extends Object
class_name SimCombatEngine

static func _roll_custom_die_index() -> int:
	var roll: int = randi() % 6
	if roll <= 2:   return 0 # Offence
	elif roll <= 4: return 1 # Defence
	return 2                 # Morale

#region Main Loop

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

	# Stash base rolled morale values directly onto the root actors so intercepts can find them
	atk["dice_morale"] = atk_dice_morale
	def["dice_morale"] = def_dice_morale

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
			
			log_current_army_statuses(state, on_event)
			
			var current_atk_overall: int = _calculate_current_morale_from_units(atk) + atk["dice_morale"] + atk_card_morale
			var current_def_overall: int = _calculate_current_morale_from_units(def) + def["dice_morale"] + def_card_morale
			
			on_event.call("dice_rolled", ["Attacker", atk_offence_pool, atk_defence_pool, (atk["dice_morale"] + atk_card_morale), current_atk_overall])
			on_event.call("dice_rolled", ["Defender", def_offence_pool, def_defence_pool, (def["dice_morale"] + def_card_morale), current_def_overall])
			
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
			"net_damage_to_defender": 0,
			"attacker_newly_routed": [],
			"defender_newly_routed": []
		}

		# --- HOOK FRAME A: BEFORE DAMAGE ASSESSMENT ---
		_execute_timing_hook(CardData.TimingWindow.BEFORE_DAMAGE, state, context, round_index, card_db, on_event)

		if on_event.is_valid():
			on_event.call("pools_updated", ["Attacker", context["atk_offence"], context["atk_defence"]])
			on_event.call("pools_updated", ["Defender", context["def_offence"], context["def_defence"]])

		# --- RAW DELTA CALCULATION STEP ---
		context["net_damage_to_defender"] = max(0, context["atk_offence"] - context["def_defence"])
		context["net_damage_to_attacker"] = max(0, context["def_offence"] - context["atk_defence"])
		
		# --- HOOK FRAME B: DURING DAMAGE ASSESSMENT ---
		_execute_timing_hook(CardData.TimingWindow.DURING_DAMAGE, state, context, round_index, card_db, on_event)
		
		if on_event.is_valid(): 
			on_event.call("damage_calculated", [context["net_damage_to_defender"], context["net_damage_to_attacker"]])
		
		# --- APPLY RESOLVED PAYLOAD TARGET DAMAGE TO UNITS ---
		
		# Pre-calculate Threat Awareness: Does the opponent have Ambush, and are we broke?
		var def_routing_lethal := _is_routing_lethal(atk_card_id, card_db, def)
		var atk_routing_lethal := _is_routing_lethal(def_card_id, card_db, atk)
		
		context["defender_newly_routed"] = apply_damage(def, context["net_damage_to_defender"], round_index, def_routing_lethal, on_event)
		context["attacker_newly_routed"] = apply_damage(atk, context["net_damage_to_attacker"], round_index, atk_routing_lethal, on_event)

		# --- HOOK FRAME C: AFTER DAMAGE ASSESSMENT (POST-COMBAT REACTIONS) ---
		_execute_timing_hook(CardData.TimingWindow.AFTER_DAMAGE, state, context, round_index, card_db, on_event)

	# --- PHASE 3: FINAL COMBAT RESOLUTION ---
	var atk_survivors: int = _count_living_units(atk)
	var def_survivors: int = _count_living_units(def)
	
	log_current_army_statuses(state, on_event)
	
	# 1. Evaluate total mutual annihilation first
	if atk_survivors == 0 and def_survivors == 0:
		if on_event.is_valid(): on_event.call("victory_mutual_annihilation", [])
		return false

	# 2. Evaluate remaining absolute force wipeouts
	if def_survivors == 0:
		if on_event.is_valid(): on_event.call("victory_by_wipeout", ["Attacker"])
		return true
	if atk_survivors == 0:
		if on_event.is_valid(): on_event.call("victory_by_wipeout", ["Defender"])
		return false
		
	# 3. Both sides survived -> Resolve directly via Morale values
	var final_printed_atk_morale: int = 0
	var final_printed_def_morale: int = 0
	
	for i in range(3):
		if atk["play_area"][i] in card_db:
			final_printed_atk_morale += card_db[atk["play_area"][i]][2]
		if def["play_area"][i] in card_db:
			final_printed_def_morale += card_db[def["play_area"][i]][2]
	
	var final_atk_morale: int = _calculate_current_morale_from_units(atk) + atk["dice_morale"] + atk_card_morale + final_printed_atk_morale
	var final_def_morale: int = _calculate_current_morale_from_units(def) + def["dice_morale"] + def_card_morale + final_printed_def_morale
	
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
					
				# THREAT AWARENESS: If routing is lethal, we CANNOT use an unrouted unit 
				# for perfect absorption because it will die anyway. 
				# (We only allow already-routed units who can absorb damage safely without dying).
				if is_routing_lethal and not is_routed:
					continue
					
				var hp_left = squad["alive_figures"][i]
				if total_damage < hp_left and hp_left < smallest_surviving_hp:
					smallest_surviving_hp = hp_left
					perfect_target = {"squad": squad, "index": i}
					
	return perfect_target

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

