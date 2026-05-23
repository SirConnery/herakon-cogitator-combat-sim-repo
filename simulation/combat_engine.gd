extends Object
class_name SimCombatEngine

#region Starting vars and functions

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

#endregion

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

	# --- 3. RECURRING ROUND-LOOP SCRATCHPAD VARIABLES ---
	var atk_idx := 0
	var def_idx := 0
	var atk_card_id := 0
	var def_card_id := 0

	var card_icons_atk_offence = 0
	var card_icons_atk_defence = 0
	var card_icons_atk_morale = 0

	var card_icons_def_offence = 0
	var card_icons_def_defence = 0
	var card_icons_def_morale = 0

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
		log_current_dice_pools(on_event, atk, def, "round_start")
		log_current_unit_morale(on_event, atk, def, "round_start")

	# --- PHASE 2: THREE-ROUND COMBAT ENGINE CRUCIBLE LOOP ---
	for round_index in range(3):

		if _count_living_units(atk) == 0 or _count_living_units(def) == 0:
			if on_event.is_valid():
				on_event.call("early_termination", [])
			break

		# --- Flush text-based round modifiers completely on fresh round start ---
		atk["extra_icons"] = [0, 0, 0]
		def["extra_icons"] = [0, 0, 0]

		# --- SYSTEMIC HEALING PASS: Restore all surviving figures to max HP ---
		for squad in atk["squads"]:
			for i in range(squad["alive_figures"].size()):
				squad["alive_figures"][i] = squad["health_value"]

		for squad in def["squads"]:
			for i in range(squad["alive_figures"].size()):
				squad["alive_figures"][i] = squad["health_value"]

		if on_event.is_valid():
			on_event.call("round_start", [round_index])
			log_current_army_statuses(state, on_event)
			log_current_dice_pools(on_event, atk, def, "round_start")
			log_current_extra_icons(on_event, atk["extra_icons"], def["extra_icons"], "round_start")
			log_current_unit_morale(on_event, atk, def, "round_start")
			log_current_card_icons(on_event, [card_icons_atk_offence, card_icons_atk_defence, card_icons_atk_morale], [card_icons_def_offence, card_icons_def_defence, card_icons_def_morale], "round_start")

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
			log_current_dice_pools(on_event, atk, def, "damage_step")
			log_current_unit_morale(on_event, atk, def, "damage_step")
			log_current_extra_icons(on_event, atk["extra_icons"], def["extra_icons"], "damage_step")
			log_current_card_icons(on_event, [card_icons_atk_offence, card_icons_atk_defence, card_icons_atk_morale], [card_icons_def_offence, card_icons_def_defence, card_icons_def_morale], "damage_step")

		atk.erase("parent_state")
		def.erase("parent_state")

		# --- Safely query the round-scoped dynamic icon modifiers ---
		var atk_ex: Array = atk.get("extra_icons", [0, 0, 0])
		var def_ex: Array = def.get("extra_icons", [0, 0, 0])

		# --- Append extra_icons array values straight into the battle equations ---
		context[0] = atk[Stat.OFFENCE] + card_icons_atk_offence + token_pools[0] + atk_ex[0] # atk_offence
		context[1] = atk[Stat.DEFENCE] + card_icons_atk_defence + token_pools[1] + atk_ex[1] # atk_defence
		context[2] = def[Stat.OFFENCE] + card_icons_def_offence + token_pools[2] + def_ex[0] # def_offence
		context[3] = def[Stat.DEFENCE] + card_icons_def_defence + token_pools[3] + def_ex[1] # def_defence
	
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

	# --- FINAL MORALE SCORE ---
	final_atk_morale = _calculate_current_morale_from_units(atk) + atk[Stat.MORALE] + card_icons_atk_morale
	final_def_morale = _calculate_current_morale_from_units(def) + def[Stat.MORALE] + card_icons_def_morale

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

static func log_current_unit_morale(on_event: Callable, atk_side: Dictionary, def_side: Dictionary, phase_context: String = "all") -> void:
	if not on_event.is_valid():
		return
		
	var atk_morale := _calculate_current_morale_from_units(atk_side)
	var def_morale := _calculate_current_morale_from_units(def_side)
	
	on_event.call("unit_morale_status_logged", ["Attacker", atk_morale, phase_context])
	on_event.call("unit_morale_status_logged", ["Defender", def_morale, phase_context])

