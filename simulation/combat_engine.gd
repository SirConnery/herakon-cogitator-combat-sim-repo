extends Object
class_name SimCombatEngine

static func _roll_custom_die_index() -> int:
	var roll: int = randi() % 6
	if roll <= 2:   return 0 # Offence
	elif roll <= 4: return 1 # Defence
	return 2                 # Morale

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

	# Track card-based morale icons accumulated across rounds from text abilities
	var atk_card_morale: int = 0
	var def_card_morale: int = 0

	# --- INITIAL POOL CONTEXT ASSIGNMENT ---
	var atk_offence_pool: int = atk_dice_offence
	var atk_defence_pool: int = atk_dice_defence
	
	var def_offence_pool: int = def_dice_offence
	var def_defence_pool: int = def_dice_defence

	if on_event.is_valid(): 
		var atk_morale_from_units: int = _calculate_current_morale_from_units(atk)
		var def_morale_from_units: int = _calculate_current_morale_from_units(def)
		on_event.call("dice_rolled", ["Attacker", atk_offence_pool, atk_defence_pool, atk_dice_morale, atk_morale_from_units])
		on_event.call("dice_rolled", ["Defender", def_offence_pool, def_defence_pool, def_dice_morale, def_morale_from_units])

	# --- INITIAL CARD DRAW (5 CARDS EACH) ---
	atk["cards_in_hand"] = []
	def["cards_in_hand"] = []
	
	var atk_draw_count: int = min(5, atk["combat_deck"].size())
	for i in range(atk_draw_count):
		var draw_idx: int = randi() % atk["combat_deck"].size()
		atk["cards_in_hand"].append(atk["combat_deck"].pop_at(draw_idx))
		
	var def_draw_count: int = min(5, def["combat_deck"].size())
	for i in range(def_draw_count):
		var draw_idx: int = randi() % def["combat_deck"].size()
		def["cards_in_hand"].append(def["combat_deck"].pop_at(draw_idx))

	if on_event.is_valid():
		on_event.call("cards_drawn_to_hand", [atk["cards_in_hand"], def["cards_in_hand"]])
	
	# --- PHASE 2: THE 3-ROUND CARD PLAY LOOP ---
	for round_index in range(3):
		if _count_living_units(atk) == 0 or _count_living_units(def) == 0:
			if on_event.is_valid(): on_event.call("early_termination", [])
			break
		
		if on_event.is_valid(): 
			on_event.call("round_start", [round_index])
			
			# Streamlined helper call replaces old nested diagnostic layout loop
			log_current_army_statuses(state, on_event)
			
			var current_atk_overall: int = _calculate_current_morale_from_units(atk) + atk_dice_morale + atk_card_morale
			var current_def_overall: int = _calculate_current_morale_from_units(def) + def_dice_morale + def_card_morale
			
			on_event.call("dice_rolled", ["Attacker", atk_offence_pool, atk_defence_pool, (atk_dice_morale + atk_card_morale), current_atk_overall])
			on_event.call("dice_rolled", ["Defender", def_offence_pool, def_defence_pool, (def_dice_morale + def_card_morale), current_def_overall])
			
		# --- SELECT & PLAY CARD FROM HAND ---
		var atk_idx: int = randi() % atk["cards_in_hand"].size()
		var def_idx: int = randi() % def["cards_in_hand"].size()
		
		var atk_card_id: int = atk["cards_in_hand"].pop_at(atk_idx)
		var def_card_id: int = def["cards_in_hand"].pop_at(def_idx)
		
		atk["play_area"][round_index] = atk_card_id
		def["play_area"][round_index] = def_card_id
		
		# --- TIMELINE ICON SEPARATION ---
		var timeline_atk_offence: int = 0
		var timeline_atk_defence: int = 0
		var printed_atk_card_morale: int = 0
		
		var timeline_def_offence: int = 0
		var timeline_def_defence: int = 0
		var printed_def_card_morale: int = 0
		
		for i in range(round_index + 1):
			var hist_atk_stats: Array = card_db[atk["play_area"][i]]
			var hist_def_stats: Array = card_db[def["play_area"][i]]
			
			timeline_atk_offence += hist_atk_stats[0]
			timeline_atk_defence += hist_atk_stats[1]
			printed_atk_card_morale += hist_atk_stats[2]
			
			timeline_def_offence += hist_def_stats[0]
			timeline_def_defence += hist_def_stats[1]
			printed_def_card_morale += hist_def_stats[2]
		
		if on_event.is_valid():
			on_event.call("card_icons_calculated", ["Attacker", timeline_atk_offence, timeline_atk_defence, printed_atk_card_morale])
			on_event.call("card_icons_calculated", ["Defender", timeline_def_offence, timeline_def_defence, printed_def_card_morale])
		
		# Package dice pools safely for text capability modifications
		var local_pools = {
			"atk_offence": atk_offence_pool, 
			"atk_defence": atk_defence_pool, 
			"atk_card_morale": atk_card_morale,
			"atk_token_offence": 0, 
			"atk_token_defence": 0,
			
			"def_offence": def_offence_pool, 
			"def_defence": def_defence_pool, 
			"def_card_morale": def_card_morale,
			"def_token_offence": 0, 
			"def_token_defence": 0
		}
		
		# Assign cross-referencing pointers so abilities can trace targets securely
		atk["parent_state"] = state
		def["parent_state"] = state
		
		# --- RESOLVE CARD TEXT ABILITIES (INSTANT WINDOW) ---
		_resolve_instant_ability(atk_card_id, card_db, local_pools, true, state, on_event)
		_resolve_instant_ability(def_card_id, card_db, local_pools, false, state, on_event)
		
		# Clean up tracking references to prevent memory leaks
		atk.erase("parent_state")
		def.erase("parent_state")
		
		# Extract text modifications back into persistent arrays
		atk_offence_pool = local_pools["atk_offence"]
		atk_defence_pool = local_pools["atk_defence"]
		atk_card_morale = local_pools["atk_card_morale"]
		
		def_offence_pool = local_pools["def_offence"]
		def_defence_pool = local_pools["def_defence"]
		def_card_morale = local_pools["def_card_morale"]

		# --- MUTABLE TIMELINE CONTEXT EVALUATION ---
		var context = {
			"atk_offence": atk_offence_pool + timeline_atk_offence + local_pools["atk_token_offence"],
			"atk_defence": atk_defence_pool + timeline_atk_defence + local_pools["atk_token_defence"],
			"def_offence": def_offence_pool + timeline_def_offence + local_pools["def_token_offence"],
			"def_defence": def_defence_pool + timeline_def_defence + local_pools["def_token_defence"],
			"net_damage_to_attacker": 0,
			"net_damage_to_defender": 0
		}

		# --- HOOK FRAME A: BEFORE DAMAGE ASSESSMENT (POOL MODIFIERS) ---
		_execute_timing_hook(CardData.TimingWindow.BEFORE_DAMAGE, state, context, round_index)

		if on_event.is_valid():
			on_event.call("pools_updated", ["Attacker", context["atk_offence"], context["atk_defence"]])
			on_event.call("pools_updated", ["Defender", context["def_offence"], context["def_defence"]])

		# --- RAW DELTA CALCULATION STEP ---
		context["net_damage_to_defender"] = max(0, context["atk_offence"] - context["def_defence"])
		context["net_damage_to_attacker"] = max(0, context["def_offence"] - context["atk_defence"])
		
		# --- HOOK FRAME B: DURING DAMAGE ASSESSMENT (DAMAGE MUTATORS) ---
		_execute_timing_hook(CardData.TimingWindow.DURING_DAMAGE, state, context, round_index)
		
		if on_event.is_valid(): 
			on_event.call("damage_calculated", [context["net_damage_to_defender"], context["net_damage_to_attacker"]])
		
		# --- APPLY RESOLVED PAYLOAD TARGET DAMAGE TO UNITS ---
		apply_damage(def, context["net_damage_to_defender"], round_index, on_event)
		apply_damage(atk, context["net_damage_to_attacker"], round_index, on_event)

		# --- HOOK FRAME C: AFTER DAMAGE ASSESSMENT (POST-COMBAT REACTIONS) ---
		_execute_timing_hook(CardData.TimingWindow.AFTER_DAMAGE, state, context, round_index)

	# --- PHASE 3: FINAL COMBAT RESOLUTION ---
	var atk_survivors: int = _count_living_units(atk)
	var def_survivors: int = _count_living_units(def)
	
	if atk_survivors > 0 and def_survivors == 0:
		if on_event.is_valid(): 
			on_event.call("victory_by_wipeout", ["Attacker"])
			log_current_army_statuses(state, on_event)
		return true
	if def_survivors > 0 and atk_survivors == 0:
		if on_event.is_valid(): 
			on_event.call("victory_by_wipeout", ["Defender"])
			log_current_army_statuses(state, on_event)
		return false
		
	if atk_survivors != def_survivors:
		if on_event.is_valid(): log_current_army_statuses(state, on_event)
		return atk_survivors > def_survivors
		
	# --- TIEBREAKER MORALE EVALUATION ---
	var final_printed_atk_morale: int = 0
	var final_printed_def_morale: int = 0
	
	for i in range(3):
		if atk["play_area"][i] in card_db:
			final_printed_atk_morale += card_db[atk["play_area"][i]][2]
		if def["play_area"][i] in card_db:
			final_printed_def_morale += card_db[def["play_area"][i]][2]
	
	var final_atk_morale: int = _calculate_current_morale_from_units(atk) + atk_dice_morale + atk_card_morale + final_printed_atk_morale
	var final_def_morale: int = _calculate_current_morale_from_units(def) + def_dice_morale + def_card_morale + final_printed_def_morale
	
	if on_event.is_valid(): 
		on_event.call("tiebreaker_morale", [final_atk_morale, final_def_morale])
		log_current_army_statuses(state, on_event)
		
	return final_atk_morale >= final_def_morale


