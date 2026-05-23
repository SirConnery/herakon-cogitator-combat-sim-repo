extends Object
class_name SimCombatEngine

# --- HIGH-SPEED SIMULATION ENUMS ---
enum Side { ATTACKER, DEFENDER }
enum Stat { OFFENCE, DEFENCE, MORALE }
enum PoolType { GENERIC, OFFENCE, DEFENCE, MORALE }
enum AbilityBlock { GENERAL, UNIT }

static func _roll_custom_die_index() -> int:
	var roll: int = randi() % 6
	if roll <= 2:   return 0 # Offence
	elif roll <= 4: return 1 # Defence
	return 2                 # Morale

#region Main Loop

static func run_full_match(state: Dictionary, card_db: Dictionary, on_event: Callable = Callable()) -> bool:
	# --- 1. CORE ROLES & DATA STATES ---
	var atk: Dictionary = state[Side.ATTACKER]
	var def: Dictionary = state[Side.DEFENDER]

	# --- 2. DICE INITIALIZATION & COUNTERS ---
	var atk_dice_offence := 0
	var atk_dice_defence := 0
	var atk_dice_morale := 0

	var def_dice_offence := 0
	var def_dice_defence := 0
	var def_dice_morale := 0

	var atk_dice_to_roll := 0
	var def_dice_to_roll := 0

	var atk_draw_count := 0
	var def_draw_count := 0

	# --- 3. RECURRING ROUND-LOOP SCRATCHPAD VARIABLES ---
	var atk_idx := 0
	var def_idx := 0
	var atk_card_id := 0
	var def_card_id := 0

	var card_icons_atk_offence := 0
	var card_icons_atk_defence := 0
	var card_icons_atk_morale := 0

	var card_icons_def_offence := 0
	var card_icons_def_defence := 0
	var card_icons_def_morale := 0

	# Flattened integer arrays to avoid string-keyed scratchpads
	var token_pools := [0, 0, 0, 0] # Index maps to Side and Token Stat combinations
	var context := [0, 0, 0, 0, 0, 0]

	var def_routing_lethal := false
	var atk_routing_lethal := false

	# --- 4. TIEBREAKER & RESOLUTION VARIABLES ---
	var atk_survivors := 0
	var def_survivors := 0
	var final_atk_morale := 0
	var final_def_morale := 0
	var atk_morale_from_units := 0
	var def_morale_from_units := 0

	# ==============================================================================
	# ENGINE SIMULATION START
	# ==============================================================================
	if on_event.is_valid():
		on_event.call("combat_start", [atk, def])

	# --- PHASE 1: ROLL DICE PHASE ---
	for squad in atk["squads"]:
		atk_dice_to_roll += squad["alive_figures"].size() * squad["combat_value"]

	for squad in def["squads"]:
		def_dice_to_roll += squad["alive_figures"].size() * squad["combat_value"]

	atk_dice_to_roll = min(8, atk_dice_to_roll)
	def_dice_to_roll = min(8, def_dice_to_roll)
	
	# Roll Attacker Dice
	for i in range(atk_dice_to_roll):
		match _roll_custom_die_index():
			0: atk_dice_offence += 1
			1: atk_dice_defence += 1
			2: atk_dice_morale += 1

	# Roll Defender Dice
	for i in range(def_dice_to_roll):
		match _roll_custom_die_index():
			0: def_dice_offence += 1
			1: def_dice_defence += 1
			2: def_dice_morale += 1

	# Store initial raw dice results into integer enum slots
	atk[Stat.OFFENCE] = atk_dice_offence
	atk[Stat.DEFENCE] = atk_dice_defence
	atk[Stat.MORALE] = atk_dice_morale

	def[Stat.OFFENCE] = def_dice_offence
	def[Stat.DEFENCE] = def_dice_defence
	def[Stat.MORALE] = def_dice_morale

	if on_event.is_valid():
		on_event.call("roll_dice_phase", [])
		log_current_dice_pools(on_event, atk[Stat.OFFENCE], atk[Stat.DEFENCE], atk[Stat.MORALE], def[Stat.OFFENCE], def[Stat.DEFENCE], def[Stat.MORALE], "round_start")
		
		atk_morale_from_units = _calculate_current_morale_from_units(atk)
		def_morale_from_units = _calculate_current_morale_from_units(def)
		on_event.call("unit_morale_calculated", ["Attacker", atk_morale_from_units, "round_start"])
		on_event.call("unit_morale_calculated", ["Defender", def_morale_from_units, "round_start"])

	# --- DRAW COMBAT CARDS STEP ---
	atk["cards_in_hand"] = []
	def["cards_in_hand"] = []

	atk_draw_count = min(5, atk["combat_deck"].size())
	for i in range(atk_draw_count):
		var draw_idx: int = randi() % atk["combat_deck"].size()
		atk["cards_in_hand"].append(atk["combat_deck"].pop_at(draw_idx))

	def_draw_count = min(5, def["combat_deck"].size())
	for i in range(def_draw_count):
		var draw_idx: int = randi() % def["combat_deck"].size()
		def["cards_in_hand"].append(def["combat_deck"].pop_at(draw_idx))

	if on_event.is_valid():
		on_event.call("cards_drawn_to_hand", [atk["cards_in_hand"], def["cards_in_hand"]])

	# --- PHASE 2: THREE-ROUND COMBAT ENGINE CRUCIBLE LOOP ---
	for round_index in range(3):

		if _count_living_units(atk) == 0 or _count_living_units(def) == 0:
			if on_event.is_valid():
				on_event.call("early_termination", [])
			break

		if on_event.is_valid():
			on_event.call("round_start", [round_index])
			atk_morale_from_units = _calculate_current_morale_from_units(atk)
			def_morale_from_units = _calculate_current_morale_from_units(def)
			
			log_current_army_statuses(state, on_event)
			log_current_dice_pools(on_event, atk[Stat.OFFENCE], atk[Stat.DEFENCE], atk[Stat.MORALE], def[Stat.OFFENCE], def[Stat.DEFENCE], def[Stat.MORALE], "round_start")
			
			on_event.call("unit_morale_calculated", ["Attacker", atk_morale_from_units, "round_start"])
			on_event.call("unit_morale_calculated", ["Defender", def_morale_from_units, "round_start"])

		# --- PLAY COMBAT CARDS ---
		atk_idx = randi() % atk["cards_in_hand"].size()
		def_idx = randi() % def["cards_in_hand"].size()

		atk_card_id = atk["cards_in_hand"].pop_at(atk_idx)
		def_card_id = def["cards_in_hand"].pop_at(def_idx)

		atk["play_area"][round_index] = atk_card_id
		def["play_area"][round_index] = def_card_id

		# --- CLEAR AND AGGREGATE CARD ICONS ---
		card_icons_atk_offence = 0
		card_icons_atk_defence = 0
		card_icons_atk_morale = 0
		card_icons_def_offence = 0
		card_icons_def_defence = 0
		card_icons_def_morale = 0

		for i in range(round_index + 1):
			var a = card_db[atk["play_area"][i]]
			var d = card_db[def["play_area"][i]]

			card_icons_atk_offence += a[0]
			card_icons_atk_defence += a[1]
			card_icons_atk_morale += a[2]

			card_icons_def_offence += d[0]
			card_icons_def_defence += d[1]
			card_icons_def_morale += d[2]

		if on_event.is_valid():
			on_event.call("card_icons_calculated", ["Attacker", card_icons_atk_offence, card_icons_atk_defence, card_icons_atk_morale])
			on_event.call("card_icons_calculated", ["Defender", card_icons_def_offence, card_icons_def_defence, card_icons_def_morale])
			
		# --- INSTANTIATE LOCAL OPERATION SCRATCHPADS ---
		token_pools[0] = 0 # Attacker Offence Token
		token_pools[1] = 0 # Attacker Defence Token
		token_pools[2] = 0 # Defender Offence Token
		token_pools[3] = 0 # Defender Defence Token

		atk["parent_state"] = state
		def["parent_state"] = state

		_resolve_instant_ability(atk_card_id, card_db, token_pools, Side.ATTACKER, state, on_event)
		_resolve_instant_ability(def_card_id, card_db, token_pools, Side.DEFENDER, state, on_event)
		
		if on_event.is_valid():
			on_event.call("assess_damage_step_start", [])
			log_current_army_statuses(state, on_event, "damage_step")
			log_current_dice_pools(on_event, atk[Stat.OFFENCE], atk[Stat.DEFENCE], atk[Stat.MORALE], def[Stat.OFFENCE], def[Stat.DEFENCE], def[Stat.MORALE], "damage_step")
			
			atk_morale_from_units = _calculate_current_morale_from_units(atk)
			def_morale_from_units = _calculate_current_morale_from_units(def)
			on_event.call("unit_morale_calculated", ["Attacker", atk_morale_from_units, "damage_step"])
			on_event.call("unit_morale_calculated", ["Defender", def_morale_from_units, "damage_step"])
			
		atk.erase("parent_state")
		def.erase("parent_state")

		# --- BUILD GLOBAL STRUCTURAL TOTAL CONTEXT ---
		context[0] = atk[Stat.OFFENCE] + card_icons_atk_offence + token_pools[0] # atk_offence
		context[1] = atk[Stat.DEFENCE] + card_icons_atk_defence + token_pools[1] # atk_defence
		context[2] = def[Stat.OFFENCE] + card_icons_def_offence + token_pools[2] # def_offence
		context[3] = def[Stat.DEFENCE] + card_icons_def_defence + token_pools[3] # def_defence
	
		_execute_timing_hook(CardData.TimingWindow.BEFORE_DAMAGE, state, context, round_index, card_db, on_event)

		if on_event.is_valid():
			on_event.call("damage_pre_calculated", ["Attacker", context[0], context[1]])
			on_event.call("damage_pre_calculated", ["Defender", context[2], context[3]])
		
		# --- NET CONFLICT MITIGATION ---
		context[4] = max(0, context[0] - context[3]) # net_damage_to_defender
		context[5] = max(0, context[2] - context[1]) # net_damage_to_attacker

		_execute_timing_hook(CardData.TimingWindow.DURING_DAMAGE, state, context, round_index, card_db, on_event)
		
		if on_event.is_valid():
			on_event.call("damage_resolved", ["Attacker", context[5]])
			on_event.call("damage_resolved", ["Defender", context[4]])

		# --- RESOLVE DAMAGE LIFECYCLES ---
		def_routing_lethal = _is_routing_lethal(atk_card_id, card_db, def)
		atk_routing_lethal = _is_routing_lethal(def_card_id, card_db, atk)

		var defender_newly_routed_array: Array[Dictionary] = apply_damage(def, context[4], round_index, def_routing_lethal, on_event)
		var attacker_newly_routed_array: Array[Dictionary] = apply_damage(atk, context[5], round_index, atk_routing_lethal, on_event)

		state["defender_newly_routed"] = defender_newly_routed_array
		state["attacker_newly_routed"] = attacker_newly_routed_array

		_execute_timing_hook(CardData.TimingWindow.AFTER_DAMAGE, state, context, round_index, card_db, on_event)

	# --- FINAL WIN CONDITION RESOLUTION EVALUATION ---
	atk_survivors = _count_living_units(atk)
	def_survivors = _count_living_units(def)

	if atk_survivors == 0 and def_survivors == 0:
		if on_event.is_valid(): on_event.call("victory_mutual_annihilation", [])
		return false

	if def_survivors == 0:
		if on_event.is_valid(): on_event.call("victory_by_wipeout", ["Attacker"])
		return true

	if atk_survivors == 0:
		if on_event.is_valid(): on_event.call("victory_by_wipeout", ["Defender"])
		return false

	final_atk_morale = _calculate_current_morale_from_units(atk) + atk[Stat.MORALE]
	final_def_morale = _calculate_current_morale_from_units(def) + def[Stat.MORALE]

	if on_event.is_valid():
		on_event.call("tiebreaker_morale", [final_atk_morale, final_def_morale])

	return final_atk_morale >= final_def_morale

