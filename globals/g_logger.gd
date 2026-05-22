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
	# ==============================================================================
	# FIXED: Sync index FIRST so _get_panel() always references the correct round panel
	# ==============================================================================
	if event_type == "round_start":
		active_round_index = data[0]

	var current_panel := _get_panel()

	match event_type:

		# =========================================================
		# COMBAT START
		# =========================================================
		"combat_start":
			print("\n==================  STARTED COMBAT ==================")
			var atk_side: Dictionary = data[0]
			var def_side: Dictionary = data[1]
			
			var atk_name: String = atk_side.get("name", "Unknown Faction")
			var def_name: String = def_side.get("name", "Unknown Faction")
			
			var atk_roster: String = context.get("attacker_composition", "None")
			var def_roster: String = context.get("defender_composition", "None")
			
			for panel in active_round_panels:
				if panel != null:
					panel.set_faction_titles(atk_name, def_name)
					
					# Universal show units call for initialization (all panels start clear/ready)
					panel.update_unit_displays(true, "Deploying...", "")
					panel.update_unit_displays(false, "Deploying...", "")


		# =========================================================
		# DICE
		# =========================================================
		"dice_pool_calculated":
			print("Calculated Dice Pools -> ATK: %d | DEF: %d" % [data[0], data[1]])
			print("\n=== PHASE 1: DICE ROLL ===")


		"dice_rolled":
			print("🎲 -> %s rolls: %d ⚔️ | %d 🛡️ | %d 🎖️"
				% [data[0], data[1], data[2], data[3]])

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
			var round_num: int = data[0]
			print("")
			print("\n🔄--- COMBAT ROUND %d ---" % (round_num + 1))


		"unit_status_logged":
			# data = [side_name, unrouted_str, routed_str, optional_phase_context]
			print("💂    Units unrouted and routed -> %s: %s | %s" % [data[0], data[1], data[2]])
			
			if current_panel != null:
				var active_attacker_name: String = ""
				var controller = context.get("controller_ref")
				if controller != null:
					var raw_factions = FactionRegistry.get_database()
					var atk_profile = raw_factions.get(controller.attacker_faction)
					active_attacker_name = atk_profile.get("name", FactionRegistry.FactionID.keys()[controller.attacker_faction])
				
				var is_attacker :bool = (data[0] == active_attacker_name)
				
				# Extract target phase context if the engine provided it, otherwise default to "all"
				var phase_context: String = data[3] if data.size() > 3 else "all"
				
				# Execute universal unified visual router pass
				current_panel.update_unit_displays(is_attacker, data[1], data[2], phase_context)
		
		"unit_morale_calculated":
			# data = [role_string ("Attacker"/"Defender"), morale_value (int)]
			print("🧠     %s Unit 🎖️ %d" % [data[0], data[1]])
			
			if current_panel != null:
				current_panel.set_unit_morale(data[0], data[1])

		# =========================================================
		# CARD EFFECTS
		# =========================================================
		"card_icons_calculated":
			print("🎴 %s card icons -> ⚔️ %d | 🛡️ %d | 🎖️ %d"
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
		# DAMAGE PIPELINE
		# =========================================================

		# PHASE A: PRE DAMAGE
		"damage_pre_calculated":
			print("\n--- [PRE-DAMAGE SNAPSHOT] ---")
			print("%s %s -> ⚔️ %d | 🛡️ %d"
				% [_role_color(data[0]), data[0], data[1], data[2]])


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
		# ROUND END STATUS
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
			# Clear unreached round rows cleanly to indicate match resolution
			for i in range(active_round_index + 1, active_round_panels.size()):
				if active_round_panels[i] != null:
					active_round_panels[i].update_unit_displays(true, "Match Terminated", "")
					active_round_panels[i].update_unit_displays(false, "Match Terminated", "")


		"victory_by_wipeout":
			print("\n🏁 WIN BY WIPEOUT: %s" % data[0])


		"victory_mutual_annihilation":
			print("\n💥 MUTUAL ANNIHILATION")


		"tiebreaker_morale":
			print("\n--- TIEBREAKER ---")
			print("ATK %d | DEF %d" % [data[0], data[1]])

#endregion