static func apply_damage(player_state: Dictionary, total_damage: int, round_index: int, on_event: Callable) -> void:
	var squads: Array = player_state["squads"]
	var side_name: String = player_state["name"]
	
	while total_damage > 0:
		# --- ROUTING & SURVIVOR PROTECTION CHECK ---
		# Combined into a single fast pass to avoid executing heavy sub-lookups
		# when the army is already completely eliminated.
		var has_unrouted_units: bool = false
		var has_any_living_units: bool = false
		
		for squad in squads:
			for i in range(squad["alive_figures"].size()):
				if squad["alive_figures"][i] > 0:
					has_any_living_units = true
					if not squad["figures_routed"][i]:
						has_unrouted_units = true
		
		# High-speed escape hatch for production loop performance
		if not has_any_living_units:
			total_damage = 0
			break

		# --------------------------------------------------
		# STEP 1: PERFECT ABSORPTION (0 DEATHS STRATEGY)
		# --------------------------------------------------
		var perfect_target: Dictionary = {}
		var smallest_surviving_hp: int = 9999
		
		for squad in squads:
			for i in range(squad["alive_figures"].size()):
				if squad["alive_figures"][i] > 0:
					if has_unrouted_units and squad["figures_routed"][i]:
						continue
						
					var hp_left = squad["alive_figures"][i]
					if total_damage < hp_left and hp_left < smallest_surviving_hp:
						smallest_surviving_hp = hp_left
						perfect_target = {"squad": squad, "index": i}
						
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
				
			target_squad["alive_figures"][target_idx] -= total_damage
			total_damage = 0
			break

		# --------------------------------------------------
		# STEP 2: LETHAL DAMAGE FALLBACKS
		# --------------------------------------------------
		var sacrifice_target: Dictionary = {}
		
		if round_index < 2:
			# ==================================================
			# ROUNDS 1-2: ASSET SURVIVAL MODE
			# ==================================================
			var highest_health_unit: Dictionary = _find_highest_health_living_unit(squads, has_unrouted_units)
			
			if not highest_health_unit.is_empty():
				var big_squad = highest_health_unit["squad"]
				var big_idx = highest_health_unit["index"]
				var big_hp = big_squad["alive_figures"][big_idx]
				
				var lowest_tier_unit: Dictionary = _find_lowest_tier_living_unit(squads, has_unrouted_units)
				var low_squad = lowest_tier_unit["squad"]
				var low_idx = lowest_tier_unit["index"]
				var low_hp = low_squad["alive_figures"][low_idx]
				
				if lowest_tier_unit["squad"] != highest_health_unit["squad"] and (total_damage - low_hp) < big_hp:
					sacrifice_target = lowest_tier_unit
				else:
					sacrifice_target = highest_health_unit
		else:
			# ==================================================
			# ROUND 3: ENDGAME TIEBREAKER PRESERVATION MODE
			# ==================================================
			var lowest_priority: float = 9999.0
			
			for squad in squads:
				for i in range(squad["alive_figures"].size()):
					if squad["alive_figures"][i] > 0:
						if has_unrouted_units and squad["figures_routed"][i]:
							continue
							
						var priority: float = float(squad["morale_value"]) / float(squad["health_value"])
						
						if priority < lowest_priority:
							lowest_priority = priority
							sacrifice_target = {"squad": squad, "index": i}
						elif abs(priority - lowest_priority) < 0.001 and not sacrifice_target.is_empty():
							if squad["figures_routed"][i] and not sacrifice_target["squad"]["figures_routed"][sacrifice_target["index"]]:
								sacrifice_target = {"squad": squad, "index": i}

		if sacrifice_target.is_empty():
			total_damage = 0
			break
			
		var final_squad: Dictionary = sacrifice_target["squad"]
		var final_idx: int = sacrifice_target["index"]
		var final_was_routed: bool = final_squad["figures_routed"][final_idx]
		var hp_to_kill: int = final_squad["alive_figures"][final_idx]
		
		if on_event.is_valid():
			on_event.call("unit_destroyed", [side_name, final_squad["name"], hp_to_kill, final_was_routed])
			
		total_damage -= hp_to_kill
		final_squad["alive_figures"][final_idx] = 0
		final_squad["figures_routed"][final_idx] = true


