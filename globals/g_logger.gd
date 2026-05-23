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
			
			for panel in active_round_panels:
				if panel != null:
					panel.set_faction_titles(atk_name, def_name)
					panel.update_unit_displays(true, "Deploying...", "")
					panel.update_unit_displays(false, "Deploying...", "")

		
		
		# =========================================================
		# UNITS
		# =========================================================
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
		
		
		"unit_morale_status_logged":
			var role_label: String = data[0]
			var morale_val: int = data[1]
			var phase_context: String = data[2]
			
			print("🧠     %s Unit 🎖️ %d (%s)" % [role_label, morale_val, phase_context])
			
			if current_panel != null:
				current_panel.set_unit_morale(role_label, morale_val, phase_context)
		# =========================================================
		# DICE
		# =========================================================
		"roll_dice_phase":
			print("\n=== PHASE 1: ROLL DICE PHASE ===")
			
		
		"dice_pool_status_logged":
			# data = [role_string, offence, defence, morale, phase_context]
			print("🎲 %s dice updated (%s) -> %d ⚔️ | %d 🛡️ | %d 🎖️" % [data[0], data[4], data[1], data[2], data[3]])
			
			if current_panel:
				var is_attacker: bool = (data[0] == "Attacker")
				var phase_context: String = data[4]
				current_panel.update_dice_displays(is_attacker, data[1], data[2], data[3], phase_context)
		
		"assess_dmg_step_dice_amounts":
			print("🎲 Modified assessment pools -> %s: %d ⚔️ | %d 🛡️ | %d 🎖️" % [data[0], data[1], data[2], data[3]])
			
			if current_panel:
				var is_attacker: bool = (data[0] == "Attacker")
				# Updates ONLY the damage assessment columns with the final modified pools
				current_panel.update_dice_displays(is_attacker, data[1], data[2], data[3], "damage_step")
		
		"bonus_dice_rolled":
			var msg := "🎲 -> %s bonus roll results: +%d ⚔️ | +%d 🛡️ | +%d 🎖️" % [data[0], data[1], data[2], data[3]]
			print(msg)
			
			if current_panel:
				current_panel.append_console_log(msg)
		
		"dice_rerolled_log":
			# data = [target_role_string ("Attacker"/"Defender"), face_removed_string, face_added_string]
			var msg := "🔄 [%s] Reroll: Lost 1 %s die -> Gained 1 %s die" % [
				data[0], 
				data[1], 
				data[2]
			]
			print(msg)
			
			if current_panel:
				current_panel.append_console_log(msg)
		# =========================================================
		# CARDS
		# =========================================================
		"cards_drawn_to_hand":
			print("\n=== PHASE 1.5: DRAW CARDS ===")

			var controller = context.get("controller_ref")
			if controller and controller.has_method("_print_cards_drawn"):
				controller._print_cards_drawn(data[0], data[1])
		
		"card_icons_logged":
			var role_label: String = data[0]
			var off_icons: int = data[1]
			var def_icons: int = data[2]
			var mor_icons: int = data[3]
			var phase_context: String = data[4]
			
			print("🎴 %s card icons updated (%s) -> ⚔️ %d | 🛡️ %d | 🎖️ %d" % [role_label, phase_context, off_icons, def_icons, mor_icons])

			if current_panel != null:
				var is_attacker: bool = (role_label == "Attacker")
				current_panel.update_card_icons_displays(is_attacker, off_icons, def_icons, mor_icons, phase_context)
		
		# =========================================================
		# EXTRA ICONS
		# =========================================================
		
		"extra_icons_logged":
			print("🎴 %s extra icons updated (%s) -> %d ⚔️ | %d 🛡️ | %d 🎖️" % [data[0], data[4], data[1], data[2], data[3]])
			
			if current_panel:
				var is_attacker: bool = (data[0] == "Attacker")
				var phase_context: String = data[4]
				current_panel.update_extra_icons(is_attacker, data[1], data[2], data[3], phase_context)
		# =========================================================
		# ROUND FLOW
		# =========================================================
		"round_start":
			var round_num: int = data[0]
			print("")
			print("\n🔄--- COMBAT ROUND %d ---" % (round_num + 1))
		
		"assess_damage_step_start":
			print("-- Assess Damage Step started. -- ")
		
		# =========================================================
		# CARD EFFECTS
		# =========================================================
		"card_icons_calculated":
			var role_label: String = data[0]
			var off_icons: int = data[1]
			var def_icons: int = data[2]
			var mor_icons: int = data[3]
			
			print("🎴 %s card icons -> ⚔️ %d | 🛡️ %d | 🎖️ %d" % [role_label, off_icons, def_icons, mor_icons])

			if current_panel != null:
				current_panel.set_assess_damage_step_card_icons(role_label, off_icons, def_icons, mor_icons)


		"ability_triggered":
			var controller = context.get("controller_ref")
			var card_name := "Card #" + str(data[0]) 

			if controller:
				var fetched_name = controller.get_card_metadata(data[0], "card_name")
				# Guard against Nil entries before committing to our strict type string
				if fetched_name != null and str(fetched_name) != "":
					card_name = str(fetched_name)

			var msg := "  [*] %s: %s" % [card_name, data[1]]
			print(msg)

			if current_panel:
				current_panel.append_console_log(msg)
		
		"tokens_updated":
			var role_label: String = data[0]
			var offence: int = data[1]
			var defence: int = data[2]
			var phase_context: String = data[3] if data.size() > 3 else "damage_step"
			
			print("🪙 %s tokens updated (%s) -> %d ⚔️ | %d 🛡️" % [role_label, phase_context, offence, defence])

			if current_panel:
				if phase_context == "round_start":
					current_panel.set_round_start_tokens(role_label, offence, defence)
				else:
					current_panel.set_assess_damage_step_tokens(role_label, offence, defence)

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
		# DAMAGE APPLICATION EVENTS
		# =========================================================
		"unit_routed":
			var message := "🏳️ %s '%s' routed (took %d dmg)" % [data[0], data[1], data[2]]
			print(message)
			# Routes directly to your scrolling panel text display
			if current_panel:
				current_panel.append_console_log(message)

		"unit_destroyed":
			var cond := "ROUTED" if data[3] else "HEALTHY"
			var message := "💀 %s '%s' (%s) destroyed (%d dmg)" % [data[0], data[1], cond, data[2]]
			print(message)
			if current_panel:
				current_panel.append_console_log(message)

		"damage_absorbed":
			var message := "🛡️ %s '%s' absorbed %d damage while routed" % [data[0], data[1], data[2]]
			print(message)
			if current_panel:
				current_panel.append_console_log(message)

		"unit_rallied":
			var controller = context.get("controller_ref")
			var card_name := "Card #" + str(data[3])

			if controller:
				card_name = controller.get_card_metadata(data[3], "card_name")

			var message := "🤝 %s rallied '%s' (%d HP) via %s" % [data[0], data[1], data[2], card_name]
			print(message)
			if current_panel:
				current_panel.append_console_log(message)


		# =========================================================
		# ROUND END STATUS
		# =========================================================


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