#endregion

#region Taking damage

static func apply_damage(player_state: Dictionary, total_damage: int, round_index: int, is_routing_lethal: bool, on_event: Callable) -> Array[Dictionary]:
	var squads: Array = player_state["squads"]
	var side_name: String = player_state["name"]
	var newly_routed_units: Array[Dictionary] = []
	
	while total_damage > 0:
		var has_unrouted_units: bool = false
		var has_any_living_units: bool = false
		
		for squad in squads:
			for i in range(squad["alive_figures"].size()):
				if squad["alive_figures"][i] > 0:
					has_any_living_units = true
					if not squad["figures_routed"][i]:
						has_unrouted_units = true
		
		if not has_any_living_units:
			total_damage = 0
			break

		# --------------------------------------------------
		# STEP 1: PERFECT ABSORPTION (0 DEATHS STRATEGY)
		# --------------------------------------------------
		var perfect_target := _find_perfect_absorption_target(squads, total_damage, has_unrouted_units, is_routing_lethal)
		
		if not perfect_target.is_empty():
			var target_squad: Dictionary = perfect_target["squad"]
			var target_idx: int = perfect_target["index"]
			var target_was_routed: bool = target_squad["figures_routed"][target_idx]
			
			if target_was_routed:
				if on_event.is_valid():
					on_event.call("damage_absorbed", [side_name, target_squad["name"], total_damage, true])
			else:
				if on_event.is_valid():
					on_event.call("unit_routed", [side_name, target_squad["name"], total_damage])
				target_squad["figures_routed"][target_idx] = true
				newly_routed_units.append({"squad": target_squad, "index": target_idx})
				
			target_squad["alive_figures"][target_idx] -= total_damage
			total_damage = 0
			break

		# --------------------------------------------------
		# STEP 2: LETHAL DAMAGE FALLBACKS
		# --------------------------------------------------
		var sacrifice_target := _find_lethal_sacrifice_target(squads, total_damage, round_index, has_unrouted_units, is_routing_lethal)

		if sacrifice_target.is_empty():
			total_damage = 0
			break
			
		var final_squad: Dictionary = sacrifice_target["squad"]
		var final_idx: int = sacrifice_target["index"]
		var final_was_routed: bool = final_squad["figures_routed"][final_idx]
		var hp_to_kill: int = final_squad["alive_figures"][final_idx]
		
		if not final_was_routed:
			newly_routed_units.append({"squad": final_squad, "index": final_idx})

		if on_event.is_valid():
			on_event.call("unit_destroyed", [side_name, final_squad["name"], hp_to_kill, final_was_routed])
			
		total_damage -= hp_to_kill
		final_squad["alive_figures"][final_idx] = 0
		final_squad["figures_routed"][final_idx] = true
		
	return newly_routed_units