#region Helper Functions

static func _find_highest_health_living_unit(squads: Array, restrict_to_unrouted: bool) -> Dictionary:
	var target: Dictionary = {}
	var max_hp: int = -1
	
	for squad in squads:
		for i in range(squad["alive_figures"].size()):
			if squad["alive_figures"][i] > 0:
				# Rule restriction: Skip if we are targeting unrouted only, but this guy is routed
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
					# Rule restriction: Skip if we are targeting unrouted only, but this guy is routed
					if restrict_to_unrouted and squad["figures_routed"][i]:
						continue
						
					lowest_tier = squad["tier"]
					target = {"squad": squad, "index": i}
					break 
	return target

static func _find_lowest_tier_unit_to_destroy(squads: Array) -> Dictionary:
	var target: Dictionary = {}
	var lowest_tier: int = 9999
	
	# --- PASS 1: SEARCH FOR ROUTED UNITS FIRST (VULNERABLE TARGETS) ---
	for squad in squads:
		for i in range(squad["alive_figures"].size()):
			if squad["alive_figures"][i] > 0 and squad["figures_routed"][i]:
				if squad["tier"] < lowest_tier:
					lowest_tier = squad["tier"]
					target = {"squad": squad, "index": i}
	
	# If we found a routed unit, return it immediately!
	if not target.is_empty():
		return target
		
	# --- PASS 2: FALLBACK TO ANY LIVING UNIT (NO ROUTED UNITS EXIST) ---
	lowest_tier = 9999
	for squad in squads:
		for i in range(squad["alive_figures"].size()):
			if squad["alive_figures"][i] > 0:
				if squad["tier"] < lowest_tier:
					lowest_tier = squad["tier"]
					target = {"squad": squad, "index": i}
					
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