static func _is_mutual_annihilation(state: Dictionary) -> bool:
	var atk_survivors: int = _count_living_units(state["attacker"])
	var def_survivors: int = _count_living_units(state["defender"])
	return atk_survivors == 0 and def_survivors == 0

static func _execute_timing_hook(window: int, state: Dictionary, context: Dictionary, round_index: int, card_db: Dictionary, on_event: Callable) -> void:
	match window:
		3: # CardData.TimingWindow.AFTER_DAMAGE
			var atk: Dictionary = state["attacker"]
			var def: Dictionary = state["defender"]
			
			var sides_to_check = [
				{"player": atk, "opponent": def, "routed_list": context.get("defender_newly_routed", []), "role": "Attacker", "opp_role": "Defender"},
				{"player": def, "opponent": atk, "routed_list": context.get("attacker_newly_routed", []), "role": "Defender", "opp_role": "Attacker"}
			]
			
			for side in sides_to_check:
				var active_card_id: int = side["player"]["play_area"][round_index]
				
				# Ensure the card actually exists in the database
				if not card_db.has(active_card_id): continue
				
				var card_data: Array = card_db[active_card_id]
				var effects_list: Array = card_data[3]
				
				# Scan the active card for AFTER_DAMAGE reactive effects
				for fx in effects_list:
					var effect_type: int = fx[0]
					
					# --- HOOK: DESTROY ON ROUT OR SPEND ---
					if effect_type == CardData.EffectType.DESTROY_ON_ROUT_OR_SPEND:
						var newly_routed: Array = side["routed_list"]
						var ransom_cost: int = fx[2] # Dynamically grab the cost from the card data!
						
						if newly_routed.is_empty():
							continue
							
						for target_data in newly_routed:
							var squad: Dictionary = target_data["squad"]
							var idx: int = target_data["index"]
							
							# Skip if standard damage overflow already outright killed it
							if squad["alive_figures"][idx] <= 0:
								continue
								
							if on_event.is_valid():
								on_event.call("ability_triggered", [active_card_id, "Ambush activates! Checking ransom on newly routed %s figure." % squad["name"]])
							
							var opponent_side: Dictionary = side["opponent"]
							
							# Check if opponent can pay the ransom
							if opponent_side.get("dice_morale", 0) >= ransom_cost:
								opponent_side["dice_morale"] -= ransom_cost
								if on_event.is_valid():
									print("    ↳ 🤝 Opponent spends %d Morale dice ransom! The unit survives." % ransom_cost)
							else:
								# Insufficient Morale to pay! Instant Execution!
								squad["alive_figures"][idx] = 0
								squad["figures_routed"][idx] = true
								if on_event.is_valid():
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
		
		if not is_unit_fx and not general_phase_started:
			general_phase_started = true
			if on_event.is_valid(): on_event.call("ability_block_started", [role_label, "General"])
		elif is_unit_fx and not unit_phase_started:
			unit_phase_started = true
			if on_event.is_valid(): on_event.call("ability_block_started", [role_label, "Unit"])

		if is_unit_fx:
			var req_unit: int = fx[5]
			if req_unit != 0 and not _has_active_unit_type(side_data, req_unit):
				if on_event.is_valid():
					on_event.call("unit_ability_not_resolved", [role_label, active_card_id, [req_unit]])
				continue
		
		var effect_type: int = fx[0]
		if EFFECT_RESOLVERS.has(effect_type):
			EFFECT_RESOLVERS[effect_type].call(fx, running_pools, side_data, role_label, active_card_id, on_event)
		else:
			print("    -> ⚠️ Engine skipped non-instant or unresolved effect archetype: %d" % effect_type)

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
	var chosen_sub_fx = final_pool[rolled_index].duplicate(true)
	
	if not chosen_sub_fx is Array or chosen_sub_fx.is_empty():
		return
		
	var sub_effect_type: int = chosen_sub_fx[0]
	if EFFECT_RESOLVERS.has(sub_effect_type):
		EFFECT_RESOLVERS[sub_effect_type].call(chosen_sub_fx, pools, side_data, role, card_id, on_event)