static func _find_perfect_absorption_target(squads: Array, total_damage: int, restrict_to_unrouted: bool, is_routing_lethal: bool) -> Dictionary:
	var perfect_target: Dictionary = {}
	var smallest_surviving_hp: int = 9999
	
	for squad in squads:
		for i in range(squad["alive_figures"].size()):
			if squad["alive_figures"][i] > 0:
				var is_routed: bool = squad["figures_routed"][i]
				
				if restrict_to_unrouted and is_routed:
					continue
					
				if is_routing_lethal and not is_routed:
					continue
					
				var hp_left = squad["alive_figures"][i]
				if total_damage < hp_left and hp_left < smallest_surviving_hp:
					smallest_surviving_hp = hp_left
					perfect_target = {"squad": squad, "index": i}
					
	return perfect_target

#endregion

#region Logging functions

static func log_current_army_statuses(state: Dictionary, on_event: Callable, phase_context: String = "all") -> void:
	if not on_event.is_valid():
		return
		
	var sides = [state[Side.ATTACKER], state[Side.DEFENDER]]
	for side in sides:
		var side_name: String = side["name"]
		var unrouted_list: Array[String] = []
		var routed_list: Array[String] = []
		
		for squad in side["squads"]:
			for i in range(squad["alive_figures"].size()):
				if squad["alive_figures"][i] > 0:
					if squad["figures_routed"][i]:
						routed_list.append(squad["name"])
					else:
						unrouted_list.append(squad["name"])
						
		var unrouted_str = ", ".join(unrouted_list) if not unrouted_list.is_empty() else "None"
		var routed_str = ", ".join(routed_list) if not routed_list.is_empty() else "None"
		
		on_event.call("unit_status_logged", [side_name, unrouted_str, routed_str, phase_context])