static func log_current_army_statuses(state: Dictionary, on_event: Callable) -> void:
	if not on_event.is_valid():
		return
		
	var sides = [state["attacker"], state["defender"]]
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
		
		on_event.call("unit_status_logged", [side_name, unrouted_str, routed_str])


static func _execute_timing_hook(window: CardData.TimingWindow, state: Dictionary, context: Dictionary, round_index: int) -> void:
	# Right now, this remains an empty, lightning-fast pass.
	# Future phase: Process cards in the play_area matching this window profile.
	pass

#endregion

#region CardAbilities
# ==============================================================================
# CARD ABILITY RESOLUTION SYSTEM (FUNCTION-POINTER LOOKUP ARCHITECTURE)
# ==============================================================================

# High-speed static O(1) integer-key lookup map for atomic card text actions
static var EFFECT_RESOLVERS = {
	# Any multi-choice card routes through here first!
	CardData.EffectType.CHOICE: _execute_choice_selection,
	
	# Generic effects
	CardData.EffectType.GAIN_DICE: _execute_gain_dice,
	CardData.EffectType.GAIN_SPECIFIC_DICE: _execute_gain_specific_dice,
	CardData.EffectType.REROLL: _execute_reroll,
	CardData.EffectType.GAIN_SPECIFIC_COMBAT_TOKEN: _execute_gain_specific_combat_token,
	
	CardData.EffectType.RALLY: _execute_rally, 
	CardData.EffectType.DESTROY_FOR_DESTROY: _execute_destroy_for_destroy,
}

