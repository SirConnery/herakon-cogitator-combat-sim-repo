extends Node
# G_Logger Autoload Singleton

var active_round_panels: Array[CombatRoundPanel] = []
var active_round_index: int = 0
var context: Dictionary = {}

func clear_session() -> void:
	active_round_panels.clear()
	active_round_index = 0
	context.clear()

func initialize_battle_logger(initialization_context: Dictionary) -> void:
	active_round_index = 0
	context = initialization_context

func finalize_battle_logger(attacker_won: bool) -> void:
	print("\n[SANDBOX FINISHED] Combat evaluation engine sequence complete. Winner evaluated: %s" % ("ATTACKER" if attacker_won else "DEFENDER"))

func engine_callback(event_type: String, data: Array) -> void:
	# Synchronize active round bounds tracking indices instantly
	if event_type == "round_start":
		active_round_index = data[0]
		
	var current_panel: CombatRoundPanel = null
	if active_round_index < active_round_panels.size():
		current_panel = active_round_panels[active_round_index]

	match event_type:
		"combat_start":
			print("\n==================  STARTED COMBAT ==================")
			print("Game stage: %s" % context.get("game_stage_string", "Unknown"))
			print("Matchup Scale Classification: %s" % context.get("matchup_scale", "Unknown"))
			print("Attacker Forces: %s" % context.get("attacker_composition", "None"))
			print("Defender Forces: %s" % context.get("defender_composition", "None"))
			
		"dice_pool_calculated":
			print("Calculated Combat Values -> Attacker: %d, Defender: %d" % [data[0], data[1]])
			print("\n=== PHASE 1.0: ROLL DICE STEP ===")
			
		"dice_rolled":
			# data = [role_name, offence, defence, card_morale, total_morale]
			print("  -> %s Rolls: %d ⚔️, %d 🛡️, %d 🦅, %d 🦅 from units)" % [data[0], data[1], data[2], data[3], data[4]])
			if current_panel != null:
				current_panel.set_dice_pools(data[0], data[1], data[2], data[4])
				
		"cards_drawn_to_hand":
			print("\n=== PHASE 1.5: DRAWING COMBAT HANDS ===")
			var controller = context.get("controller_ref")
			if controller != null and controller.has_method("_print_cards_drawn"):
				controller._print_cards_drawn(data[0], data[1])
			print("=======================================")
			
		"round_start":
			print("")
			print("\n🔄--- COMBAT ROUND %d ---" % (data[0] + 1))
			
		"unit_status_logged":
			# data = [side_name, unrouted_str, routed_str]
			print("    📊 %s units unrouted: %s" % [data[0], data[1]])
			print("    📊 %s units routed: %s" % [data[0], data[2]])
			if current_panel != null:
				current_panel.set_unit_statuses(data[0], data[1], data[2])
				
		"card_icons_calculated":
			print("    🎴 %s Card Icons on play area -> Offence: %d, Defence: %d, Morale: %d" % [data[0], data[1], data[2], data[3]])
			
		"ability_block_started":
			print("")
			print(" [%s] Processing %s Abilities..." % [data[0], data[1]])
			
		"ability_triggered":
			# data = [card_id, message_string]
			var card_id: int = data[0]
			var card_name: String = "Card #" + str(card_id)
			var controller = context.get("controller_ref")
			if controller != null and controller.has_method("get_card_metadata"):
				card_name = controller.get_card_metadata(card_id, "card_name")
				
			var msg: String = "  [*] %s. %s" % [card_name, data[1]]
			print(msg)
			if current_panel != null:
				current_panel.append_console_log(msg)
				
		"pools_updated":
			print("")
			print("  Current Action Frame -> %s Pool: %d ⚔️, %d 🛡️" % [data[0], data[1], data[2]])
			
		"damage_calculated":
			# data = [net_damage_to_defender, net_damage_to_attacker]
			print("")
			print("  -----[ASSESS DAMAGE STEP]-----")
			print("Net Impact: Defender suffers %d 💥 | Attacker suffers %d 💥" % [data[0], data[1]])
			if current_panel != null:
				current_panel.set_damage_assessment_pools(data[0], data[1])
				
		"unit_routed":
			print("     -> 🏳️ %s '%s' took %d damage and was forced to ROUT!" % [data[0], data[1], data[2]])
			
		"unit_rallied":
			var card_name: String = "Card #" + str(data[3])
			var controller = context.get("controller_ref")
			if controller != null and controller.has_method("get_card_metadata"):
				card_name = controller.get_card_metadata(data[3], "card_name")
			print("     -> 🤝 %s successfully RALLIED '%s' (Health: %d) using %s!" % [data[0], data[1], data[2], card_name])
			
		"unit_ability_not_resolved":
			var card_id: int = data[1]
			var req_unit_payload = data[2]
			
			var card_name: String = "Card #" + str(card_id)
			var req_unit_str: String = "Unknown Type"
			
			var controller = context.get("controller_ref")
			if controller != null and controller.has_method("get_card_metadata"):
				card_name = controller.get_card_metadata(card_id, "card_name")
				
				# Unpack collection dynamically to safely preserve multi-unit requirements
				if req_unit_payload is Array:
					var names: Array[String] = []
					for unit_enum in req_unit_payload:
						names.append(controller.get_card_metadata(card_id, "required_unit_types"))
					req_unit_str = " + ".join(names)
				else:
					req_unit_str = controller.get_card_metadata(card_id, "required_unit_types")
					
			print("     -> 🚫 %s Unit Ability SKIPPED: '%s' requires an unrouted '%s' unit." % [data[0], card_name, req_unit_str])
			
		"dice_rerolled_log":
			print("    -> 🎲 %s rerolled a %s icon into a %s icon!" % [data[0], data[1], data[2]])
			
		"damage_absorbed":
			print("     -> 🛡️ %s '%s' safely absorbed %d damage while routed." % [data[0], data[1], data[2]])
			
		"unit_destroyed":
			var cond = "ROUTED" if data[3] else "HEALTHY"
			print("     -> 💀 %s '%s' (%s) took %d damage and was completely DESTROYED!" % [data[0], data[1], cond, data[2]])
			
		"early_termination":
			print("\n[ALERT] Sudden Death! An entire side has been eliminated from the theater.")
			
		"victory_by_wipeout":
			print("\n  -----[RESOLUTION PHASE]----- ") 
			print("Tactical deployment complete. Winner: %s by clean wipeout." % data[0])
			
		"victory_mutual_annihilation":
			print("\n  -----[RESOLUTION PHASE]----- ") 
			print("💥 MUTUAL ANNIHILATION DETECTED! Both armies completely eradicated each other in the crossfire.")
			
		"tiebreaker_morale":
			print("\n  -----[RESOLUTION PHASE]----- ")
			print("Evaluating final Morale Pools -> Attacker: %d, Defender: %d" % [data[0], data[1]])
			
		"bonus_dice_rolled":
			print("     ↳ 🎲 %s Dice roll: +%d ⚔️ | +%d 🛡️ | +%d 🦅 " % [data[0], data[1], data[2], data[3]])