static func log_current_dice_pools(on_event: Callable, atk_offence: int, atk_defence: int, atk_morale: int, def_offence: int, def_defence: int, def_morale: int, phase_context: String = "all") -> void:
	on_event.call("dice_pool_status_logged", ["Attacker", atk_offence, atk_defence, atk_morale, phase_context])
	on_event.call("dice_pool_status_logged", ["Defender", def_offence, def_defence, def_morale, phase_context])

#endregion

#region Helper Functions

static func _find_highest_health_living_unit(squads: Array, restrict_to_unrouted: bool) -> Dictionary:
	var target: Dictionary = {}
	var max_hp: int = -1
	
	for squad in squads:
		for i in range(squad["alive_figures"].size()):
			if squad["alive_figures"][i] > 0:
				if restrict_to_unrouted and squad["figures_routed"][i]:
					continue
					
				var current_hp = squad["alive_figures"][i]
				if current_hp > max_hp:
					max_hp = current_hp
					target = {"squad": squad, "index": i}
	return target


static func _find_lowest_tier_living_unit(squads: Array, restrict_to_unrouted: bool) -> Dictionary:
	var target: Dictionary = {}
	var lowest_tier: int = 9999
	
	for squad in squads:
		if squad["tier"] < lowest_tier:
			for i in range(squad["alive_figures"].size()):
				if squad["alive_figures"][i] > 0:
					if restrict_to_unrouted and squad["figures_routed"][i]:
						continue
						
					lowest_tier = squad["tier"]
					target = {"squad": squad, "index": i}
					break 
	return target


static func _find_lowest_tier_unit_to_destroy(squads: Array) -> Dictionary:
	var lowest_tier: int = 9999
	
	for squad in squads:
		for i in range(squad["alive_figures"].size()):
			if squad["alive_figures"][i] > 0:
				if squad["tier"] < lowest_tier:
					lowest_tier = squad["tier"]
					
	if lowest_tier == 9999:
		return {}

	var candidates: Array[Dictionary] = []
	for squad in squads:
		if squad["tier"] == lowest_tier:
			for i in range(squad["alive_figures"].size()):
				if squad["alive_figures"][i] > 0:
					candidates.append({"squad": squad, "index": i})

	for c in candidates:
		if c["squad"]["figures_routed"][c["index"]]:
			return c

	return candidates[0]


static func _find_lowest_tier_matching_unit(squads: Array, required_types: Array) -> Dictionary:
	var target: Dictionary = {}
	var lowest_tier: int = 9999
	
	for squad in squads:
		var squad_type: int = int(squad.get("unit_type", 0))
		
		if required_types.has(squad_type):
			if squad["tier"] < lowest_tier:
				for i in range(squad["alive_figures"].size()):
					if squad["alive_figures"][i] > 0 and not squad["figures_routed"][i]:
						lowest_tier = squad["tier"]
						target = {"squad": squad, "index": i}
						break
	return target


static func _count_living_units(player_state: Dictionary) -> int:
	var count: int = 0
	for squad in player_state["squads"]:
		for hp in squad["alive_figures"]:
			if hp > 0: count += 1
	return count


static func _calculate_current_morale_from_units(player_state: Dictionary) -> int:
	var total: int = 0
	for squad in player_state["squads"]:
		for i in range(squad["alive_figures"].size()):
			if squad["alive_figures"][i] > 0 and not squad["figures_routed"][i]:
				total += squad["morale_value"]
	return total