static func log_current_dice_pools(on_event: Callable, atk_side: Dictionary, def_side: Dictionary, phase_context: String = "all") -> void:
	if not on_event.is_valid():
		return
		
	var atk_o: int = atk_side.get(Stat.OFFENCE, 0)
	var atk_d: int = atk_side.get(Stat.DEFENCE, 0)
	var atk_m: int = atk_side.get(Stat.MORALE, 0)
	
	var def_o: int = def_side.get(Stat.OFFENCE, 0)
	var def_d: int = def_side.get(Stat.DEFENCE, 0)
	var def_m: int = def_side.get(Stat.MORALE, 0)
	
	on_event.call("dice_pool_status_logged", ["Attacker", atk_o, atk_d, atk_m, phase_context])
	on_event.call("dice_pool_status_logged", ["Defender", def_o, def_d, def_m, phase_context])

static func log_current_card_icons(on_event: Callable, atk_icons: Array, def_icons: Array, phase_context: String = "all") -> void:
	if not on_event.is_valid():
		return
		
	var a = atk_icons if atk_icons.size() == 3 else [0, 0, 0]
	var d = def_icons if def_icons.size() == 3 else [0, 0, 0]
	
	on_event.call("card_icons_logged", ["Attacker", a[0], a[1], a[2], phase_context])
	on_event.call("card_icons_logged", ["Defender", d[0], d[1], d[2], phase_context])

static func log_current_extra_icons(on_event: Callable, atk_icons: Array, def_icons: Array, phase_context: String = "all") -> void:
	var a = atk_icons if atk_icons.size() == 3 else [0, 0, 0]
	var d = def_icons if def_icons.size() == 3 else [0, 0, 0]
	
	on_event.call("extra_icons_logged", ["Attacker", a[0], a[1], a[2], phase_context])
	on_event.call("extra_icons_logged", ["Defender", d[0], d[1], d[2], phase_context])
	
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

static func _get_token_index(role: String, pool_type: int, target_opponent: bool) -> int:
	var is_attacker := (role == "Attacker")
	var subject_is_attacker := is_attacker if not target_opponent else not is_attacker
	
	var base_idx := 0 if subject_is_attacker else 2
	var offset := 0 if pool_type == CardData.DicePoolType.OFFENSE else 1
	
	return base_idx + offset

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

#region Effect Resolvers database

# Resolvers for instant effects
static var EFFECT_RESOLVERS = {
	CardData.EffectType.CHOICE: _execute_choice_selection,
	CardData.EffectType.GAIN_DICE: _execute_gain_dice,
	CardData.EffectType.GAIN_SPECIFIC_DICE: _execute_gain_specific_dice,
	CardData.EffectType.LOSE_SPECIFIC_DICE: _execute_lose_specific_dice,
	CardData.EffectType.CONVERT_DICE_TO_SPECIFIC_DICE: _execute_convert_dice_to_specific_dice,
	CardData.EffectType.REROLL: _execute_reroll,
	CardData.EffectType.REROLL_ALL_SPECIFIC_DICE: _execute_reroll_all_specific_dice,
	CardData.EffectType.REROLL_SPECIFIC_DICE_FOR_EACH_UNIT: _execute_reroll_specific_dice_for_each_unit,
	
	CardData.EffectType.GAIN_SPECIFIC_COMBAT_TOKEN: _execute_gain_specific_combat_token,
	
	CardData.EffectType.RALLY: _execute_rally, 
	
	# SM
	CardData.EffectType.SHIELD_DEBUFF_CONDITIONAL: _execute_shield_debuff_conditional, # FAITH_IN_THE_EMPEROR
	
	# ORK
	CardData.EffectType.DESTROY_FOR_DESTROY: _execute_destroy_for_destroy, # GRETCHIN
	CardData.EffectType.DISCARD_STEAL_ICONS: _execute_discard_steal_icons, # MEK_BOYZ
}

#endregion