static func _resolve_instant_ability(active_card_id: int, card_db: Dictionary, running_pools: Dictionary, is_attacker: bool, state: Dictionary, on_event: Callable) -> void:
	var card_data: Array = card_db[active_card_id]
	var effects_list: Array = card_data[3]
	if effects_list.is_empty():
		return
		
	var role_label := "Attacker" if is_attacker else "Defender"
	var side_data: Dictionary = state["attacker"] if is_attacker else state["defender"]
	
	var general_phase_started := false
	var unit_phase_started := false
	
	for fx in effects_list:
		var is_unit_fx: bool = (fx[4] == 1)
		
		# --- PHASE BOUNDARY LOGGING ---
		if not is_unit_fx and not general_phase_started:
			general_phase_started = true
			if on_event.is_valid(): on_event.call("ability_block_started", [role_label, "General"])
		elif is_unit_fx and not unit_phase_started:
			unit_phase_started = true
			if on_event.is_valid(): on_event.call("ability_block_started", [role_label, "Unit"])

		# --- REQUIREMENT VALIDATION ---
		if is_unit_fx:
			var req_unit: int = fx[5]
			if req_unit != 0 and not _has_active_unit_type(side_data, req_unit):
				if on_event.is_valid():
					on_event.call("unit_ability_not_resolved", [role_label, active_card_id, [req_unit]])
				continue
		
		# --- LOOKUP TABLE ROUTING ---
		var effect_type: int = fx[0]
		if EFFECT_RESOLVERS.has(effect_type):
			EFFECT_RESOLVERS[effect_type].call(fx, running_pools, side_data, role_label, active_card_id, on_event)
		else:
			print("    -> ⚠️ Engine skipped unresolved effect type code (%d) - check your map." % effect_type)

# --- Shared Validation Helpers ---

static func _has_active_unit_type(side_data: Dictionary, required_type: int) -> bool:
	for squad in side_data["squads"]:
		if int(squad.get("unit_type", -1)) == required_type:
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