static func _is_mutual_annihilation(state: Dictionary) -> bool:
	var atk_survivors: int = _count_living_units(state[Side.ATTACKER])
	var def_survivors: int = _count_living_units(state[Side.DEFENDER])
	return atk_survivors == 0 and def_survivors == 0


static func _has_active_unit_type(side_data: Dictionary, required_types: Array) -> bool:
	if required_types.is_empty():
		return true
		
	for squad in side_data["squads"]:
		var squad_type: int = int(squad.get("unit_type", 0))
		
		if required_types.has(squad_type):
			for i in range(squad["alive_figures"].size()):
				if squad["alive_figures"][i] > 0 and not squad["figures_routed"][i]:
					return true
	return false


static func _has_any_routed_units(side_data: Dictionary) -> bool:
	for squad in side_data["squads"]:
		for i in range(squad["alive_figures"].size()):
			if squad["alive_figures"][i] > 0 and squad["figures_routed"][i]:
				return true
	return false


static func _has_reached_max_dice(side_data: Dictionary) -> bool:
	var side_dice: int = side_data[Stat.OFFENCE] + side_data[Stat.DEFENCE] + side_data[Stat.MORALE]
	return side_dice >= 8

#endregion


#region Timing Hook

static func _execute_timing_hook(window: int, state: Dictionary, context: Array, round_index: int, card_db: Dictionary, on_event: Callable) -> void:
	match window:
		3: # CardData.TimingWindow.AFTER_DAMAGE
			var atk: Dictionary = state[Side.ATTACKER]
			var def: Dictionary = state[Side.DEFENDER]
			
			var sides_to_check = [
				{"player": atk, "opponent": def, "routed_list": state.get("defender_newly_routed", []), "role": "Attacker", "opp_role": "Defender", "opp_stat_morale": Stat.MORALE},
				{"player": def, "opponent": atk, "routed_list": state.get("attacker_newly_routed", []), "role": "Defender", "opp_role": "Attacker", "opp_stat_morale": Stat.MORALE}
			]
			
			for side in sides_to_check:
				var active_card_id: int = side["player"]["play_area"][round_index]
				if not card_db.has(active_card_id): continue
				
				var card_data: Array = card_db[active_card_id]
				var effects_list: Array = card_data[3]
				
				for fx in effects_list:
					var effect_type: int = fx[0]
					
					var is_unit_fx: bool = (fx[4] == 1)
					if is_unit_fx:
						var req_types: Array = fx[5]
						if not req_types.is_empty() and not _has_active_unit_type(side["player"], req_types):
							continue
					
					if effect_type == CardData.EffectType.DESTROY_ON_ROUT_OR_SPEND:
						var newly_routed: Array = side["routed_list"]
						var ransom_cost: int = int(fx[2])
						
						if newly_routed.is_empty():
							continue
						
						var master_header_logged := false
							
						for target_data in newly_routed:
							var squad: Dictionary = target_data["squad"]
							var idx: int = target_data["index"]
							
							if squad["alive_figures"][idx] <= 0:
								continue
							
							if not master_header_logged and on_event.is_valid():
								on_event.call("ability_triggered", [active_card_id, "💥 Passive Threat Snapped: Ambush conditions met! Demanding survival ransoms."])
								master_header_logged = true
								
							var opponent_side: Dictionary = side["opponent"]
							
							if opponent_side.get(side["opp_stat_morale"], 0) >= ransom_cost:
								opponent_side[side["opp_stat_morale"]] -= ransom_cost
								
								if on_event.is_valid():
									on_event.call("ability_triggered", [active_card_id, "↳ 🤝 Opponent spends %d Morale die ransom! %s figure survives." % [ransom_cost, squad["name"]]])
							else:
								squad["alive_figures"][idx] = 0
								squad["figures_routed"][idx] = true
								
								if on_event.is_valid():
									on_event.call("ability_triggered", [active_card_id, "↳ 🪓 Ransom unpaid! Instant execution resolved on %s." % squad["name"]])
									on_event.call("unit_destroyed", [side["opp_role"], squad["name"], 0, true])

#endregion


#region Instant Card Abilities

static var EFFECT_RESOLVERS = {
	CardData.EffectType.CHOICE: _execute_choice_selection,
	CardData.EffectType.GAIN_DICE: _execute_gain_dice,
	CardData.EffectType.GAIN_SPECIFIC_DICE: _execute_gain_specific_dice,
	CardData.EffectType.REROLL: _execute_reroll,
	CardData.EffectType.GAIN_SPECIFIC_COMBAT_TOKEN: _execute_gain_specific_combat_token,
	CardData.EffectType.RALLY: _execute_rally, 
	CardData.EffectType.DESTROY_FOR_DESTROY: _execute_destroy_for_destroy,
}

