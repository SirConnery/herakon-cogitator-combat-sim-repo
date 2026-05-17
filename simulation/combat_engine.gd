extends Object
class_name SimCombatEngine

static func _roll_custom_die() -> Array[int]:
	var roll: int = randi() % 6
	match roll:
		0, 1, 2: return [1, 0, 0] # Offence
		3, 4:    return [0, 1, 0] # Defence
		_:       return [0, 0, 1] # Morale

static func run_full_match(state: Dictionary, card_db: Dictionary, on_event: Callable = Callable()) -> bool:
	var atk: Dictionary = state["attacker"]
	var def: Dictionary = state["defender"]
	
	if on_event.is_valid(): on_event.call("combat_start", [atk, def])
	
	# --- PHASE 1: INITIAL COMBAT ROLL ---
	var atk_dice_offence: int = 0
	var atk_dice_defence: int = 0
	var atk_dice_morale: int = 0
	
	var def_dice_offence: int = 0
	var def_dice_defence: int = 0
	var def_dice_morale: int = 0
	
	var atk_dice_to_roll: int = 0
	var def_dice_to_roll: int = 0
	
	for squad in atk["squads"]:
		atk_dice_to_roll += squad["alive_figures"].size() * squad["combat_value"]
	for squad in def["squads"]:
		def_dice_to_roll += squad["alive_figures"].size() * squad["combat_value"]
			
	atk_dice_to_roll = min(8, atk_dice_to_roll)
	def_dice_to_roll = min(8, def_dice_to_roll)
	
	if on_event.is_valid(): on_event.call("dice_pool_calculated", [atk_dice_to_roll, def_dice_to_roll])
	
	# Roll Attacker Dice
	for i in range(atk_dice_to_roll):
		var die: Array[int] = _roll_custom_die()
		atk_dice_offence += die[0]
		atk_dice_defence += die[1]
		atk_dice_morale += die[2]
		
	# Roll Defender Dice
	for i in range(def_dice_to_roll):
		var die: Array[int] = _roll_custom_die()
		def_dice_offence += die[0]
		def_dice_defence += die[1]
		def_dice_morale += die[2]

	# Track card-based morale icons accumulated across rounds
	var atk_card_morale: int = 0
	var def_card_morale: int = 0

	if on_event.is_valid(): 
		on_event.call("dice_rolled", ["Attacker", atk_dice_offence, atk_dice_defence, atk_dice_morale,  _calculate_current_morale(atk) + atk_dice_morale])
		on_event.call("dice_rolled", ["Defender", def_dice_offence, def_dice_defence, def_dice_morale, _calculate_current_morale(def) + def_dice_morale])

	# --- INITIAL CARD DRAW (5 CARDS EACH) ---
	atk["cards_in_hand"] = []
	def["cards_in_hand"] = []
	
	# Draw up to 5 cards for Attacker
	var atk_draw_count: int = min(5, atk["combat_deck"].size())
	for i in range(atk_draw_count):
		# drawing randomly from deck to hand, popping to remove it
		var draw_idx: int = randi() % atk["combat_deck"].size()
		atk["cards_in_hand"].append(atk["combat_deck"].pop_at(draw_idx))
		
	# Draw up to 5 cards for Defender
	var def_draw_count: int = min(5, def["combat_deck"].size())
	for i in range(def_draw_count):
		var draw_idx: int = randi() % def["combat_deck"].size()
		def["cards_in_hand"].append(def["combat_deck"].pop_at(draw_idx))

	if on_event.is_valid():
		on_event.call("cards_drawn_to_hand", [atk["cards_in_hand"], def["cards_in_hand"]])
	
	# --- INITIALIZE PERSISTENT RUNNING POOLS OUTSIDE THE LOOP ---
	# These baseline dice values are set once and will persist and grow over all 3 rounds
	var atk_offence_pool: int = atk_dice_offence
	var atk_defence_pool: int = atk_dice_defence
	
	var def_offence_pool: int = def_dice_offence
	var def_defence_pool: int = def_dice_defence
	
	# --- PHASE 2: THE 3-ROUND CARD PLAY LOOP ---
	for round_index in range(3):
		if _count_living_units(atk) == 0 or _count_living_units(def) == 0:
			if on_event.is_valid(): on_event.call("early_termination", [])
			break
		
		if on_event.is_valid(): on_event.call("round_start", [round_index])
		
		# UPDATED: Correctly logs the current, active persistent dice values at the start of each round pass
		if on_event.is_valid(): 
			on_event.call("dice_rolled", ["Attacker", atk_offence_pool, atk_defence_pool, atk_dice_morale,  _calculate_current_morale(atk) + atk_dice_morale])
			on_event.call("dice_rolled", ["Defender", def_offence_pool, def_defence_pool, def_dice_morale, _calculate_current_morale(def) + def_dice_morale])
		
		# --- SELECT & PLAY CARD FROM HAND ---
		# Pick a random card from the hand
		var atk_idx: int = randi() % atk["cards_in_hand"].size()
		var def_idx: int = randi() % def["cards_in_hand"].size()
		
		# Pop it out of the hand array
		var atk_card_id: int = atk["cards_in_hand"].pop_at(atk_idx)
		var def_card_id: int = def["cards_in_hand"].pop_at(def_idx)
		
		# Place drawn card at play area
		atk["play_area"][round_index] = atk_card_id
		def["play_area"][round_index] = def_card_id
		
		# Track timeline card icons independently for this round frame pass
		var timeline_atk_offence: int = 0
		var timeline_atk_defence: int = 0
		var timeline_atk_morale: int = 0
		
		var timeline_def_offence: int = 0
		var timeline_def_defence: int = 0
		var timeline_def_morale: int = 0
		
		# --- 1. PERSISTENT ICON EVALUATION ---
		for i in range(round_index + 1):
			var hist_atk_stats: Array = card_db[atk["play_area"][i]]
			var hist_def_stats: Array = card_db[def["play_area"][i]]
			
			timeline_atk_offence += hist_atk_stats[0]
			timeline_atk_defence += hist_atk_stats[1]
			timeline_atk_morale += hist_atk_stats[2]
			
			timeline_def_offence += hist_def_stats[0]
			timeline_def_defence += hist_def_stats[1]
			timeline_def_morale += hist_def_stats[2]

		# Package calculated totals for the ability modifier filter pass
		var local_pools = {
			"atk_offence": atk_offence_pool, 
			"atk_defence": atk_defence_pool, 
			"atk_card_morale": atk_card_morale,
			
			"def_offence": def_offence_pool, 
			"def_defence": def_defence_pool, 
			"def_card_morale": def_card_morale
		}
		
		# --- 2. DELEGATE TO INSTANT CARD ABILITY HELPERS ---
		_resolve_instant_ability(atk_card_id, card_db, local_pools, true, state, on_event)
		_resolve_instant_ability(def_card_id, card_db, local_pools, false, state, on_event)
		
		# Extract your modified counts back to the local tracking scope
		atk_offence_pool = local_pools["atk_offence"]
		atk_defence_pool = local_pools["atk_defence"]
		atk_card_morale = local_pools["atk_card_morale"]
		
		def_offence_pool = local_pools["def_offence"]
		def_defence_pool = local_pools["def_defence"]
		def_card_morale = local_pools["def_card_morale"]

		# Calculate combined values for processing execution rules
		var final_atk_offence: int = atk_offence_pool + timeline_atk_offence
		var final_atk_defence: int = atk_defence_pool + timeline_atk_defence
		
		var final_def_offence: int = def_offence_pool + timeline_def_offence
		var final_def_defence: int = def_defence_pool + timeline_def_defence

		if on_event.is_valid():
			on_event.call("pools_updated", ["Attacker", final_atk_offence, final_atk_defence])
			on_event.call("pools_updated", ["Defender", final_def_offence, final_def_defence])

		# --- ASSESS DAMAGE STEP ---
		var net_damage_to_defender: int = max(0, final_atk_offence - final_def_defence)
		var net_damage_to_attacker: int = max(0, final_def_offence - final_atk_defence)
		
		if on_event.is_valid(): on_event.call("damage_calculated", [net_damage_to_defender, net_damage_to_attacker])
		
		_apply_forbidden_stars_damage(def, net_damage_to_defender, on_event)
		_apply_forbidden_stars_damage(atk, net_damage_to_attacker, on_event)

	# --- PHASE 3: FINAL COMBAT RESOLUTION ---
	var atk_survivors: int = _count_living_units(atk)
	var def_survivors: int = _count_living_units(def)
	
	if atk_survivors > 0 and def_survivors == 0:
		if on_event.is_valid(): on_event.call("victory_wipeout", ["Attacker"])
		return true
	if def_survivors > 0 and atk_survivors == 0:
		if on_event.is_valid(): on_event.call("victory_wipeout", ["Defender"])
		return false
		
	if on_event.is_valid(): on_event.call("tiebreaker_figures", [atk_survivors, def_survivors])
	if atk_survivors != def_survivors:
		return atk_survivors > def_survivors
		
	var final_atk_morale: int = _calculate_current_morale(atk) + atk_dice_morale + atk_card_morale
	var final_def_morale: int = _calculate_current_morale(def) + def_dice_morale + def_card_morale
	
	if on_event.is_valid(): on_event.call("tiebreaker_morale", [final_atk_morale, final_def_morale])
	return final_atk_morale >= final_def_morale