static func _execute_gain_dice(fx: Array, pools: Dictionary, _side_data: Dictionary, role: String, card_id: int, on_event: Callable) -> void:
	if fx[2] is Array:
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
		return
		
	var val: int = fx[2]
	var pool_type: int = fx[3]
	var prefix := "atk_" if role == "Attacker" else "def_"
	
	if on_event.is_valid(): 
		on_event.call("ability_triggered", [card_id, "Resolved GAIN_SPECIFIC_DICE (Count: %d)" % val])
		
	var b_offence := 0; var b_defence := 0; var b_morale := 0
	
	if pool_type == 0:
		for d in range(val):
			match _roll_custom_die_index():
				0: b_offence += 1
				1: b_defence += 1
				2: b_morale += 1
	else:
		match pool_type:
			1: b_offence = val
			2: b_defence = val
			3: b_morale = val
			
	if on_event.is_valid(): 
		on_event.call("bonus_dice_rolled", [role, b_offence, b_defence, b_morale])
	
	pools[prefix + "offence"] += b_offence
	pools[prefix + "defence"] += b_defence
	pools[prefix + "card_morale"] += b_morale

static func _execute_reroll(fx: Array, pools: Dictionary, _side_data: Dictionary, role: String, card_id: int, on_event: Callable) -> void:
	if fx[2] is Array:
		return
		
	var val: int = fx[2]
	var target_type: int = fx[1]
	
	var is_attacker := (role == "Attacker")
	var targets_self := (target_type == 0)
	var target_role := role if targets_self else ("Defender" if is_attacker else "Attacker")
	var prefix := "atk_" if target_role == "Attacker" else "def_"

	var icon_names := {0: "Offence", 1: "Defence", 2: "Morale"}

	for iteration in range(val):
		var o_count: int = pools[prefix + "offence"]
		var d_count: int = pools[prefix + "defence"]
		var m_count: int = pools[prefix + "card_morale"]
		var total_dice: int = o_count + d_count + m_count
		
		if total_dice == 0:
			break
			
		var picked_index := randi() % total_dice
		var face_removed := -1
		
		if picked_index < o_count:
			face_removed = 0
			pools[prefix + "offence"] -= 1
		elif picked_index < (o_count + d_count):
			face_removed = 1
			pools[prefix + "defence"] -= 1
		else:
			face_removed = 2
			pools[prefix + "card_morale"] -= 1
			
		var face_added := _roll_custom_die_index()
		
		match face_added:
			0: pools[prefix + "offence"] += 1
			1: pools[prefix + "defence"] += 1
			2: pools[prefix + "card_morale"] += 1
			
		if on_event.is_valid():
			on_event.call("dice_rerolled_log", [
				target_role, 
				icon_names[face_removed], 
				icon_names[face_added]
			])