static func _resolve_instant_ability(active_card_id: int, card_db: Dictionary, token_pools: Array, side_id: int, state: Dictionary, on_event: Callable) -> void:
	var card_data: Array = card_db[active_card_id]
	var effects_list: Array = card_data[3]
	if effects_list.is_empty():
		return
		
	var role_label := "Attacker" if side_id == Side.ATTACKER else "Defender"
	var side_data: Dictionary = state[side_id]
	
	var has_valid_units := true
	for fx in effects_list:
		var is_unit_fx: bool = (fx[4] == 1)
		if is_unit_fx:
			var req_types: Array = fx[5]
			if not req_types.is_empty() and not _has_active_unit_type(side_data, req_types):
				has_valid_units = false
				if on_event.is_valid():
					on_event.call("unit_ability_not_resolved", [role_label, active_card_id, req_types])
				break

	var general_phase_started := false
	var unit_phase_started := false
	
	for fx in effects_list:
		var is_unit_fx: bool = (fx[4] == 1)
		if is_unit_fx and not has_valid_units:
			continue

		var effect_type: int = fx[0]

		if effect_type == CardData.EffectType.DESTROY_ON_ROUT_OR_SPEND:
			if not has_valid_units:
				continue
			if on_event.is_valid():
				on_event.call("ability_triggered", [active_card_id, "⚠️ Passive Threat Primed: Any units routed this round face destruction!"])

		if not is_unit_fx and not general_phase_started:
			general_phase_started = true
			if on_event.is_valid(): on_event.call("ability_block_started", [role_label, "General"])
		elif is_unit_fx and not unit_phase_started:
			unit_phase_started = true
			if on_event.is_valid(): on_event.call("ability_block_started", [role_label, "Unit"])
		
		if EFFECT_RESOLVERS.has(effect_type):
			EFFECT_RESOLVERS[effect_type].call(fx, token_pools, side_data, role_label, active_card_id, has_valid_units, on_event)
		else:
			if effect_type != CardData.EffectType.DESTROY_ON_ROUT_OR_SPEND:
				print("    -> ⚠️ Engine skipped non-instant or unresolved effect archetype: %d" % effect_type)

# ==============================================================================
# ATOMIC MECHANIC RESOLVERS
# ==============================================================================

static func _execute_choice_selection(fx: Array, token_pools: Array, side_data: Dictionary, role: String, card_id: int, units_valid: bool, on_event: Callable) -> void:
	var options = fx[2]
	if not options is Array or options.is_empty():
		return
		
	var valid_options: Array = []
	for sub_fx in options:
		if not sub_fx is Array:
			continue
		var effect_type: int = sub_fx[0]
		
		match effect_type:
			CardData.EffectType.RALLY:
				if _has_any_routed_units(side_data):
					valid_options.append(sub_fx)
			CardData.EffectType.GAIN_DICE, CardData.EffectType.GAIN_SPECIFIC_DICE:
				var current_total: int = side_data[Stat.OFFENCE] + side_data[Stat.DEFENCE] + side_data[Stat.MORALE]
				if current_total < 8:
					valid_options.append(sub_fx)
			_:
				valid_options.append(sub_fx)
				
	var final_pool: Array = valid_options if not valid_options.is_empty() else options
	var rolled_index := randi() % final_pool.size()
	var chosen_sub_fx = final_pool[rolled_index].duplicate(true)
	
	if not chosen_sub_fx is Array or chosen_sub_fx.is_empty():
		return
		
	var sub_effect_type: int = chosen_sub_fx[0]
	if EFFECT_RESOLVERS.has(sub_effect_type):
		EFFECT_RESOLVERS[sub_effect_type].call(chosen_sub_fx, token_pools, side_data, role, card_id, units_valid, on_event)


static func _execute_gain_dice(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	if fx[2] is Array:
		return
		
	var requested_val: int = fx[2]
	var current_total_dice: int = side_data[Stat.OFFENCE] + side_data[Stat.DEFENCE] + side_data[Stat.MORALE]
	var allowed_val: int = min(requested_val, 8 - current_total_dice)
	
	if allowed_val <= 0:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "Resolved GAIN_DICE skipped - Already at maximum 8 dice cap."])
		return
		
	if on_event.is_valid(): 
		on_event.call("ability_triggered", [card_id, "Resolved GAIN_DICE (Count: %d)" % allowed_val])
	
	var b_offence := 0; var b_defence := 0; var b_morale := 0
	for d in range(allowed_val):
		match _roll_custom_die_index():
			0: b_offence += 1
			1: b_defence += 1
			2: b_morale += 1
		
	if on_event.is_valid(): 
		on_event.call("bonus_dice_rolled", [role, b_offence, b_defence, b_morale])
	
	side_data[Stat.OFFENCE] += b_offence
	side_data[Stat.DEFENCE] += b_defence
	side_data[Stat.MORALE] += b_morale