#region Main Resolvers

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
		
	var is_attacker := (role == "Attacker")
	var opponent_side_data: Dictionary = side_data.get("parent_state", {}).get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
		
	var valid_options: Array = []
	for sub_fx in options:
		if not sub_fx is Array:
			continue
		var effect_type: int = sub_fx[0]
		var target_type: int = sub_fx[1]
		
		match effect_type:
			CardData.EffectType.RALLY:
				if _has_any_routed_units(side_data):
					valid_options.append(sub_fx)
			CardData.EffectType.GAIN_DICE, CardData.EffectType.GAIN_SPECIFIC_DICE:
				var current_total: int = side_data[Stat.OFFENCE] + side_data[Stat.DEFENCE] + side_data[Stat.MORALE]
				if current_total < 8:
					valid_options.append(sub_fx)
			CardData.EffectType.REROLL:
				var target_ctx = opponent_side_data if target_type == 1 else side_data
				var pool_to_check: int = sub_fx[3]
				
				if pool_to_check == 2 and not target_ctx.is_empty() and target_ctx[Stat.DEFENCE] > 0:
					valid_options.append(sub_fx)
				elif pool_to_check != 2 and not target_ctx.is_empty():
					valid_options.append(sub_fx)
			_:
				valid_options.append(sub_fx)
				
	var final_pool: Array = valid_options if not valid_options.is_empty() else options
	var rolled_index := randi() % final_pool.size()
	var chosen_sub_fx = final_pool[rolled_index].duplicate(true)
	
	if not chosen_sub_fx is Array or chosen_sub_fx.is_empty():
		return
		
	var sub_effect_type: int = chosen_sub_fx[0]
	
	# Handles optional choice passes cleanly without throwing an unresolved error
	if sub_effect_type == CardData.EffectType.NONE:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ 🎲 Tactical Choice: %s elected to pass on their optional self-reroll action." % role])
		return

	if EFFECT_RESOLVERS.has(sub_effect_type):
		EFFECT_RESOLVERS[sub_effect_type].call(chosen_sub_fx, token_pools, side_data, role, card_id, units_valid, on_event)

#endregion

#region Generic Dice functions
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
	var target_type: int = fx[1]
	var pool_type: int = fx[3]
	
	var is_attacker := (role == "Attacker")
	var targets_self := (target_type == 0)
	
	# FIXED: Dynamically resolve who is actually gaining the dice portfolio entries
	var target_side_data := side_data
	var target_role := role
	if not targets_self:
		target_role = "Defender" if is_attacker else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
		
	if target_side_data.is_empty():
		return

	# Evaluate cap restrictions based on the true target's pool size
	var current_total_dice: int = target_side_data[Stat.OFFENCE] + target_side_data[Stat.DEFENCE] + target_side_data[Stat.MORALE]
	var allowed_val: int = min(requested_val, 8 - current_total_dice)
	
	if allowed_val <= 0:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "Resolved GAIN_SPECIFIC_DICE skipped - %s already at maximum 8 dice cap." % target_role])
		return
		
	if on_event.is_valid(): 
		on_event.call("ability_triggered", [card_id, "Resolved GAIN_SPECIFIC_DICE (Allowed: %d out of %d for %s)" % [allowed_val, requested_val, target_role]])
		
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
		on_event.call("bonus_dice_rolled", [target_role, b_offence, b_defence, b_morale])
	
	target_side_data[Stat.OFFENCE] += b_offence
	target_side_data[Stat.DEFENCE] += b_defence
	target_side_data[Stat.MORALE] += b_morale

	var parent_state: Dictionary = side_data.get("parent_state", {})
	if not parent_state.is_empty() and on_event.is_valid():
		var atk_side: Dictionary = parent_state.get(Side.ATTACKER, {})
		var def_side: Dictionary = parent_state.get(Side.DEFENDER, {})
		
		if not atk_side.is_empty() and not def_side.is_empty():
			log_current_dice_pools(on_event, atk_side, def_side, "Dice Gain")