static func _has_reached_max_dice(pools: Dictionary, prefix: String) -> bool:
	var side_dice: int = pools[prefix + "offence"] + pools[prefix + "defence"] + pools[prefix + "card_morale"]
	return side_dice >= 8

# ==============================================================================
# ATOMIC MECHANIC RESOLVERS
# ==============================================================================

static func _execute_choice_selection(fx: Array, pools: Dictionary, side_data: Dictionary, role: String, card_id: int, on_event: Callable) -> void:
	var options = fx[2]
	if not options is Array or options.is_empty():
		print("    -> ❌ CHOICE BUG: Index 2 is not an array! Current value: ", options)
		return
		
	var prefix := "atk_" if role == "Attacker" else "def_"
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
				if not _has_reached_max_dice(pools, prefix):
					valid_options.append(sub_fx)
			_:
				valid_options.append(sub_fx)
				
	var final_pool: Array = valid_options if not valid_options.is_empty() else options
	var rolled_index := randi() % final_pool.size()
	
	# DEEP COPY CLONE: Use true to force a deep recursive duplication of all nested elements
	var chosen_sub_fx = final_pool[rolled_index].duplicate(true)
	
	if not chosen_sub_fx is Array or chosen_sub_fx.is_empty():
		return
		
	var sub_effect_type: int = chosen_sub_fx[0]
	if EFFECT_RESOLVERS.has(sub_effect_type):
		EFFECT_RESOLVERS[sub_effect_type].call(chosen_sub_fx, pools, side_data, role, card_id, on_event)

static func _execute_gain_dice(fx: Array, pools: Dictionary, _side_data: Dictionary, role: String, card_id: int, on_event: Callable) -> void:
	if fx[2] is Array:
		push_error("Engine Leak Caught: GAIN_DICE received an Array instead of an int for Card #%d. Skipping execution to prevent crash." % card_id)
		return
		
	var val: int = fx[2]
	var prefix := "atk_" if role == "Attacker" else "def_"
	
	if on_event.is_valid(): 
		on_event.call("ability_triggered", [card_id, "Resolved GAIN_DICE (Count: %d)" % val])
	
	var b_offence := 0; var b_defence := 0; var b_morale := 0
	for d in range(val):
		match _roll_custom_die_index():
			0: b_offence += 1
			1: b_defence += 1
			2: b_morale += 1
		
	if on_event.is_valid(): 
		on_event.call("bonus_dice_rolled", [role, b_offence, b_defence, b_morale])
	
	pools[prefix + "offence"] += b_offence
	pools[prefix + "defence"] += b_defence
	pools[prefix + "card_morale"] += b_morale


static func _execute_gain_specific_dice(fx: Array, pools: Dictionary, _side_data: Dictionary, role: String, card_id: int, on_event: Callable) -> void:
	if fx[2] is Array:
		push_error("Engine Leak Caught: GAIN_SPECIFIC_DICE received an Array instead of an int for Card #%d. Skipping execution to prevent crash." % card_id)
		return
		
	var val: int = fx[2]
	var pool_type: int = fx[3]
	var prefix := "atk_" if role == "Attacker" else "def_"
	
	if on_event.is_valid(): 
		on_event.call("ability_triggered", [card_id, "Resolved GAIN_SPECIFIC_DICE (Count: %d)" % val])
		
	var b_offence := 0; var b_defence := 0; var b_morale := 0
	
	if pool_type == 0: # 0 means roll standard random custom dice
		for d in range(val):
			match _roll_custom_die_index():
				0: b_offence += 1
				1: b_defence += 1
				2: b_morale += 1
	else:
		# Directly grant guaranteed icons based on the configuration layout
		match pool_type:
			1: b_offence = val  # CardData.DicePoolType.OFFENSE
			2: b_defence = val  # CardData.DicePoolType.DEFENSE
			3: b_morale = val   # CardData.DicePoolType.MORALE
			
	if on_event.is_valid(): 
		on_event.call("bonus_dice_rolled", [role, b_offence, b_defence, b_morale])
	
	pools[prefix + "offence"] += b_offence
	pools[prefix + "defence"] += b_defence
	pools[prefix + "card_morale"] += b_morale