static func _execute_gain_specific_dice(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	if fx[2] is Array:
		return
		
	var requested_val: int = fx[2]
	var pool_type: int = fx[3]
	
	var current_total_dice: int = side_data[Stat.OFFENCE] + side_data[Stat.DEFENCE] + side_data[Stat.MORALE]
	var allowed_val: int = min(requested_val, 8 - current_total_dice)
	
	if allowed_val <= 0:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "Resolved GAIN_SPECIFIC_DICE skipped - Already at maximum 8 dice cap."])
		return
		
	if on_event.is_valid(): 
		on_event.call("ability_triggered", [card_id, "Resolved GAIN_SPECIFIC_DICE (Allowed: %d out of %d)" % [allowed_val, requested_val]])
		
	var b_offence := 0; var b_defence := 0; var b_morale := 0
	
	if pool_type == 0:
		for d in range(allowed_val):
			match _roll_custom_die_index():
				0: b_offence += 1
				1: b_defence += 1
				2: b_morale += 1
	else:
		match pool_type:
			1: b_offence = allowed_val
			2: b_defence = allowed_val
			3: b_morale = allowed_val
			
	if on_event.is_valid(): 
		on_event.call("bonus_dice_rolled", [role, b_offence, b_defence, b_morale])
	
	side_data[Stat.OFFENCE] += b_offence
	side_data[Stat.DEFENCE] += b_defence
	side_data[Stat.MORALE] += b_morale


static func _execute_reroll(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, _card_id: int, _units_valid: bool, on_event: Callable) -> void:
	if fx[2] is Array:
		return
		
	var val: int = fx[2]
	var target_type: int = fx[1]
	
	var is_attacker := (role == "Attacker")
	var targets_self := (target_type == 0)
	
	var target_side_data: Dictionary = side_data
	var target_role := role
	if not targets_self:
		target_role = "Defender" if is_attacker else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
		
	if target_side_data.is_empty():
		return

	var icon_names := {0: "Offence", 1: "Defence", 2: "Morale"}

	for iteration in range(val):
		var o_count: int = target_side_data[Stat.OFFENCE]
		var d_count: int = target_side_data[Stat.DEFENCE]
		var m_count: int = target_side_data[Stat.MORALE]
		var total_dice: int = o_count + d_count + m_count
		
		if total_dice == 0:
			break
			
		var picked_index := randi() % total_dice
		var face_removed := -1
		
		if picked_index < o_count:
			face_removed = 0
			target_side_data[Stat.OFFENCE] -= 1
		elif picked_index < (o_count + d_count):
			face_removed = 1
			target_side_data[Stat.DEFENCE] -= 1
		else:
			face_removed = 2
			target_side_data[Stat.MORALE] -= 1
			
		var face_added := _roll_custom_die_index()
		
		match face_added:
			0: target_side_data[Stat.OFFENCE] += 1
			1: target_side_data[Stat.DEFENCE] += 1
			2: target_side_data[Stat.MORALE] += 1
			
		if on_event.is_valid():
			on_event.call("dice_rerolled_log", [target_role, icon_names[face_removed], icon_names[face_added]])