static func _execute_gain_specific_combat_token(fx: Array, pools: Dictionary, _side_data: Dictionary, role: String, card_id: int, on_event: Callable) -> void:
	if fx[2] is Array:
		return
		
	var val: int = fx[2]
	var pool_type: int = fx[3]
	var prefix := "atk_token_" if role == "Attacker" else "def_token_"
	
	var label := "Offence" if pool_type == 1 else "Defence"
	if on_event.is_valid():
		on_event.call("ability_triggered", [card_id, "Resolved GAIN_SPECIFIC_COMBAT_TOKEN (+%d %s Token)" % [val, label]])
		
	match pool_type:
		1: pools[prefix + "offence"] += val
		2: pools[prefix + "defence"] += val

static func _execute_rally(fx: Array, _pools: Dictionary, side_data: Dictionary, role: String, card_id: int, on_event: Callable) -> void:
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

static func _execute_destroy_for_destroy(fx: Array, _pools: Dictionary, side_data: Dictionary, role: String, card_id: int, on_event: Callable) -> void:
	var required_unit_type: int = fx[5]
	var count_to_destroy: int = fx[2]
	
	var is_attacker := (role == "Attacker")
	var opponent_data: Dictionary = side_data.get("parent_state", {}).get("defender" if is_attacker else "attacker", {})
	var opponent_role := "Defender" if is_attacker else "Attacker"
	
	if opponent_data.is_empty():
		return

	if on_event.is_valid():
		on_event.call("ability_triggered", [card_id, "Executing DESTROY_FOR_DESTROY sacrifice trade!"])

	var self_sacrificed := 0
	for squad in side_data["squads"]:
		if int(squad.get("unit_type", -1)) == required_unit_type:
			for i in range(squad["alive_figures"].size()):
				if squad["alive_figures"][i] > 0 and not squad["figures_routed"][i]:
					squad["alive_figures"][i] = 0
					squad["figures_routed"][i] = true
					self_sacrificed += 1
					
					if on_event.is_valid():
						on_event.call("unit_destroyed", [role, squad["name"], 0, false])
					break
			if self_sacrificed >= count_to_destroy:
				break

	if self_sacrificed == 0:
		return

	var opponent_sacrificed := 0
	while opponent_sacrificed < count_to_destroy:
		var victim_target := _find_lowest_tier_unit_to_destroy(opponent_data["squads"])
		
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
			
		vic_squad["alive_figures"][vic_idx] = 0
		vic_squad["figures_routed"][vic_idx] = true
		opponent_sacrificed += 1

#endregion


#region Passive Card Abilities and helpers

static func _is_routing_lethal(opp_card_id: int, card_db: Dictionary, my_state: Dictionary) -> bool:
	if not card_db.has(opp_card_id):
		return false
		
	var effects_list: Array = card_db[opp_card_id][3]
	for fx in effects_list:
		if fx[0] == CardData.EffectType.DESTROY_ON_ROUT_OR_SPEND:
			var ransom_cost: int = fx[2]
			# If we cannot afford the ransom, routing is guaranteed death
			if my_state.get("dice_morale", 0) < ransom_cost:
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
			
			# Normal logic: Sacrifice cheap unit if overflow is survivable by big guy
			var overflow_survivable = (total_damage - low_hp) < big_hp
			
			# THREAT AWARENESS: If routing is lethal, ANY overflow onto the big guy causes a rout & death.
			# So we only sacrifice the cheap unit if it absorbs ALL the incoming damage.
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