static func _apply_forbidden_stars_damage(player_state: Dictionary, total_damage: int, on_event: Callable) -> void:
	var squads: Array = player_state["squads"]
	var side_name: String = player_state["name"]
	
	while total_damage > 0:
		var target: Dictionary = _find_valid_damage_target(squads)
		if target.is_empty(): break
			
		var squad: Dictionary = target["squad"]
		var idx: int = target["index"]
		
		if squad["figures_routed"][idx]:
			if total_damage >= squad["health_value"]:
				if on_event.is_valid(): on_event.call("unit_destroyed", [side_name, squad["name"], squad["health_value"], true])
				total_damage -= squad["health_value"]
				squad["alive_figures"][idx] = 0
			else:
				if on_event.is_valid(): on_event.call("damage_absorbed", [side_name, squad["name"], total_damage, true])
				total_damage = 0
		else:
			if total_damage >= squad["health_value"]:
				if on_event.is_valid(): on_event.call("unit_destroyed", [side_name, squad["name"], squad["health_value"], false])
				total_damage -= squad["health_value"]
				squad["alive_figures"][idx] = 0
				squad["figures_routed"][idx] = true
			else:
				if on_event.is_valid(): on_event.call("unit_routed", [side_name, squad["name"], total_damage])
				squad["figures_routed"][idx] = true
				total_damage = 0

