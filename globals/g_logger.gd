extends Node

var active_round_panels: Array[CombatRoundPanel] = []
var active_round_index: int = 0
var context: Dictionary = {}

#region Session Lifecycle

func clear_session() -> void:
	active_round_panels.clear()
	active_round_index = 0
	context.clear()


func initialize_battle_logger(initialization_context: Dictionary) -> void:
	active_round_index = 0
	context = initialization_context


func finalize_battle_logger(attacker_won: bool) -> void:
	print("\n[SANDBOX FINISHED] Combat evaluation engine sequence complete. Winner evaluated: %s"
		% ("ATTACKER" if attacker_won else "DEFENDER"))

#endregion


#region Helpers

func _get_panel() -> CombatRoundPanel:
	if active_round_index < active_round_panels.size():
		return active_round_panels[active_round_index]
	return null


func _role_color(role: String) -> String:
	return "🟥" if role == "Attacker" else "🟦"

#endregion


#region Engine Callback

func engine_callback(event_type: String, data: Array) -> void:

	var current_panel := _get_panel()

	# Sync round index
	if event_type == "round_start":
		active_round_index = data[0]

	match event_type:

		# =========================================================
		# COMBAT START
		# =========================================================
		"combat_start":
			print("\n==================  STARTED COMBAT ==================")
			print("Game stage: %s" % context.get("game_stage_string", "Unknown"))
			print("Matchup Scale Classification: %s" % context.get("matchup_scale", "Unknown"))
			print("Attacker Forces: %s" % context.get("attacker_composition", "None"))
			print("Defender Forces: %s" % context.get("defender_composition", "None"))
			
			# Extract the underlying player configuration state dictionaries
			var atk_side: Dictionary = data[0]
			var def_side: Dictionary = data[1]
			
			# Safely fetch the structural name properties (e.g., "Attacker" / "Defender")
			# If you have specific faction designations stored there (like "Space Marines" vs "Orks"), 
			# this string extraction loop will capture them automatically!
			var atk_name: String = atk_side.get("name", "Unknown Faction")
			var def_name: String = def_side.get("name", "Unknown Faction")
			
			# Direct call update to assign the header layouts across all 3 panel views synchronously
			for panel in active_round_panels:
				if panel != null:
					panel.set_faction_titles(atk_name, def_name)


		# =========================================================
		# DICE
		# =========================================================
		"dice_pool_calculated":
			print("Calculated Dice Pools -> ATK: %d | DEF: %d" % [data[0], data[1]])
			print("\n=== PHASE 1: DICE ROLL ===")


		"dice_rolled":
			print("  -> %s rolls: %d ⚔️ | %d 🛡️ | %d 🦅 | units morale %d"
				% [data[0], data[1], data[2], data[3], data[4]])

			if current_panel:
				current_panel.set_dice_pools(data[0], data[1], data[2], data[3])


		# =========================================================
		# CARDS
		# =========================================================
		"cards_drawn_to_hand":
			print("\n=== PHASE 1.5: DRAW CARDS ===")

			var controller = context.get("controller_ref")
			if controller and controller.has_method("_print_cards_drawn"):
				controller._print_cards_drawn(data[0], data[1])


		# =========================================================
		# ROUND FLOW
		# =========================================================
		"round_start":
			print("\n🔄 --- ROUND %d ---" % (data[0] + 1))


		"unit_status_logged":
			print("📊 START %s: unrouted=%s routed=%s" % [data[0], data[1], data[2]])

			if current_panel:
				current_panel.set_round_start_unit_statuses(data[0], data[1], data[2])


		# =========================================================
		# CARD EFFECTS
		# =========================================================
		"card_icons_calculated":
			print("🎴 %s icons -> ⚔️ %d | 🛡️ %d | 🦅 %d"
				% [data[0], data[1], data[2], data[3]])


		"ability_triggered":
			var controller = context.get("controller_ref")
			var card_name := "Card #" + str(data[0])

			if controller:
				card_name = controller.get_card_metadata(data[0], "card_name")

			var msg := "  [*] %s: %s" % [card_name, data[1]]
			print(msg)

			if current_panel:
				current_panel.append_console_log(msg)


		# =========================================================
		# DAMAGE PIPELINE (NEW MODEL)
		# =========================================================

		# PHASE A: PRE DAMAGE
		"damage_pre_calculated":
			print("\n--- [PRE-DAMAGE SNAPSHOT] ---")
			print("%s %s -> ⚔️ %d | 🛡️ %d"
				% [_role_color(data[0]), data[0], data[1], data[2]])

			# UI can show comparison BEFORE resolution


		# PHASE B: RESOLVED DAMAGE
		"damage_resolved":
			print("\n--- [DAMAGE RESOLVED] ---")
			print("%s takes %d 💥" % [data[0], data[1]])

			if current_panel:
				current_panel.set_damage_assessment_pools(data[0], data[1])


		# =========================================================
		# POOL DEBUG
		# =========================================================
		"pools_updated":
			print("📌 %s pools -> ⚔️ %d | 🛡️ %d" % [data[0], data[1], data[2]])


		# =========================================================
		# DAMAGE APPLICATION EVENTS
		# =========================================================
		"unit_routed":
			print("🏳️ %s '%s' routed (took %d dmg)" % [data[0], data[1], data[2]])


		"unit_destroyed":
			var cond := "ROUTED" if data[3] else "HEALTHY"
			print("💀 %s '%s' (%s) destroyed (%d dmg)"
				% [data[0], data[1], cond, data[2]])


		"damage_absorbed":
			print("🛡️ %s '%s' absorbed %d damage while routed"
				% [data[0], data[1], data[2]])


		"unit_rallied":
			var controller = context.get("controller_ref")
			var card_name := "Card #" + str(data[3])

			if controller:
				card_name = controller.get_card_metadata(data[3], "card_name")

			print("🤝 %s rallied '%s' (%d HP) via %s"
				% [data[0], data[1], data[2], card_name])


		# =========================================================
		# ROUND END STATUS (CLEAR SEMANTIC)
		# =========================================================
		"round_end_unit_status_logged":
			print("📊 END %s: unrouted=%s routed=%s" % [data[0], data[1], data[2]])

			if current_panel:
				current_panel.set_assess_damage_unit_statuses(data[0], data[1], data[2])


		# =========================================================
		# TERMINATION / VICTORY
		# =========================================================
		"early_termination":
			print("\n⚠️ SUDDEN DEATH: one side eliminated")


		"victory_by_wipeout":
			print("\n🏁 WIN BY WIPEOUT: %s" % data[0])


		"victory_mutual_annihilation":
			print("\n💥 MUTUAL ANNIHILATION")


		"tiebreaker_morale":
			print("\n--- TIEBREAKER ---")
			print("ATK %d | DEF %d" % [data[0], data[1]])

#endregion