static func _execute_reroll(fx: Array, pools: Dictionary, _side_data: Dictionary, role: String, card_id: int, on_event: Callable) -> void:
	if fx[2] is Array:
		push_error("Engine Leak Caught: _execute_reroll received an Array value for Card #%d." % card_id)
		return
		
	var val: int = fx[2]
	var target_type: int = fx[1] # CardData.TargetType.SELF vs OPPONENT
	
	# Route target prefix safely based on who is casting and who is targeted
	var is_attacker := (role == "Attacker")
	var targets_self := (target_type == 0) # Assumes 0 is SELF, adjust to your enum if needed
	var target_role := role if targets_self else ("Defender" if is_attacker else "Attacker")
	var prefix := "atk_" if target_role == "Attacker" else "def_"

	var icon_names := {0: "Offence", 1: "Defence", 2: "Morale"}

	for iteration in range(val):
		# Gather the current sizes of their pools
		var o_count: int = pools[prefix + "offence"]
		var d_count: int = pools[prefix + "defence"]
		var m_count: int = pools[prefix + "card_morale"]
		var total_dice: int = o_count + d_count + m_count
		
		# If they have completely empty pools, nothing can be picked to reroll
		if total_dice == 0:
			break
			
		# Pick a random die index from their total pool
		var picked_index := randi() % total_dice
		var face_removed := -1
		
		# Determine which pool that random index landed in and deduct it
		if picked_index < o_count:
			face_removed = 0
			pools[prefix + "offence"] -= 1
		elif picked_index < (o_count + d_count):
			face_removed = 1
			pools[prefix + "defence"] -= 1
		else:
			face_removed = 2
			pools[prefix + "card_morale"] -= 1
			
		# --- ROLL FRESH FACE ---
		var face_added := _roll_custom_die_index()
		
		match face_added:
			0: pools[prefix + "offence"] += 1
			1: pools[prefix + "defence"] += 1
			2: pools[prefix + "card_morale"] += 1
			
		# --- LOG HIGH-FIDELITY RESULTS ---
		if on_event.is_valid():
			on_event.call("dice_rerolled", [
				target_role, 
				icon_names[face_removed], 
				icon_names[face_added]
			])

static func _execute_gain_specific_combat_token(fx: Array, pools: Dictionary, _side_data: Dictionary, role: String, card_id: int, on_event: Callable) -> void:
	if fx[2] is Array:
		push_error("Engine Leak Caught: GAIN_SPECIFIC_COMBAT_TOKEN received an Array value for Card #%d." % card_id)
		return
		
	var val: int = fx[2]
	var pool_type: int = fx[3] # Expects CardData.DicePoolType values
	var prefix := "atk_token_" if role == "Attacker" else "def_token_"
	
	var label := "Offence" if pool_type == 1 else "Defence"
	if on_event.is_valid():
		on_event.call("ability_triggered", [card_id, "Resolved GAIN_SPECIFIC_COMBAT_TOKEN (+%d %s Token)" % [val, label]])
		
	match pool_type:
		1: # CardData.DicePoolType.OFFENSE
			pools[prefix + "offence"] += val
		2: # CardData.DicePoolType.DEFENSE
			pools[prefix + "defence"] += val
		_:
			print("  -> ⚠️ Engine skipped non-combat token pool specification mapping type: %d" % pool_type)