static func _execute_lose_specific_dice(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	if fx[2] is Array:
		return
		
	var requested_val: int = fx[2]
	var target_type: int = fx[1]
	var pool_type: int = fx[3]
	
	var is_attacker := (role == "Attacker")
	var targets_self := (target_type == 0)
	
	# Determine whose dice pool is shrinking
	var target_side_data := side_data
	var target_role := role
	if not targets_self:
		target_role = "Defender" if is_attacker else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
		
	if target_side_data.is_empty():
		return

	var labels := {1: "Offence", 2: "Defence", 3: "Morale"}
	var stat_map := {1: Stat.OFFENCE, 2: Stat.DEFENCE, 3: Stat.MORALE}
	
	var lost_offence := 0
	var lost_defence := 0
	var lost_morale := 0

	# --- BRANCH 1: Strip From A Specific Targeted Pool ---
	if pool_type in stat_map:
		var target_stat = stat_map[pool_type]
		var available_dice: int = target_side_data[target_stat]
		var actual_lost = min(requested_val, available_dice)
		
		if actual_lost > 0:
			target_side_data[target_stat] -= actual_lost
			match pool_type:
				1: lost_offence = actual_lost
				2: lost_defence = actual_lost
				3: lost_morale = actual_lost
				
			if on_event.is_valid():
				on_event.call("ability_triggered", [card_id, "Resolved LOSE_SPECIFIC_DICE: %s lost %d %s die/dice." % [target_role, actual_lost, labels[pool_type]]])

	# --- BRANCH 2: Strip Randomly From Any Existing Pools ---
	elif pool_type == 0:
		for iteration in range(requested_val):
			var o_count: int = target_side_data[Stat.OFFENCE]
			var d_count: int = target_side_data[Stat.DEFENCE]
			var m_count: int = target_side_data[Stat.MORALE]
			var total_dice := o_count + d_count + m_count
			
			if total_dice == 0:
				break # Opponent is bone-dry, nothing left to take
				
			var picked_idx := randi() % total_dice
			if picked_idx < o_count:
				target_side_data[Stat.OFFENCE] -= 1
				lost_offence += 1
			elif picked_idx < (o_count + d_count):
				target_side_data[Stat.DEFENCE] -= 1
				lost_defence += 1
			else:
				target_side_data[Stat.MORALE] -= 1
				lost_morale += 1
				
		var total_lost_classes := lost_offence + lost_defence + lost_morale
		if total_lost_classes > 0 and on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "Resolved LOSE_SPECIFIC_DICE: %s lost %d random dice portfolio entries (-%d⚔️, -%d🛡️, -%d🎖️)." % [target_role, total_lost_classes, lost_offence, lost_defence, lost_morale]])

	# Broadcast a master state updates call log if changes occurred
	if (lost_offence + lost_defence + lost_morale) > 0 and on_event.is_valid():
		on_event.call("dice_updated", [target_role, target_side_data[Stat.OFFENCE], target_side_data[Stat.DEFENCE], target_side_data[Stat.MORALE]])