static func _execute_gain_specific_combat_token(fx: Array, token_pools: Array, _side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	if fx[2] is Array:
		return
		
	var val: int = fx[2]
	var pool_type: int = fx[3]
	
	var base_idx := 0 if role == "Attacker" else 2
	var token_idx := base_idx + (0 if pool_type == 1 else 1)
	
	var label := "Offence" if pool_type == 1 else "Defence"
	if on_event.is_valid():
		on_event.call("ability_triggered", [card_id, "Resolved GAIN_SPECIFIC_COMBAT_TOKEN (+%d %s Token)" % [val, label]])
		
	token_pools[token_idx] += val

	if on_event.is_valid():
		on_event.call("tokens_updated", [role, token_pools[base_idx], token_pools[base_idx + 1]])


static func _execute_rally(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	if fx[2] is Array:
		return
		
	var val: int = fx[2]
	if on_event.is_valid():
		on_event.call("ability_triggered", [card_id, "Resolved RALLY effect (Max Targets: %d)" % val])
		
	for rally_count in range(val):
		var target_squad: Dictionary = {}
		var target_idx: int = -1
		var highest_health: int = -1
		
		for squad in side_data["squads"]:
			for i in range(squad["alive_figures"].size()):
				var hp: int = squad["alive_figures"][i]
				if hp > 0 and squad["figures_routed"][i]:
					if hp > highest_health:
						highest_health = hp
						target_squad = squad
						target_idx = i
						
		if not target_squad.is_empty():
			target_squad["figures_routed"][target_idx] = false
			if on_event.is_valid():
				on_event.call("unit_rallied", [role, target_squad["name"], highest_health, card_id])
		else:
			break


static func _execute_destroy_for_destroy(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, units_valid: bool, on_event: Callable) -> void:
	if not units_valid:
		return

	var required_unit_types: Array = fx[5]
	var count_to_destroy: int = fx[2]
	
	var is_attacker := (role == "Attacker")
	var opponent_data: Dictionary = side_data.get("parent_state", {}).get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
	var opponent_role := "Defender" if is_attacker else "Attacker"
	
	if opponent_data.is_empty():
		return

	var self_sacrificed := 0
	var sacrificed_names: Array[String] = []
	
	# 1. Prioritized Self-Sacrifice Loop
	while self_sacrificed < count_to_destroy:
		var target_unit := _find_lowest_tier_matching_unit(side_data["squads"], required_unit_types)
		if target_unit.is_empty():
			break
			
		var squad: Dictionary = target_unit["squad"]
		var idx: int = target_unit["index"]
		
		var sac_hp: int = squad["alive_figures"][idx]
		var sac_was_routed: bool = squad["figures_routed"][idx]
		
		# Buffer friendly sacrifice names
		sacrificed_names.append(squad["name"])
		
		if self_sacrificed == 0 and on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "Executing DESTROY_FOR_DESTROY sacrifice trade!"])
		
		squad["alive_figures"][idx] = 0
		squad["figures_routed"][idx] = true
		self_sacrificed += 1
		
		if on_event.is_valid():
			on_event.call("unit_destroyed", [role, squad["name"], sac_hp, sac_was_routed])

	if self_sacrificed == 0:
		return

	var opponent_sacrificed := 0
	var victim_names: Array[String] = []
	
	# 2. Hostile Destruction Phase
	while opponent_sacrificed < count_to_destroy:
		if _count_living_units(opponent_data) == 0:
			break
			
		var victim_target := _find_lowest_tier_unit_to_destroy(opponent_data["squads"])
		if victim_target.is_empty():
			break
			
		var vic_squad: Dictionary = victim_target["squad"]
		var vic_idx: int = victim_target["index"]
		
		var vic_hp: int = vic_squad["alive_figures"][vic_idx]
		var vic_was_routed: bool = vic_squad["figures_routed"][vic_idx]
		
		# Buffer enemy victim names
		victim_names.append(vic_squad["name"])
		
		if on_event.is_valid():
			on_event.call("unit_destroyed", [opponent_role, vic_squad["name"], vic_hp, vic_was_routed])
			
		vic_squad["alive_figures"][vic_idx] = 0
		vic_squad["figures_routed"][vic_idx] = true
		opponent_sacrificed += 1

	# 3. Consolidated Summary Output Pass
	if on_event.is_valid() and not victim_names.is_empty():
		var friendly_list_string := ", ".join(sacrificed_names)
		var enemy_list_string := ", ".join(victim_names)
		on_event.call("ability_triggered", [card_id, "↳ ⚖️ Trade Complete: Sacrificed [%s] to destroy enemy [%s]!" % [friendly_list_string, enemy_list_string]])

#endregion


#region Passive Card Abilities and helpers

static func _is_routing_lethal(opp_card_id: int, card_db: Dictionary, my_state: Dictionary) -> bool:
	if not card_db.has(opp_card_id):
		return false
		
	var effects_list: Array = card_db[opp_card_id][3]
	for fx in effects_list:
		if fx[0] == CardData.EffectType.DESTROY_ON_ROUT_OR_SPEND:
			var ransom_cost: int = fx[2]
			if my_state.get(Stat.MORALE, 0) < ransom_cost:
				return true
	return false


static func _find_lethal_sacrifice_target(squads: Array, total_damage: int, round_index: int, restrict_to_unrouted: bool, is_routing_lethal: bool) -> Dictionary:
	var sacrifice_target: Dictionary = {}
	
	if round_index < 2:
		var highest_health_unit: Dictionary = _find_highest_health_living_unit(squads, restrict_to_unrouted)
		
		if not highest_health_unit.is_empty():
			var big_squad = highest_health_unit["squad"]
			var big_idx = highest_health_unit["index"]
			var big_hp = big_squad["alive_figures"][big_idx]
			
			var lowest_tier_unit: Dictionary = _find_lowest_tier_living_unit(squads, restrict_to_unrouted)
			var low_squad = lowest_tier_unit["squad"]
			var low_idx = lowest_tier_unit["index"]
			var low_hp = low_squad["alive_figures"][low_idx]
			
			var overflow_survivable = (total_damage - low_hp) < big_hp
			if is_routing_lethal:
				overflow_survivable = (total_damage - low_hp) <= 0
				
			if lowest_tier_unit["squad"] != highest_health_unit["squad"] and overflow_survivable:
				sacrifice_target = lowest_tier_unit
			else:
				sacrifice_target = highest_health_unit
	else:
		var lowest_priority: float = 9999.0
		
		for squad in squads:
			for i in range(squad["alive_figures"].size()):
				if squad["alive_figures"][i] > 0:
					if restrict_to_unrouted and squad["figures_routed"][i]:
						continue
						
					var priority: float = float(squad["morale_value"]) / float(squad["health_value"])
					
					if priority < lowest_priority:
						lowest_priority = priority
						sacrifice_target = {"squad": squad, "index": i}
					elif abs(priority - lowest_priority) < 0.001 and not sacrifice_target.is_empty():
						if squad["figures_routed"][i] and not sacrifice_target["squad"]["figures_routed"][sacrifice_target["index"]]:
							sacrifice_target = {"squad": squad, "index": i}
							
	return sacrifice_target

#endregion