static func _execute_rally(fx: Array, _pools: Dictionary, side_data: Dictionary, role: String, card_id: int, on_event: Callable) -> void:
	# DEFENSIVE TYPE GUARD: If layout pollution passes the master Choice block here, bypass the crash
	if fx[2] is Array:
		push_error("Engine Leak Caught: _execute_rally received an Array instead of an int for Card #%d. Skipping to prevent crash." % card_id)
		return
		
	var val: int = fx[2]
	
	if on_event.is_valid():
		on_event.call("ability_triggered", [card_id, "Resolved RALLY effect (Max Targets: %d)" % val])
		
	for rally_count in range(val):
		var target_squad: Dictionary = {}
		var target_idx: int = -1
		var highest_health: int = -1
		
		# --- SCAN FOR THE HIGHEST HEALTH ROUTED UNIT ---
		for squad in side_data["squads"]:
			for i in range(squad["alive_figures"].size()):
				var hp: int = squad["alive_figures"][i]
				if hp > 0 and squad["figures_routed"][i]:
					if hp > highest_health:
						highest_health = hp
						target_squad = squad
						target_idx = i
						
		# --- EXECUTE THE RALLY ACTION IF A TARGET WAS FOUND ---
		if not target_squad.is_empty():
			target_squad["figures_routed"][target_idx] = false
			
			if on_event.is_valid():
				on_event.call("unit_rallied", [role, target_squad["name"], highest_health, card_id])
		else:
			if on_event.is_valid() and rally_count == 0:
				on_event.call("rally_skipped", [role, card_id])
			break

static func _execute_destroy_for_destroy(fx: Array, _pools: Dictionary, side_data: Dictionary, role: String, card_id: int, on_event: Callable) -> void:
	# fx array indices map to: [effect_type, target_type, value, pool_type, is_unit_fx, req_unit]
	var required_unit_type: int = fx[5]
	var count_to_destroy: int = fx[2]
	
	# Determine opponent data targeting paths
	var is_attacker := (role == "Attacker")
	var opponent_data: Dictionary = side_data.get("parent_state", {}).get("defender" if is_attacker else "attacker", {})
	var opponent_role := "Defender" if is_attacker else "Attacker"
	
	if opponent_data.is_empty():
		push_error("Engine Resolution Fail: DESTROY_FOR_DESTROY failed to locate opponent handle state structure.")
		return

	if on_event.is_valid():
		on_event.call("ability_triggered", [card_id, "Executing DESTROY_FOR_DESTROY sacrifice trade!"])

	# --- PART 1: CONSUME SELF SACRIFICE COST ---
	var self_sacrificed := 0
	for squad in side_data["squads"]:
		if int(squad.get("unit_type", -1)) == required_unit_type:
			for i in range(squad["alive_figures"].size()):
				if squad["alive_figures"][i] > 0 and not squad["figures_routed"][i]:
					# Terminate the asset immediately to pay the ability activation toll
					squad["alive_figures"][i] = 0
					squad["figures_routed"][i] = true
					self_sacrificed += 1
					
					if on_event.is_valid():
						on_event.call("unit_destroyed", [role, squad["name"], 0, false])
					break
			if self_sacrificed >= count_to_destroy:
				break

	# Security check: If we somehow couldn't find our own unit to kill, abort the trade penalty
	if self_sacrificed == 0:
		return

	# --- PART 2: FORCE OPPONENT SACRIFICE PENALTY ---
	var opponent_sacrificed := 0
	while opponent_sacrificed < count_to_destroy:
		# Leverage our rule-compliant routed-first targeting algorithm
		var victim_target := _find_lowest_tier_unit_to_destroy(opponent_data["squads"])
		
		# If the opponent has completely zero assets left alive, break execution loop
		if victim_target.is_empty():
			break
			
		var vic_squad: Dictionary = victim_target["squad"]
		var vic_idx: int = victim_target["index"]
		var vic_was_routed: bool = vic_squad["figures_routed"][vic_idx]
		
		if on_event.is_valid():
			on_event.call("unit_destroyed", [
				opponent_role, 
				vic_squad["name"], 
				vic_squad["alive_figures"][vic_idx], 
				vic_was_routed
			])
			
		# Deliver instant fatal payload execution
		vic_squad["alive_figures"][vic_idx] = 0
		vic_squad["figures_routed"][vic_idx] = true
		opponent_sacrificed += 1