static func _find_valid_damage_target(squads: Array) -> Dictionary:
	var routed_fallback: Dictionary = {}
	for squad in squads:
		for i in range(squad["alive_figures"].size()):
			if squad["alive_figures"][i] > 0:
				if not squad["figures_routed"][i]:
					return {"squad": squad, "index": i}
				elif routed_fallback.is_empty():
					routed_fallback = {"squad": squad, "index": i}
	return routed_fallback

static func _count_living_units(player_state: Dictionary) -> int:
	var count: int = 0
	for squad in player_state["squads"]:
		for hp in squad["alive_figures"]:
			if hp > 0: count += 1
	return count

static func _calculate_current_morale(player_state: Dictionary) -> int:
	var total: int = 0
	for squad in player_state["squads"]:
		for i in range(squad["alive_figures"].size()):
			if squad["alive_figures"][i] > 0 and not squad["figures_routed"][i]:
				total += squad["morale_value"]
	return total


#region CardAbilities

static func _resolve_instant_ability(active_card_id: int, card_db: Dictionary, running_pools: Dictionary, is_attacker: bool, state: Dictionary, on_event: Callable) -> void:
	var active_stats: Array = card_db[active_card_id]
	var effects_list: Array = active_stats[3]
	if effects_list.is_empty():
		return
		
	var role_label := "Attacker" if is_attacker else "Defender"
	var side_data: Dictionary = state["attacker"] if is_attacker else state["defender"]
	
	var general_phase_started := false
	var unit_phase_started := false
	var unit_requirement_failed := false
	
	# Loop through every packed sub-array ability block sequentially
	for fx in effects_list:
		var source_type: int = fx[4] if fx.size() > 4 else 0 
		var req_unit_types: Array = fx[5] if fx.size() > 5 else [] # Index 5 is now an Array
		
		# --- CONDITION VALIDATION FOR UNIT ABILITIES ---
		if source_type == 1:
			if unit_requirement_failed:
				continue
				
			var has_valid_unit := false
			
			# If the requirement list is completely empty, it passes automatically
			if req_unit_types.is_empty():
				has_valid_unit = true
			else:
				# Scan our live squads to see if at least one matches ANY allowed requirement type
				for squad in side_data["squads"]:
					# Using .get() safely returns a default fallback value (like -1) if the key is missing instead of crashing
					var squad_unit_type: int = squad.get("unit_type", -1)
					
					if squad_unit_type in req_unit_types:
						if squad["alive_figures"].size() > 0 and not squad.get("is_routed", false):
							has_valid_unit = true
							break # Found a valid unrouted unit, break squad check loop!
			
			if not has_valid_unit:
				unit_requirement_failed = true
				if on_event.is_valid():
					on_event.call("ability_failed_requirements", [role_label, active_card_id, req_unit_types])
				continue
		
		var effect_type: int = fx[0] 
		var target_type: int = fx[1] 
		var value: int       = fx[2] 
		var pool_type: int   = fx[3] if fx.size() > 3 else 0
		
		# --- PHASE BOUNDARY: GENERAL ABILITY BLOCK START ---
		if source_type == 0 and not general_phase_started:
			general_phase_started = true
			if on_event.is_valid():
				on_event.call("ability_block_started", [role_label, "General"])
				
		# --- PHASE BOUNDARY: UNIT ABILITY BLOCK START ---
		elif source_type == 1 and not unit_phase_started:
			unit_phase_started = true
			if on_event.is_valid():
				on_event.call("ability_block_started", [role_label, "Unit"])
		
		# Set up target destination prefixes
		var target_is_attacker := is_attacker if target_type == 0 else not is_attacker
		var target_prefix := "atk_" if target_is_attacker else "def_"
		
		# --- ABILITY TYPE 1: GAIN_DICE ---
		if effect_type == 1: 
			if on_event.is_valid(): 
				on_event.call("ability_triggered", [active_card_id, "Resolved GAIN_DICE (Count: %d)" % value])            
			
			var bonus_offence: int = 0
			var bonus_defence: int = 0
			var bonus_morale: int = 0
			
			for d in range(value):
				var die: Array[int] = _roll_custom_die()
				bonus_offence += die[0]
				bonus_defence += die[1]
				bonus_morale += die[2]
			
			if on_event.is_valid():
				on_event.call("bonus_dice_rolled", [role_label, bonus_offence, bonus_defence, bonus_morale])
			
			running_pools[target_prefix + "offence"] += bonus_offence
			running_pools[target_prefix + "defence"] += bonus_defence
			running_pools[target_prefix + "card_morale"] += bonus_morale
			
		# --- ABILITY TYPE 2: GAIN_SPECIFIC_DICE ---
		elif effect_type == 2: 
			if on_event.is_valid(): 
				on_event.call("ability_triggered", [active_card_id, "Resolved GAIN_SPECIFIC_DICE (Count: %d)" % value])
			
			var bonus_offence: int = 0
			var bonus_defence: int = 0
			var bonus_morale: int = 0
			
			if pool_type == 0: 
				for d in range(value):
					var die: Array[int] = _roll_custom_die()
					bonus_offence += die[0]
					bonus_defence += die[1]
					bonus_morale += die[2]
			else:
				match pool_type:
					1: bonus_offence = value 
					2: bonus_defence = value 
					3: bonus_morale = value  
					
			if on_event.is_valid():
				on_event.call("bonus_dice_rolled", [role_label, bonus_offence, bonus_defence, bonus_morale])
				
			running_pools[target_prefix + "offence"] += bonus_offence
			running_pools[target_prefix + "defence"] += bonus_defence
			running_pools[target_prefix + "card_morale"] += bonus_morale