static func _execute_convert_dice_to_specific_dice(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var max_to_convert: int = fx[2]
	var target_pool_type: int = fx[3]
	
	var is_attacker := (role == "Attacker")
	var targets_self = (fx[1] == 0)
	
	var target_side_data := side_data
	var target_role := role
	if not targets_self:
		target_role = "Defender" if is_attacker else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
		
	if target_side_data.is_empty():
		return

	var stat_map := {1: Stat.OFFENCE, 2: Stat.DEFENCE, 3: Stat.MORALE}
	if not target_pool_type in stat_map:
		return
		
	var target_stat = stat_map[target_pool_type]
	var converted_count := 0
	var stripped_counts := {Stat.OFFENCE: 0, Stat.DEFENCE: 0, Stat.MORALE: 0}

	for conversion in range(max_to_convert):
		var best_source_stat := -1
		var max_available_dice := 0
		
		for src_stat in [Stat.OFFENCE, Stat.DEFENCE, Stat.MORALE]:
			if src_stat == target_stat:
				continue
			if target_side_data[src_stat] > max_available_dice:
				max_available_dice = target_side_data[src_stat]
				best_source_stat = src_stat
				
		if best_source_stat == -1 or max_available_dice <= 0:
			break
			
		target_side_data[best_source_stat] -= 1
		target_side_data[target_stat] += 1
		
		stripped_counts[best_source_stat] += 1
		converted_count += 1

	if converted_count > 0 and on_event.is_valid():
		var labels := {Stat.OFFENCE: "Offence", Stat.DEFENCE: "Defence", Stat.MORALE: "Morale"}
		var breakdown_parts: Array[String] = []
		for stat_key in stripped_counts:
			if stripped_counts[stat_key] > 0:
				breakdown_parts.append("%d %s" % [stripped_counts[stat_key], labels[stat_key]])
				
		on_event.call("ability_triggered", [card_id, "↳ 🔄 Dice Conversion: %s turned %d alternate dice (%s) directly into %s dice!" % [target_role, converted_count, ", ".join(breakdown_parts), labels[target_stat]]])
		
		var parent_state: Dictionary = side_data.get("parent_state", {})
		if not parent_state.is_empty():
			var atk_side: Dictionary = parent_state.get(Side.ATTACKER, {})
			var def_side: Dictionary = parent_state.get(Side.DEFENDER, {})
			
			if not atk_side.is_empty() and not def_side.is_empty():
				log_current_dice_pools(on_event, atk_side, def_side, "Conversion")

static func _execute_reroll(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
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

	var current_o: int = target_side_data[Stat.OFFENCE]
	var current_d: int = target_side_data[Stat.DEFENCE]
	var current_m: int = target_side_data[Stat.MORALE]
	var total_dice := current_o + current_d + current_m
	
	var actual_reroll_count: int = min(val, total_dice)
	if actual_reroll_count <= 0:
		return

	var removed_o := 0
	var removed_d := 0
	var removed_m := 0
	
	# 1. Generate an index array tracking the frozen state of the pool
	var flat_pool: Array[int] = []
	for i in range(current_o): flat_pool.append(0)
	for i in range(current_d): flat_pool.append(1)
	for i in range(current_m): flat_pool.append(2)
	
	# 2. Extract targeted categories safely without mutation loops
	for iteration in range(actual_reroll_count):
		var picked_idx := randi() % flat_pool.size()
		match flat_pool.pop_at(picked_idx):
			0: removed_o += 1
			1: removed_d += 1
			2: removed_m += 1

	# 3. Apply the combined removal batch instantly
	target_side_data[Stat.OFFENCE] -= removed_o
	target_side_data[Stat.DEFENCE] -= removed_d
	target_side_data[Stat.MORALE] -= removed_m
	
	# 4. Roll fresh replacement metrics into an insertion tracker
	var added_o := 0
	var added_d := 0
	var added_m := 0
	
	for iteration in range(actual_reroll_count):
		var face_added := _roll_custom_die_index()
		match face_added:
			0: added_o += 1
			1: added_d += 1
			2: added_m += 1
			
	# 5. Inject newly rolled faces back into play systems all at once
	target_side_data[Stat.OFFENCE] += added_o
	target_side_data[Stat.DEFENCE] += added_d
	target_side_data[Stat.MORALE] += added_m

	# 6. Print clean unified summary
	if on_event.is_valid():
		var summary_msg := "↳ 🎲 Tactical Reroll: Selected %d random dice (-%d⚔️, -%d🛡️, -%d🎖️). Simultaneous results -> +%d ⚔️ | +%d 🛡️ | +%d 🎖️" % [
			actual_reroll_count, removed_o, removed_d, removed_m, added_o, added_d, added_m
		]
		on_event.call("ability_triggered", [card_id, summary_msg])
		on_event.call("dice_updated", [target_role, target_side_data[Stat.OFFENCE], target_side_data[Stat.DEFENCE], target_side_data[Stat.MORALE]])

static func _execute_reroll_all_specific_dice(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var pool_type: int = fx[3]
	var targets_self: bool = (fx[1] == 0)
	
	var target_side_data := side_data
	var target_role := role
	if not targets_self:
		var is_attacker := (role == "Attacker")
		target_role = "Defender" if is_attacker else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
		
	if target_side_data.is_empty():
		return

	var stat_map := {1: Stat.OFFENCE, 2: Stat.DEFENCE, 3: Stat.MORALE}
	var labels := {1: "Offence", 2: "Defence", 3: "Morale"}
	
	if not pool_type in stat_map:
		return
		
	var target_stat = stat_map[pool_type]
	var total_to_reroll: int = target_side_data[target_stat]
	
	if total_to_reroll <= 0:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ 🔄 Reroll All skipped: %s has 0 %s dice." % [target_role, labels[pool_type]]])
		return
	
	# 1. Take the entire frozen batch out of the live pool instantly
	target_side_data[target_stat] = 0
	
	# 2. Roll all fresh faces into an isolated temporary buffer
	var results := [0, 0, 0] # [Offence, Defence, Morale]
	for i in range(total_to_reroll):
		var face_added := _roll_custom_die_index()
		results[face_added] += 1
			
	# 3. Commit the new batch results back to the live pool all at once
	target_side_data[Stat.OFFENCE] += results[0]
	target_side_data[Stat.DEFENCE] += results[1]
	target_side_data[Stat.MORALE] += results[2]

	# 4. Print a single consolidated batch summary to eliminate log confusion
	if on_event.is_valid():
		var summary_msg := "↳ 🎲 Batch Roll Resolved %s: Picked up all %d %s dice. Simultaneous results -> +%d ⚔️ | +%d 🛡️ | +%d 🎖️" % [
			target_role, total_to_reroll, labels[pool_type], results[0], results[1], results[2]
		]
		on_event.call("ability_triggered", [card_id, summary_msg])
		on_event.call("dice_updated", [target_role, target_side_data[Stat.OFFENCE], target_side_data[Stat.DEFENCE], target_side_data[Stat.MORALE]])


static func _execute_reroll_specific_dice_for_each_unit(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var target_unit_type: int = fx[2]
	var pool_type: int = fx[3]
	var targets_self: bool = (fx[1] == 0)
	
	var is_attacker := (role == "Attacker")
	var user_side_data := side_data
	var target_side_data := side_data
	var target_role := role
	
	if not targets_self:
		target_role = "Defender" if is_attacker else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
	else:
		user_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})

	if target_side_data.is_empty() or user_side_data.is_empty():
		return

	var unit_count := 0
	for squad in user_side_data["squads"]:
		var squad_type: int = int(squad.get("unit_type", 0))
		if squad_type == target_unit_type:
			for i in range(squad["alive_figures"].size()):
				if squad["alive_figures"][i] > 0 and not squad["figures_routed"][i]:
					unit_count += 1
					
	if unit_count <= 0:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ ⚠️ Disruptive Presence failed: No active scaling units found."])
		return

	var stat_map := {1: Stat.OFFENCE, 2: Stat.DEFENCE, 3: Stat.MORALE}
	var labels := {1: "Offence", 2: "Defence", 3: "Morale"}
	
	if not pool_type in stat_map:
		return
		
	var target_stat = stat_map[pool_type]
	var available_dice: int = target_side_data[target_stat]
	var final_reroll_count: int = min(unit_count, available_dice)
	
	if final_reroll_count <= 0:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ 🔄 Disrupt skipped: %s has 0 %s dice to target." % [target_role, labels[pool_type]]])
		return

	# 1. Deduct the whole target chunk safely up front
	target_side_data[target_stat] -= final_reroll_count
	
	# 2. Roll fresh outcomes into an isolated tracking buffer
	var results := [0, 0, 0]
	for iteration in range(final_reroll_count):
		var face_added := _roll_custom_die_index()
		results[face_added] += 1

	# 3. Inject new rolled allocations back into active state systems
	target_side_data[Stat.OFFENCE] += results[0]
	target_side_data[Stat.DEFENCE] += results[1]
	target_side_data[Stat.MORALE] += results[2]

	# 4. Print clean unified summary
	if on_event.is_valid():
		var summary_msg := "↳ 🪓 Disruptive Presence: Found %d matching units! Forced %s to simultaneous-reroll %d %s dice -> Gained +%d ⚔️ | +%d 🛡️ | +%d 🎖️" % [
			unit_count, target_role, final_reroll_count, labels[pool_type], results[0], results[1], results[2]
		]
		on_event.call("ability_triggered", [card_id, summary_msg])
		on_event.call("dice_updated", [target_role, target_side_data[Stat.OFFENCE], target_side_data[Stat.DEFENCE], target_side_data[Stat.MORALE]])
#endregion


#region Generic Token functions

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

#endregion

#region Generic Rally and Routing functions

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

#endregion

#region Generic Card functions

static func _execute_discard_steal_icons(_fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var is_attacker := (role == "Attacker")
	var opp_role := "Defender" if is_attacker else "Attacker"
	
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return
		
	var opp_side_data: Dictionary = parent_state.get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
	
	# 1. Unpack our shared flat card database reference
	var card_db: Dictionary = parent_state.get("card_db", {})
	if card_db.is_empty():
		return

	# 2. Extract and validate the target opponent's combat deck array
	var opp_deck: Array = opp_side_data.get("combat_deck", [])
	if opp_deck.is_empty():
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ 🎴 Theft Failed: Enemy %s combat deck is completely dry!" % opp_role])
		return

	# 3. Strip the top Card ID off their active pile
	var stolen_card_id: int = opp_deck.pop_front()
	var flat_card_data = card_db.get(stolen_card_id)
	
	if flat_card_data == null or not flat_card_data is Array:
		# Safety rewind: restore the deck order if it encounters a data mismatch
		opp_deck.push_front(stolen_card_id)
		return

	# Parse flat profile fields: [0: Offence, 1: Defence, 2: Morale]
	var stolen_offence: int = flat_card_data[0]
	var stolen_defence: int = flat_card_data[1]
	var stolen_morale: int = flat_card_data[2]
	
	# 4. Apply stolen stats straight into your temporary extra_icons array structure
	if side_data.has("extra_icons") and side_data["extra_icons"] is Array:
		side_data["extra_icons"][0] += stolen_offence
		side_data["extra_icons"][1] += stolen_defence
		side_data["extra_icons"][2] += stolen_morale
	
	if on_event.is_valid():
		on_event.call("ability_triggered", [card_id, "↳ ⚙️ Mek Salvage: Discarded top enemy card! Harvested temporary extra icons: +%d⚔️ | +%d🛡️ | +%d🎖️" % [stolen_offence, stolen_defence, stolen_morale]])

	# 5. Recycling Rule: Push the spent item back to bottom and reshuffle
	opp_deck.append(stolen_card_id)
	opp_deck.shuffle()

	# 6. UPDATED: Pass the array structures directly through to the tracking helper
	if on_event.is_valid():
		var atk_side: Dictionary = parent_state.get(Side.ATTACKER, {})
		var def_side: Dictionary = parent_state.get(Side.DEFENDER, {})
		
		if not atk_side.is_empty() and not def_side.is_empty():
			var atk_ex: Array = atk_side.get("extra_icons", [0, 0, 0])
			var def_ex: Array = def_side.get("extra_icons", [0, 0, 0])
			
			log_current_extra_icons(on_event, atk_ex, def_ex, "damage_step")

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


#region Instant Card abilities

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


static func _execute_shield_debuff_conditional(fx: Array, token_pools: Array, side_data: Dictionary, role: String, card_id: int, units_valid: bool, on_event: Callable) -> void:
	var max_tokens_to_strip: int = fx[2]
	var pool_type: int = fx[3]
	
	# 1. Use the token index helper to inspect the opponent's pool status silently
	var opp_token_idx := _get_token_index(role, pool_type, true)
	var current_opp_tokens: int = token_pools[opp_token_idx]
	
	# --- BRANCH 1: Opponent has tokens -> Outsource to generic token handler ---
	if current_opp_tokens > 0:
		var tokens_lost = min(current_opp_tokens, max_tokens_to_strip)
		
		# Build a temporary runtime effect payload targeted at the enemy's tokens
		var token_payload := [
			CardData.EffectType.GAIN_SPECIFIC_COMBAT_TOKEN, # Index 0: EffectType
			1,                                             # Index 1: TargetType.OPPONENT
			-tokens_lost,                                  # Index 2: Value (Negative modifier strips tokens)
			pool_type,                                     # Index 3: PoolType
			fx[4],                                         # Index 4: Block Type
			fx[5]                                          # Index 5: Requirements Array
		]
		
		_execute_gain_specific_combat_token(token_payload, token_pools, side_data, role, card_id, units_valid, on_event)
		
	# --- BRANCH 2: Opponent has 0 tokens -> Outsource to generic dice dropper ---
	else:
		# Build a temporary runtime effect payload targeted at the enemy's dice pool
		var dice_payload := [
			CardData.EffectType.LOSE_SPECIFIC_DICE,         # Index 0: EffectType
			1,                                             # Index 1: TargetType.OPPONENT
			1,                                             # Index 2: Value (Count of dice to drop)
			pool_type,                                     # Index 3: PoolType
			fx[4],                                         # Index 4: Block Type
			fx[5]                                          # Index 5: Requirements Array
		]
		
		_execute_lose_specific_dice(dice_payload, token_pools, side_data, role, card_id, units_valid, on_event)




#endregion
