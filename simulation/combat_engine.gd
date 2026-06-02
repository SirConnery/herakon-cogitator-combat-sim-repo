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

	# Initialize snapshot arrays to cache unit ability qualification histories
	atk["unit_abilities_unlocked"] = [false, false, false]
	def["unit_abilities_unlocked"] = [false, false, false]

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

	var token_pools := [0, 0, 0, 0] 

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
	
	for i in range(atk_dice_to_roll):
		match _roll_custom_die_index():
			0: atk_dice_offence += 1
			1: atk_dice_defence += 1
			2: atk_dice_morale += 1

	for i in range(def_dice_to_roll):
		match _roll_custom_die_index():
			0: def_dice_offence += 1
			1: def_dice_defence += 1
			2: def_dice_morale += 1

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
		state["current_round_index"] = round_index
		state["extra_damage_steps_this_round"] = 0
		
		if _count_living_units(atk) == 0 or _count_living_units(def) == 0:
			if on_event.is_valid():
				on_event.call("early_termination", [])
			break

		# Reset modifier variables and clear card status structures per round
		atk["extra_icons"] = [0, 0, 0]
		def["extra_icons"] = [0, 0, 0]
		
		#region Special ability round variables
		atk["cannot_route"] = false
		def["cannot_route"] = false
		
		atk["cannot_gain_defense_tokens"] = false
		def["cannot_gain_defense_tokens"] = false
		#endregion Special ability round variables end

		for squad in atk["squads"]:
			for i in range(squad["alive_figures"].size()):
				if squad["alive_figures"][i] > 0: 
					squad["alive_figures"][i] = squad["health_value"]

		for squad in def["squads"]:
			for i in range(squad["alive_figures"].size()):
				if squad["alive_figures"][i] > 0: 
					squad["alive_figures"][i] = squad["health_value"]

		# --- CENTRALIZED ROUND START TELEMETRY ---
		if on_event.is_valid():
			_log_phase_telemetry("round_start", state, card_db, round_index, on_event, token_pools)

		# --- PLAY COMBAT CARDS ---
		atk_idx = randi() % atk["cards_in_hand"].size()
		def_idx = randi() % def["cards_in_hand"].size()

		atk_card_id = atk["cards_in_hand"].pop_at(atk_idx)
		def_card_id = def["cards_in_hand"].pop_at(def_idx)

		atk["play_area"][round_index] = atk_card_id
		def["play_area"][round_index] = def_card_id

		# Evaluate and store requirements snapshot before state transitions
		atk["unit_abilities_unlocked"][round_index] = _check_card_unit_reqs_met(atk_card_id, card_db, atk)
		def["unit_abilities_unlocked"][round_index] = _check_card_unit_reqs_met(def_card_id, card_db, def)

		# --- INSTANTIATE LOCAL OPERATION SCRATCHPADS ---
		token_pools[0] = 0 
		token_pools[1] = 0 
		token_pools[2] = 0 
		token_pools[3] = 0 

		state["card_db"] = card_db
		atk["parent_state"] = state
		def["parent_state"] = state

		# Step A: Resolve Attacker and execute immediate turn-order reactive check
		var pre_atk_o: int = token_pools[0]
		var pre_atk_d: int = token_pools[1]
		_resolve_instant_ability(atk_card_id, card_db, token_pools, Side.ATTACKER, state, on_event)
		_check_weirdboyz_after_attacker_resolves(state, round_index, token_pools, pre_atk_o, pre_atk_d, on_event)
		
		# Step B: Resolve Defender and execute immediate turn-order reactive check
		var pre_def_o: int = token_pools[2]
		var pre_def_d: int = token_pools[3]
		_resolve_instant_ability(def_card_id, card_db, token_pools, Side.DEFENDER, state, on_event)
		_check_weirdboyz_after_defender_resolves(state, round_index, token_pools, pre_def_o, pre_def_d, on_event)
		
		# --- DYNAMIC MULTI-PASS DAMAGE LOOP WRAPPER ---
		var extra_steps: int = state.get("extra_damage_steps_this_round", 0)
		
		for pass_index in range(1 + extra_steps):
			# Intercept step processing if a player has been completely eradicated
			if pass_index > 0 and (_count_living_units(atk) == 0 or _count_living_units(def) == 0):
				break
				
			# Route arguments out to our dedicated damage evaluation processor cleanly
			_assess_damage_step(state, card_db, round_index, pass_index, token_pools, atk_card_id, def_card_id, on_event)

		# Clear link states at the end of the round context pipeline completely
		atk.erase("parent_state")
		def.erase("parent_state")
		state.erase("card_db")

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

	# Final Tiebreaker aggregates entire 3-round timeline mapping
	var final_atk_card_icons := _get_live_card_icons(atk, card_db, 2)
	var final_def_card_icons := _get_live_card_icons(def, card_db, 2)

	final_atk_morale = _calculate_current_morale_from_units(atk) + atk[Stat.MORALE] + final_atk_card_icons[2]
	final_def_morale = _calculate_current_morale_from_units(def) + def[Stat.MORALE] + final_def_card_icons[2]

	if on_event.is_valid():
		on_event.call("tiebreaker_morale", [final_atk_morale, final_def_morale])

	return final_atk_morale >= final_def_morale

#endregion

#region Assess Damage Step

## Evaluates and applies a single discrete damage pass calculation for the round
static func _assess_damage_step(state: Dictionary, card_db: Dictionary, round_index: int, pass_index: int, token_pools: Array, atk_card_id: int, def_card_id: int, on_event: Callable) -> void:
	var atk: Dictionary = state[Side.ATTACKER]
	var def: Dictionary = state[Side.DEFENDER]
	
	# 1. Gather true field state configurations dynamically
	var atk_card_icons := _get_live_card_icons(atk, card_db, round_index)
	var def_card_icons := _get_live_card_icons(def, card_db, round_index)
	
	# 2. Trigger centralized telemetry logging hooks if valid observer attached
	if on_event.is_valid():
		if pass_index > 0:
			on_event.call("ability_triggered", [atk_card_id, "--- BONUS ASSESS DAMAGE STEP PASS (Iteration %d) ---" % pass_index, "zap_icon" ])
			
		_log_phase_telemetry("damage_step", state, card_db, round_index, on_event, token_pools, atk_card_icons, def_card_icons)

	# 3. Compile tactical attribute modifications 
	var atk_ex: Array = atk.get("extra_icons", [0, 0, 0])
	var def_ex: Array = def.get("extra_icons", [0, 0, 0])

	# 4. Instantiate temporary calculation scratchpad vector
	var context := [0, 0, 0, 0, 0, 0] # [atk_atk, atk_def, def_atk, def_def, raw_atk_dmg, raw_def_dmg]
	context[0] = atk[Stat.OFFENCE] + atk_card_icons[0] + token_pools[0] + atk_ex[0] 
	context[1] = atk[Stat.DEFENCE] + atk_card_icons[1] + token_pools[1] + atk_ex[1] 
	context[2] = def[Stat.OFFENCE] + def_card_icons[0] + token_pools[2] + def_ex[0] 
	context[3] = def[Stat.DEFENCE] + def_card_icons[1] + token_pools[3] + def_ex[1] 

	# 5. Pipeline damage calculations across timeline timing windows
	_execute_timing_hook(CardData.TimingWindow.BEFORE_DAMAGE, state, context, round_index, card_db, on_event)

	if on_event.is_valid():
		on_event.call("damage_pre_calculated", ["Attacker", context[0], context[1]])
		on_event.call("damage_pre_calculated", ["Defender", context[2], context[3]])
	
	context[4] = max(0, context[0] - context[3]) 
	context[5] = max(0, context[2] - context[1]) 

	_execute_timing_hook(CardData.TimingWindow.DURING_DAMAGE, state, context, round_index, card_db, on_event)
	
	if on_event.is_valid():
		on_event.call("damage_resolved", ["Attacker", context[5]])
		on_event.call("damage_resolved", ["Defender", context[4]])

	# 6. Evaluate routing thresholds and write back state mutations
	var def_routing_lethal := _is_routing_lethal(atk_card_id, card_db, def)
	var atk_routing_lethal := _is_routing_lethal(def_card_id, card_db, atk)

	state["defender_newly_routed"] = apply_damage(def, context[4], round_index, def_routing_lethal, atk_card_id, on_event)
	state["attacker_newly_routed"] = apply_damage(atk, context[5], round_index, atk_routing_lethal, def_card_id, on_event)

	_execute_timing_hook(CardData.TimingWindow.AFTER_DAMAGE, state, context, round_index, card_db, on_event)

#endregion

#region Taking damage

static func apply_damage(player_state: Dictionary, total_damage: int, round_index: int, is_routing_lethal: bool, hostile_card_id: int, on_event: Callable) -> Array[Dictionary]:
	var squads: Array = player_state["squads"]
	var side_name: String = player_state["name"]
	var newly_routed_units: Array[Dictionary] = []
	
	#  THE IMMUNITY INTERCEPT: Check player state or parent state for the global immunity flag
	if is_damage_immunity_active(player_state):
		if on_event.is_valid():
			on_event.call("ability_triggered", [
				hostile_card_id, 
				"↳ Damage Immunity Active! All units on both sides are immune to damage this round.",
				"shield_icon"
			])
		return newly_routed_units # Exit immediately with 0 units routed or damaged

	# Fetch the round-scoped status flag directly from the state container
	var routing_prevented: bool = player_state.get("cannot_route", false)
	
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
				if routing_prevented:
					if on_event.is_valid():
						on_event.call("ability_triggered", [hostile_card_id, "↳ Show No Fear active! %s absorbs %d damage without routing." % [target_squad["name"], total_damage], "shield_icon"])
				else:
					# Redirect state updates and tracking filters through the unified helper loop
					_rout_unit(target_squad, target_idx, side_name, total_damage, newly_routed_units, on_event)
				
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
		
		# Protect passive threshold tracking lookups from registering false routes under active protection
		if not final_was_routed and not routing_prevented:
			newly_routed_units.append({"squad": final_squad, "index": final_idx})

		if hp_to_kill > total_damage and is_routing_lethal and not final_was_routed:
			if on_event.is_valid():
				on_event.call("ability_triggered", [hostile_card_id, "↳  AI executes healthy %s: Forced overkill because Routing is Lethal!" % final_squad["name"], "axe_icon"])

		total_damage -= hp_to_kill
		
		# Standardized figure destruction and memory cleanup pipeline pass
		_destroy_figure(final_squad, final_idx, side_name, on_event)
		
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

## Centralized bottleneck for all engine logging phases ("round_start" or "damage_step")
static func _log_phase_telemetry(phase: String, state: Dictionary, card_db: Dictionary, round_index: int, on_event: Callable, token_pools: Array = [], atk_icons: Array = [], def_icons: Array = []) -> void:
	var atk: Dictionary = state[Side.ATTACKER]
	var def: Dictionary = state[Side.DEFENDER]
	
	if atk_icons.is_empty() or def_icons.is_empty():
		atk_icons = _get_live_card_icons(atk, card_db, round_index)
		def_icons = _get_live_card_icons(def, card_db, round_index)
		
	match phase:
		"round_start":
			on_event.call("round_start", [round_index])
			log_current_army_statuses(state, on_event)
			log_current_dice_pools(on_event, atk, def, "round_start")
			log_current_extra_icons(on_event, atk["extra_icons"], def["extra_icons"], "round_start")
			log_current_unit_morale(on_event, atk, def, "round_start")
			log_current_card_icons(on_event, atk_icons, def_icons, "round_start")
			
			# Broadcast starting tokens out to UI panel slots
			if not token_pools.is_empty():
				_log_current_token_pools(on_event, token_pools, "round_start")
			
		"damage_step":
			on_event.call("assess_damage_step_start", [])
			log_current_army_statuses(state, on_event, "damage_step")
			log_current_dice_pools(on_event, atk, def, "damage_step")
			log_current_unit_morale(on_event, atk, def, "damage_step")
			log_current_extra_icons(on_event, atk["extra_icons"], def["extra_icons"], "damage_step")
			log_current_card_icons(on_event, atk_icons, def_icons, "damage_step")
			
			# Broadcast modified step tokens out to UI panel slots
			if not token_pools.is_empty():
				_log_current_token_pools(on_event, token_pools, "damage_step")

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

## Unpacks the engine's flat scratchpad array and dispatches separate UI update events per side
static func _log_current_token_pools(on_event: Callable, token_pools: Array, phase_context: String) -> void:
	if token_pools.size() < 4:
		return
		
	# Unpack and dispatch Attacker vector
	var atk_offence: int = token_pools[0]
	var atk_defence: int = token_pools[1]
	on_event.call("tokens_updated", [ "Attacker", atk_offence, atk_defence, phase_context ])
	
	# Unpack and dispatch Defender vector
	var def_offence: int = token_pools[2]
	var def_defence: int = token_pools[3]
	on_event.call("tokens_updated", [ "Defender", def_offence, def_defence, phase_context ])

#endregion

#region Helper Functions

static func _has_specific_dice(side_data: Dictionary, pool_type: int, amount: int) -> bool:
	if side_data.is_empty():
		return false
		
	var target_stat := Stat.OFFENCE
	match pool_type:
		2: # CardData.DicePoolType.DEFENSE
			target_stat = Stat.DEFENCE
		3: # CardData.DicePoolType.MORALE
			target_stat = Stat.MORALE
			
	return side_data.get(target_stat, 0) >= amount

static func get_token_amount(token_pools: Array, role: String, pool_type: int) -> int:
	if token_pools.size() < 4:
		return 0
		
	# Determine base position based on resolved role string
	var base_idx := 0 if role == "Attacker" else 2
	
	# Map pool_type to array offset (1 = Offence, 2 = Defence)
	var offset := 0 if pool_type == 1 else 1
	
	var target_idx := base_idx + offset
	if target_idx >= 0 and target_idx < token_pools.size():
		return int(token_pools[target_idx])
		
	return 0

static func _has_more_specific_dice_than_opponent(side_data: Dictionary, opp_side_data: Dictionary, pool_type: int) -> bool:
	var self_count := 0
	# Leverage your working helper to find the exact local count
	while _has_specific_dice(side_data, pool_type, self_count + 1):
		self_count += 1
		
	var opp_count := 0
	while _has_specific_dice(opp_side_data, pool_type, opp_count + 1):
		opp_count += 1
		
	return self_count > opp_count

static func _is_attacker(side: int) -> bool:
	return side == Side.ATTACKER

static func _get_live_card_icons(side_data: Dictionary, card_db: Dictionary, _up_to_round: int) -> Array[int]:
	var totals: Array[int] = [0, 0, 0] # [Offence, Defence, Morale]
	var play_area: Array = side_data.get("play_area", [])
	
	# Loop through every single card currently in the play area to capture dynamic additions!
	for i in range(play_area.size()):
		if play_area[i] != null:
			var card_id = play_area[i]
			var card_entry = card_db.get(card_id, [0, 0, 0])
			totals[0] += card_entry[0]
			totals[1] += card_entry[1]
			totals[2] += card_entry[2]
			
	return totals

static func _perform_rout_or_spend_tax(opp_side_data: Dictionary, opp_role: String, target_stat: int, target_label: String, penalty_amount: int, card_id: int, parent_state: Dictionary, on_event: Callable) -> void:
	if opp_side_data[target_stat] >= penalty_amount:
		opp_side_data[target_stat] -= penalty_amount
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ %s spent %d %s die/dice to not rout his units." % [opp_role, penalty_amount, target_label], "rally_icon"])
			on_event.call("dice_updated", [opp_role, opp_side_data[Stat.OFFENCE], opp_side_data[Stat.DEFENCE], opp_side_data[Stat.MORALE]])
	else:
		var target_unit := _find_lowest_tier_unrouted_unit(opp_side_data["squads"])
		if not target_unit.is_empty():
			var squad: Dictionary = target_unit["squad"]
			var idx: int = target_unit["index"]
			squad["figures_routed"][idx] = true
			
			if on_event.is_valid():
				on_event.call("ability_triggered", [card_id, "↳ Insufficient dice pool! Forced routing resolved on %s." % squad["name"], "axe_icon"])
				on_event.call("unit_routed", [opp_role, squad["name"], 0])
			
			log_current_army_statuses(parent_state, on_event, "damage_step")

static func _spend_die_to_continue(side_data: Dictionary, stat_key: int, amount: int, role: String, on_event: Callable) -> bool:
	if side_data[stat_key] < amount:
		return false
		
	side_data[stat_key] -= amount
	
	if on_event.is_valid():
		on_event.call("dice_updated", [role, side_data[Stat.OFFENCE], side_data[Stat.DEFENCE], side_data[Stat.MORALE]])
		
	return true

static func _rout_unit(squad: Dictionary, figure_idx: int, role: String, damage: int, newly_routed_units: Array, on_event: Callable) -> void:
	squad["figures_routed"][figure_idx] = true
	newly_routed_units.append({"squad": squad, "index": figure_idx})
	
	if on_event.is_valid():
		on_event.call("unit_routed", [role, squad["name"], damage])

static func _spawn_unit(side_data: Dictionary, unit_name: String, unit_type: int, tier: int, combat: int, health: int, morale: int, is_ship: bool) -> void:
	var new_unit_payload := {
		"name": unit_name, 
		"tier": tier, 
		"unit_type": unit_type,
		"is_ship": is_ship, 
		"combat_value": combat, 
		"health_value": health, 
		"morale_value": morale, 
		"alive_figures": [health],
		"figures_routed": [false]
	}
	side_data["squads"].append(new_unit_payload)

static func _check_card_unit_reqs_met(card_id: int, card_db: Dictionary, player_side: Dictionary) -> bool:
	if not card_db.has(card_id):
		return false
	var card_data: Array = card_db[card_id]
	var effects_list: Array = card_data[3]
	
	for fx in effects_list:
		if fx[4] == 1: # Unit Effect Type
			var req_types: Array = fx[5]
			# If the card specifies requirements, check them against current board state
			if not req_types.is_empty() and not _has_active_unit_type(player_side, req_types):
				return false
	return true

static func _destroy_figure(squad: Dictionary, figure_idx: int, role: String, on_event: Callable) -> void:
	# 1. Capture snapshot variables before changing data states
	var pre_death_hp: int = squad["alive_figures"][figure_idx]
	var pre_death_routed: bool = squad["figures_routed"][figure_idx]
	
	# 2. Enforce clean data state updates
	squad["alive_figures"][figure_idx] = 0
	squad["figures_routed"][figure_idx] = true
	
	# 3. Handle telemetry pipelines
	if on_event.is_valid():
		on_event.call("unit_destroyed", [role, squad["name"], pre_death_hp, pre_death_routed])


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

## Locates the living, unrouted unit structure displaying the absolute lowest tier
static func _find_lowest_tier_unrouted_unit(squads: Array) -> Dictionary:
	var target: Dictionary = {}
	var lowest_tier: int = 9999
	for squad in squads:
		for i in range(squad["alive_figures"].size()):
			if squad["alive_figures"][i] > 0 and not squad["figures_routed"][i]:
				if squad["tier"] < lowest_tier:
					lowest_tier = squad["tier"]
					target = {"squad": squad, "index": i}
	return target

## Find the highest tier figure slot that is currently alive and unrouted
static func _find_highest_tier_unrouted_unit(squads: Array) -> Dictionary:
	var best_squad: Dictionary = {}
	var best_idx := -1
	var best_tier := -1
	
	for squad in squads:
		var squad_tier = int(squad.get("tier", 0))
		for i in range(squad["alive_figures"].size()):
			if squad["alive_figures"][i] > 0 and not squad["figures_routed"][i]:
				if squad_tier > best_tier:
					best_tier = squad_tier
					best_squad = squad
					best_idx = i
					
	if best_idx != -1:
		return {"squad": best_squad, "index": best_idx, "tier": best_tier}
	return {}


## Find the highest tier figure slot that is currently alive and already routed
static func _find_highest_tier_routed_unit(squads: Array) -> Dictionary:
	var best_squad: Dictionary = {}
	var best_idx := -1
	var best_tier := -1
	
	for squad in squads:
		var squad_tier = int(squad.get("tier", 0))
		for i in range(squad["alive_figures"].size()):
			if squad["alive_figures"][i] > 0 and squad["figures_routed"][i]:
				if squad_tier > best_tier:
					best_tier = squad_tier
					best_squad = squad
					best_idx = i
					
	if best_idx != -1:
		return {"squad": best_squad, "index": best_idx, "tier": best_tier}
	return {}

static func _count_living_units(player_state: Dictionary) -> int:
	var count: int = 0
	for squad in player_state["squads"]:
		for hp in squad["alive_figures"]:
			if hp > 0: count += 1
	return count

## Counts total living unrouted figures currently active on the field state
static func _count_unrouted_units(side_data: Dictionary) -> int:
	var count := 0
	for squad in side_data["squads"]:
		for i in range(squad["alive_figures"].size()):
			if squad["alive_figures"][i] > 0 and not squad["figures_routed"][i]:
				count += 1
	return count

## Count if you have more unrouted units than opponent
static func _has_more_unrouted_units_than_opponent(side_data: Dictionary, opp_side_data: Dictionary) -> bool:
	return _count_unrouted_units(side_data) > _count_unrouted_units(opp_side_data)

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

static func _has_units(side_data: Dictionary) -> bool:
	for squad in side_data.get("squads", []):
		for hp in squad.get("alive_figures", []):
			if hp > 0:
				return true
	return false

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

static func _has_any_unrouted_units(side_data: Dictionary) -> bool:
	for squad in side_data["squads"]:
		for i in range(squad["alive_figures"].size()):
			if squad["alive_figures"][i] > 0 and not squad["figures_routed"][i]:
				return true
	return false

static func _has_reached_max_dice(side_data: Dictionary) -> bool:
	var side_dice: int = side_data[Stat.OFFENCE] + side_data[Stat.DEFENCE] + side_data[Stat.MORALE]
	return side_dice >= 8

## Opponent Logic: Finds the faceup card index with the LEAST total icons. Ties broken randomly.
static func _find_faceup_card_with_least_icons(side_data: Dictionary, card_db: Dictionary, ignored_index: int = -1) -> int:
	var play_area: Array = side_data.get("play_area", [])
	var valid_indices: Array[int] = []
	
	for i in range(play_area.size()):
		if i == ignored_index:
			continue
		if play_area[i] != null and int(play_area[i]) > 0:
			valid_indices.append(i)
			
	if valid_indices.is_empty():
		return -1
		
	var best_indices: Array[int] = []
	var min_icons := 999999
	
	for idx in valid_indices:
		var card_id = play_area[idx]
		var card_entry = card_db.get(card_id, [0, 0, 0])
		var total_icons: int = card_entry[0] + card_entry[1] + card_entry[2]
		
		if total_icons < min_icons:
			min_icons = total_icons
			best_indices = [idx]
		elif total_icons == min_icons:
			best_indices.append(idx)
			
	return best_indices[randi() % best_indices.size()]


## Player Logic: Finds the faceup card index with the MOST total icons. Ties broken randomly.
static func _find_faceup_card_with_most_icons(side_data: Dictionary, card_db: Dictionary, ignored_index: int = -1) -> int:
	var play_area: Array = side_data.get("play_area", [])
	var valid_indices: Array[int] = []
	
	for i in range(play_area.size()):
		if i == ignored_index:
			continue
		if play_area[i] != null and int(play_area[i]) > 0:
			valid_indices.append(i)
			
	if valid_indices.is_empty():
		return -1
		
	var best_indices: Array[int] = []
	var max_icons := -1
	
	for idx in valid_indices:
		var card_id = play_area[idx]
		var card_entry = card_db.get(card_id, [0, 0, 0])
		var total_icons: int = card_entry[0] + card_entry[1] + card_entry[2]
		
		if total_icons > max_icons:
			max_icons = total_icons
			best_indices = [idx]
		elif total_icons == max_icons:
			best_indices.append(idx)
			
	return best_indices[randi() % best_indices.size()]


static func add_specific_card_to_combat_deck(target_side_data: Dictionary, card_id: int) -> void:
	var deck: Array = target_side_data.get("combat_deck", [])
	deck.append(card_id)
	deck.shuffle()

static func has_specific_unit(side_data: Dictionary, unit_type: int) -> bool:
	for squad in side_data.get("squads", []):
		if int(squad.get("unit_type", -1)) == unit_type:
			for hp in squad.get("alive_figures", []):
				if hp > 0:
					return true
	return false

static func get_specific_unit_amount_in_this_combat(side_data: Dictionary, unit_type: int) -> int:
	var count := 0
	for squad in side_data.get("squads", []):
		if int(squad.get("unit_type", -1)) == unit_type:
			for hp in squad.get("alive_figures", []):
				if hp > 0:
					count += 1
	return count

static func count_specific_dice_amount(side_data: Dictionary, stat_type: int) -> int:
	return int(side_data.get(stat_type, 0))


static func count_tier_0_units(side_data: Dictionary) -> int:
	var count := 0
	var squads = side_data.get("squads", [])
	if squads is Array:
		for squad in squads:
			if squad is Dictionary and int(squad.get("tier", -1)) == 0:
				var alive_figs = squad.get("alive_figures", [])
				if alive_figs is Array:
					for hp in alive_figs:
						if int(hp) > 0:
							count += 1
	return count


static func _add_card_to_play_area(side_data: Dictionary, card_id: int, round_index: int = -1) -> void:
	if not side_data.has("play_area"):
		side_data["play_area"] = []
		
	var play_area = side_data["play_area"]
	
	if play_area is Array:
		if round_index >= 0:
			# Ensure the array is sized appropriately for explicit round slotting
			if play_area.size() <= round_index:
				play_area.resize(round_index + 1)
			play_area[round_index] = card_id
		else:
			# Dynamic injection via card ability (appends to the end of the timeline)
			play_area.append(card_id)
			
	elif play_area is Dictionary:
		if round_index >= 0:
			play_area[round_index] = card_id
		else:
			play_area[play_area.size()] = card_id

static func _draw_cards_from_combat_deck(target_side_data: Dictionary, amount: int) -> int:
	var deck: Array = target_side_data.get("combat_deck", [])
	var hand: Array = target_side_data.get("cards_in_hand", [])
	var actual_drawn := 0
	
	for i in range(amount):
		if not deck.is_empty():
			hand.append(deck.pop_at(0))
			actual_drawn += 1
			
	return actual_drawn

static func _discard_random_card_from_hand(target_side_data: Dictionary) -> int:
	var hand: Array = target_side_data.get("cards_in_hand", [])
	var deck: Array = target_side_data.get("combat_deck", [])
	
	if hand.is_empty():
		return -1
		
	# Extract a random card from hand safely
	var rand_idx := randi() % hand.size()
	var discarded_card_id: int = int(hand.pop_at(rand_idx))
	
	# Append back into the combat deck container and randomize the stack
	deck.append(discarded_card_id)
	deck.shuffle()
	
	return discarded_card_id

static func _discard_and_recycle_faceup_card(target_side_data: Dictionary, target_idx: int) -> int:
	var discarded_card_id: int = target_side_data["play_area"][target_idx]
	target_side_data["play_area"][target_idx] = 0
	
	# Reuse your existing working helper to tuck it back in safely
	add_specific_card_to_combat_deck(target_side_data, discarded_card_id)
	return discarded_card_id

## Safely extracts the active round tracker integer from the state structures
static func _get_current_combat_round_index(side_data: Dictionary) -> int:
	if side_data.is_empty():
		return 0
		
	# Route automatically if passed side_data or the master match_state directly
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return int(side_data.get("current_round_index", 0))
		
	return int(parent_state.get("current_round_index", 0))

## Centralized checker to determine if damage immunity is globally or locally active
static func is_damage_immunity_active(state_data: Dictionary) -> bool:
	if state_data.is_empty():
		return false
		
	# 1. Direct check (if player_state/side_data itself holds the flag)
	if state_data.get("all_units_damage_immune", false):
		return true
		
	# 2. Nested check (if player_state contains a parent_state holding the flag)
	var parent_state: Dictionary = state_data.get("parent_state", {})
	if not parent_state.is_empty() and parent_state.get("all_units_damage_immune", false):
		return true
		
	return false

static func has_tier_0_units(side_data: Dictionary) -> bool:
	var squads = side_data.get("squads", [])
	if squads is Array:
		for squad in squads:
			if squad is Dictionary and int(squad.get("tier", -1)) == 0:
				var alive_figs = squad.get("alive_figures", [])
				if alive_figs is Array:
					for hp in alive_figs:
						if int(hp) > 0:
							return true #  SHORT-CIRCUIT: Found an alive figure, stop checking!
	return false



#endregion

#region Passive helper functions

## Each time your opponent gains a token, gain the same token
## Processed immediately after Attacker finishes resolving their instant ability
static func _check_weirdboyz_after_attacker_resolves(state: Dictionary, round_index: int, token_pools: Array, pre_o: int, pre_d: int, on_event: Callable) -> void:
	var def_play_area: Array = state[Side.DEFENDER].get("play_area", [])
	var def_leech_active_from_past := false
	
	# Historical Scan: Defender only copies if Weirdboyz was active from a PRIOR round
	for i in range(round_index):
		if i < def_play_area.size() and def_play_area[i] == 3010:
			if state[Side.DEFENDER]["unit_abilities_unlocked"][i]:
				def_leech_active_from_past = true
				break
				
	if def_leech_active_from_past:
		var atk_delta_offence = token_pools[0] - pre_o
		var atk_delta_defence = token_pools[1] - pre_d
		
		if atk_delta_offence > 0 or atk_delta_defence > 0:
			token_pools[2] += atk_delta_offence
			token_pools[3] += atk_delta_defence
			if on_event.is_valid():
				on_event.call("ability_triggered", [3010, "↳ Psychic Leech (Aura): Mirrored Attacker instant tokens! Gained +%d ⚔️ and +%d 🛡️ tokens." % [atk_delta_offence, atk_delta_defence],"crystal_ball_icon"])
				on_event.call("tokens_updated", ["Defender", token_pools[2], token_pools[3]])

## Each time your opponent gains a token, gain the same token
## Processed immediately after Defender finishes resolving their instant ability
static func _check_weirdboyz_after_defender_resolves(state: Dictionary, round_index: int, token_pools: Array, pre_o: int, pre_d: int, on_event: Callable) -> void:
	var atk_play_area: Array = state[Side.ATTACKER].get("play_area", [])
	var atk_leech_active := false
	
	# Full Scan: Attacker copies if Weirdboyz is active from a prior round OR the current round
	for i in range(round_index + 1):
		if i < atk_play_area.size() and atk_play_area[i] == 3010:
			if state[Side.ATTACKER]["unit_abilities_unlocked"][i]:
				atk_leech_active = true
				break
				
	if atk_leech_active:
		var def_delta_offence = token_pools[2] - pre_o
		var def_delta_defence = token_pools[3] - pre_d
		
		if def_delta_offence > 0 or def_delta_defence > 0:
			token_pools[0] += def_delta_offence
			token_pools[1] += def_delta_defence
			if on_event.is_valid():
				on_event.call("ability_triggered", [3010, "↳ Psychic Leech (Aura): Mirrored Defender instant tokens! Gained +%d ⚔️ and +%d 🛡️ tokens." % [def_delta_offence, def_delta_defence], "crystal_ball_icon"])
				on_event.call("tokens_updated", ["Attacker", token_pools[0], token_pools[1]])

## Checks if the defense token suppression modifier is currently active on this side state
static func _is_cannot_gain_defense_tokens_active(side_data: Dictionary) -> bool:
	if side_data.is_empty():
		return false
	return side_data.get("cannot_gain_defense_tokens", false)

#endregion

#region Centralized Gain Dice and Gain tokens helpers

static func _add_dice_to_pool(target_side_data: Dictionary, target_role: String, requested_val: int, pool_type: int, card_id: int, original_side_data: Dictionary, on_event: Callable) -> void:
	# 1. Enforce the global 8-dice maximum cap constraint
	var current_total_dice: int = target_side_data[Stat.OFFENCE] + target_side_data[Stat.DEFENCE] + target_side_data[Stat.MORALE]
	var allowed_val: int = min(requested_val, 8 - current_total_dice)
	
	if allowed_val <= 0:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Gain skipped: %s is already at the maximum 8 dice cap." % target_role, "reroll_icon"])
		return
		
	if on_event.is_valid(): 
		on_event.call("ability_triggered", [card_id, "Resolved GAIN_DICE (Allowed: %d out of %d for %s)" % [allowed_val, requested_val, target_role], "dice_icon"])
		
	var b_offence := 0
	var b_defence := 0
	var b_morale := 0
	
	# 2. Route distribution logic: 0 = Random Roll, 1/2/3 = Specific Allocations
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
			
	# 3. Fire internal roll notifications
	if on_event.is_valid(): 
		on_event.call("bonus_dice_rolled", [target_role, b_offence, b_defence, b_morale])
	
	# 4. Commit values directly to target memory arrays
	target_side_data[Stat.OFFENCE] += b_offence
	target_side_data[Stat.DEFENCE] += b_defence
	target_side_data[Stat.MORALE] += b_morale

	# 5. Broadcast state modification to update visual UI panel numbers
	if on_event.is_valid():
		on_event.call("dice_updated", [target_role, target_side_data[Stat.OFFENCE], target_side_data[Stat.DEFENCE], target_side_data[Stat.MORALE]])

	# 6. Global master registry table dump print log
	var parent_state: Dictionary = original_side_data.get("parent_state", {})
	if not parent_state.is_empty() and on_event.is_valid():
		var atk_side: Dictionary = parent_state.get(Side.ATTACKER, {})
		var def_side: Dictionary = parent_state.get(Side.DEFENDER, {})
		
		if not atk_side.is_empty() and not def_side.is_empty():
			log_current_dice_pools(on_event, atk_side, def_side, "Dice Gain")

static func _remove_dice_from_pool(target_side_data: Dictionary, target_role: String, requested_val: int, pool_type: int, card_id: int, original_side_data: Dictionary, on_event: Callable) -> void:
	# Ensure the requested loss count is processed as a clean positive integer
	var raw_loss_count: int = abs(requested_val)
	
	var b_offence := 0
	var b_defence := 0
	var b_morale := 0
	
	# --- BRANCH A: RANDOM DICE LOSS (pool_type == 0) ---
	# Dynamically builds a lottery pool based ONLY on what the player currently has!
	if pool_type == 0:
		var active_dice_lottery: Array[int] = []
		for i in range(target_side_data[Stat.OFFENCE]): active_dice_lottery.append(1)
		for i in range(target_side_data[Stat.DEFENCE]): active_dice_lottery.append(2)
		for i in range(target_side_data[Stat.MORALE]):  active_dice_lottery.append(3)
		
		if active_dice_lottery.is_empty():
			if on_event.is_valid():
				on_event.call("ability_triggered", [card_id, "↳ Loss skipped: %s has no dice to lose." % target_role, "reroll_icon"])
			return
			
		var total_to_remove: int = min(raw_loss_count, active_dice_lottery.size())
		for d in range(total_to_remove):
			var random_idx := randi() % active_dice_lottery.size()
			match active_dice_lottery.pop_at(random_idx):
				1: b_offence += 1
				2: b_defence += 1
				3: b_morale += 1

	# --- BRANCH B: SPECIFIC DICE LOSS (1 = Off, 2 = Def, 3 = Morale) ---
	else:
		match pool_type:
			1: b_offence = min(raw_loss_count, target_side_data[Stat.OFFENCE])
			2: b_defence = min(raw_loss_count, target_side_data[Stat.DEFENCE])
			3: b_morale = min(raw_loss_count, target_side_data[Stat.MORALE])

	var total_dropped := b_offence + b_defence + b_morale
	if total_dropped <= 0:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Loss skipped: Specified pools on %s are already completely empty." % target_role, "reroll_icon"])
		return

	# Commit mutations safely (guaranteed never to drop below zero via our min checks above)
	target_side_data[Stat.OFFENCE] -= b_offence
	target_side_data[Stat.DEFENCE] -= b_defence
	target_side_data[Stat.MORALE] -= b_morale

	# Telemetry Pass
	if on_event.is_valid():
		var label_items: Array[String] = []
		if b_offence > 0: label_items.append("-%d ⚔️" % b_offence)
		if b_defence > 0: label_items.append("-%d 🛡️" % b_defence)
		if b_morale > 0:  label_items.append("-%d 🎖️" % b_morale)
		
		on_event.call("ability_triggered", [card_id, "Resolved LOSE_DICE: %s lost [%s]" % [target_role, ", ".join(label_items)], "dice_icon"])
		on_event.call("dice_updated", [target_role, target_side_data[Stat.OFFENCE], target_side_data[Stat.DEFENCE], target_side_data[Stat.MORALE]])

	# Master Table Print Dump Sync
	var parent_state: Dictionary = original_side_data.get("parent_state", {})
	if not parent_state.is_empty() and on_event.is_valid():
		var atk_side: Dictionary = parent_state.get(Side.ATTACKER, {})
		var def_side: Dictionary = parent_state.get(Side.DEFENDER, {})
		if not atk_side.is_empty() and not def_side.is_empty():
			log_current_dice_pools(on_event, atk_side, def_side, "Dice Loss")

static func _convert_dice_in_pool(target_side_data: Dictionary, target_role: String, max_to_convert: int, target_pool_type: int, card_id: int, original_side_data: Dictionary, on_event: Callable, source_pool_type: int = -1) -> void:
	var stat_map := {1: Stat.OFFENCE, 2: Stat.DEFENCE, 3: Stat.MORALE}
	if not target_pool_type in stat_map:
		return
		
	var target_stat = stat_map[target_pool_type]
	var converted_count := 0
	var stripped_counts := {Stat.OFFENCE: 0, Stat.DEFENCE: 0, Stat.MORALE: 0}

	# --- CORE CONVERSION LOOP ---
	for conversion in range(max_to_convert):
		var best_source_stat := -1
		
		#  Path A: Strict Source Pool Constraint Mode (e.g., Wraithguard Advance)
		if source_pool_type in stat_map:
			var constrained_stat = stat_map[source_pool_type]
			if target_side_data[constrained_stat] > 0 and constrained_stat != target_stat:
				best_source_stat = constrained_stat
		
		#  Path B: Generic Scavenger Mode (e.g., Blessed Power Armour)
		else:
			var max_available_dice := 0
			for src_stat in [Stat.OFFENCE, Stat.DEFENCE, Stat.MORALE]:
				if src_stat == target_stat:
					continue
				if target_side_data[src_stat] > max_available_dice:
					max_available_dice = target_side_data[src_stat]
					best_source_stat = src_stat
					
		# If no dice are left or source constraints aren't met, break out gracefully (handles 1-die scenarios)
		if best_source_stat == -1 or target_side_data[best_source_stat] <= 0:
			break
			
		target_side_data[best_source_stat] -= 1
		target_side_data[target_stat] += 1
		
		stripped_counts[best_source_stat] += 1
		converted_count += 1

	# --- TELEMETRY AND STATE SYNCHRONIZATION ---
	if converted_count > 0 and on_event.is_valid():
		var icons := {Stat.OFFENCE: "⚔️", Stat.DEFENCE: "🛡️", Stat.MORALE: "🎖️"}
		var breakdown_parts: Array[String] = []
		
		for stat_key in stripped_counts:
			if stripped_counts[stat_key] > 0:
				breakdown_parts.append("%d %s" % [stripped_counts[stat_key], icons[stat_key]])
				
		var summary_msg := "↳ Dice Conversion (%s): Converted %s into %d %s" % [
			target_role, 
			", ".join(breakdown_parts), 
			converted_count, 
			icons[target_stat]
		]
		on_event.call("ability_triggered", [card_id, summary_msg, "arrows_counterclockwise_icon"])
		
		on_event.call("dice_updated", [target_role, target_side_data[Stat.OFFENCE], target_side_data[Stat.DEFENCE], target_side_data[Stat.MORALE]])
		
		var parent_state: Dictionary = original_side_data.get("parent_state", {})
		if not parent_state.is_empty():
			var atk_side: Dictionary = parent_state.get(Side.ATTACKER, {})
			var def_side: Dictionary = parent_state.get(Side.DEFENDER, {})
			
			if not atk_side.is_empty() and not def_side.is_empty():
				log_current_dice_pools(on_event, atk_side, def_side, "Conversion")

static func _convert_dice_to_random_different_dice(target_side_data: Dictionary, target_role: String, max_to_convert: int, source_pool_type: int, card_id: int, original_side_data: Dictionary, on_event: Callable) -> void:
	var stat_map := {1: Stat.OFFENCE, 2: Stat.DEFENCE, 3: Stat.MORALE}
	if not source_pool_type in stat_map:
		return
		
	var source_stat = stat_map[source_pool_type]
	var current_source_dice: int = target_side_data[source_stat]
	
	# Determine how many dice can actually be modified based on what's physically available
	var actual_convert_count: int = min(max_to_convert, current_source_dice)
	
	if actual_convert_count <= 0:
		if on_event.is_valid():
			var labels := {1: "⚔️", 2: "🛡️", 3: "🎖️"}
			on_event.call("ability_triggered", [card_id, "↳ Conversion skipped: 0 %s dice available on %s's side." % [labels[source_pool_type], target_role], "reroll_icon"])
		return

	# --- EXCLUSION FILTER ---
	# Dynamically isolates the alternative stats (e.g., if converting Morale, filters to ONLY Offence and Defence)
	var alternative_stats: Array[int] = []
	for pool_key in stat_map.keys():
		if pool_key != source_pool_type:
			alternative_stats.append(stat_map[pool_key])

	var added_counts := {Stat.OFFENCE: 0, Stat.DEFENCE: 0, Stat.MORALE: 0}

	# 1. Deduct the whole target chunk safely up front
	target_side_data[source_stat] -= actual_convert_count

	# 2. Distribute randomly across remaining alternate pools
	for iteration in range(actual_convert_count):
		var chosen_stat: int = alternative_stats[randi() % alternative_stats.size()]
		target_side_data[chosen_stat] += 1
		added_counts[chosen_stat] += 1

	# --- TELEMETRY AND UI SYNC ---
	if on_event.is_valid():
		var labels := {Stat.OFFENCE: "⚔️", Stat.DEFENCE: "🛡️", Stat.MORALE: "🎖️"}
		var source_label: String = labels[source_stat]
		
		var breakdown_parts: Array[String] = []
		for stat_key in added_counts:
			if added_counts[stat_key] > 0:
				breakdown_parts.append("+%d %s" % [added_counts[stat_key], labels[stat_key]])
				
		var summary_msg := "↳ Dice Conversion (%s): Exchanged %d %s dice into alternative types -> %s" % [
			target_role, actual_convert_count, source_label, ", ".join(breakdown_parts)
		]
		on_event.call("ability_triggered", [card_id, summary_msg, "reroll_icon"])
		
		# Informs layout panels to immediately update screen numbers
		on_event.call("dice_updated", [target_role, target_side_data[Stat.OFFENCE], target_side_data[Stat.DEFENCE], target_side_data[Stat.MORALE]])

	# Global master system log window print statements
	var parent_state: Dictionary = original_side_data.get("parent_state", {})
	if not parent_state.is_empty() and on_event.is_valid():
		var atk_side: Dictionary = parent_state.get(Side.ATTACKER, {})
		var def_side: Dictionary = parent_state.get(Side.DEFENDER, {})
		
		if not atk_side.is_empty() and not def_side.is_empty():
			log_current_dice_pools(on_event, atk_side, def_side, "Conversion")

static func _reroll_dice_in_pool(target_side_data: Dictionary, target_role: String, val: int, pool_type: int, card_id: int, on_event: Callable) -> void:
	var current_o: int = target_side_data[Stat.OFFENCE]
	var current_d: int = target_side_data[Stat.DEFENCE]
	var current_m: int = target_side_data[Stat.MORALE]
	
	# Sentinel configuration: if value is -1, we clear out the entire target criteria footprint
	var is_all_flush := (val == -1)
	var actual_reroll_count := 0
	var removed_o := 0
	var removed_d := 0
	var removed_m := 0
	var pool_label := "random"
	
	# --- 1. EVALUATE TARGET POPULATION TO EXTRACTION POOLS ---
	if pool_type == 0: # CardData.DicePoolType.RANDOM
		var total_dice := current_o + current_d + current_m
		actual_reroll_count = total_dice if is_all_flush else min(val, total_dice)
		if actual_reroll_count <= 0:
			return
			
		var flat_pool: Array[int] = []
		for i in range(current_o): flat_pool.append(0)
		for i in range(current_d): flat_pool.append(1)
		for i in range(current_m): flat_pool.append(2)
		
		for iteration in range(actual_reroll_count):
			var picked_idx := randi() % flat_pool.size()
			match flat_pool.pop_at(picked_idx):
				0: removed_o += 1
				1: removed_d += 1
				2: removed_m += 1
	else: # Specific Target Pools (1 = Offense, 2 = Defense, 3 = Morale)
		match pool_type:
			1: # CardData.DicePoolType.OFFENSE
				actual_reroll_count = current_o if is_all_flush else min(val, current_o)
				removed_o = actual_reroll_count
				pool_label = "⚔️"
			2: # CardData.DicePoolType.DEFENSE
				actual_reroll_count = current_d if is_all_flush else min(val, current_d)
				removed_d = actual_reroll_count
				pool_label = "🛡️"
			3: # CardData.DicePoolType.MORALE
				actual_reroll_count = current_m if is_all_flush else min(val, current_m)
				removed_m = actual_reroll_count
				pool_label = "🎖️"
				
		if actual_reroll_count <= 0:
			if is_all_flush and on_event.is_valid():
				on_event.call("ability_triggered", [card_id, "↳ Reroll All skipped: %s has 0 %s dice." % [target_role, pool_label], "reroll_icon"])
			return

	# --- 2. TRANSACTIONAL ATOMIC UPDATE PHASE ---
	# Deduct from side data instantly
	target_side_data[Stat.OFFENCE] -= removed_o
	target_side_data[Stat.DEFENCE] -= removed_d
	target_side_data[Stat.MORALE] -= removed_m
	
	# Roll fresh replacements
	var added_o := 0
	var added_d := 0
	var added_m := 0
	
	for iteration in range(actual_reroll_count):
		match _roll_custom_die_index():
			0: added_o += 1
			1: added_d += 1
			2: added_m += 1
			
	# Inject newly rolled metrics back into tracking targets
	target_side_data[Stat.OFFENCE] += added_o
	target_side_data[Stat.DEFENCE] += added_d
	target_side_data[Stat.MORALE] += added_m

	# --- 3. TELEMETRY WRAP ---
	if on_event.is_valid():
		var log_prefix := "↳ Batch Roll Resolved %s:" % target_role if is_all_flush else "↳ 🎲 Tactical Reroll:"
		var summary_msg := "%s Selected %d %s dice (-%d⚔️, -%d🛡️, -%d🎖️). New results -> +%d ⚔️ | +%d 🛡️ | +%d 🎖️" % [
			log_prefix, actual_reroll_count, pool_label, removed_o, removed_d, removed_m, added_o, added_d, added_m
		]
		on_event.call("ability_triggered", [card_id, summary_msg, "dice_icon"])
		on_event.call("dice_updated", [target_role, target_side_data[Stat.OFFENCE], target_side_data[Stat.DEFENCE], target_side_data[Stat.MORALE]])


static func _get_token_index(role: String, token_type: int, target_opponent: bool) -> int:
	var is_attacker := (role == "Attacker")
	var subject_is_attacker := is_attacker if not target_opponent else not is_attacker
	
	var base_idx := 0 if subject_is_attacker else 2
	var offset := 0 if token_type == CardData.CombatTokenType.OFFENSE else 1
	
	return base_idx + offset

static func _validate_token_type(token_type: int) -> int:
	# 🛡️ STRICT EXPLICITNESS GUARD: Tokens must never map to dice pools like Morale
	assert(token_type == CardData.CombatTokenType.OFFENSE or token_type == CardData.CombatTokenType.DEFENSE,
		"CRITICAL ENGINE ERROR: Attempted to process a token transaction with an invalid token type (%d). Tokens must explicitly be CombatTokenType.OFFENSE or DEFENSE!" % token_type)
	return token_type

## Centralized bottleneck for modifying token pools safely across both players
static func _gain_or_lose_tokens(token_pools: Array, role: String, token_type: int, amount: int, is_opponent: bool = false, parent_state: Dictionary = {}) -> void:
	# Enforce explicit token type validation immediately at the boundary door
	var verified_type := _validate_token_type(token_type)
	
	# 🛡️ SUPPRESSION GUARD
	if amount > 0 and verified_type == CardData.CombatTokenType.DEFENSE and not parent_state.is_empty():
		var is_attacker := (role == "Attacker")
		var subject_is_attacker := is_attacker if not is_opponent else not is_attacker
		var target_side_key = Side.ATTACKER if subject_is_attacker else Side.DEFENDER
		var target_side_data: Dictionary = parent_state.get(target_side_key, {})
		
		if target_side_data.get("cannot_gain_defense_tokens", false):
			return

	# Pass the fully validated token type downstream safely
	var token_idx := _get_token_index(role, verified_type, is_opponent)
	
	if token_idx >= 0 and token_idx < token_pools.size():
		token_pools[token_idx] = max(0, token_pools[token_idx] + amount)

#endregion

#region Timing Hook (IMPORTANT)

static func _execute_timing_hook(window: int, state: Dictionary, _context: Array, round_index: int, card_db: Dictionary, on_event: Callable) -> void:
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
						# FIXED: Read directly from our immutable play-time validation snapshot
						var history: Array = side["player"].get("unit_abilities_unlocked", [false, false, false])
						if not history[round_index]:
							continue # Skipped if requirements weren't met at the start of the round
					
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
								on_event.call("ability_triggered", [active_card_id, "Passive Threat Snapped: Ambush conditions met! Demanding survival ransoms.", "boom_icon"])
								master_header_logged = true
								
							var opponent_side: Dictionary = side["opponent"]
							
							if opponent_side.get(side["opp_stat_morale"], 0) >= ransom_cost:
								opponent_side[side["opp_stat_morale"]] -= ransom_cost
								
								if on_event.is_valid():
									on_event.call("ability_triggered", [active_card_id, "↳ Opponent spends %d Morale die ransom! %s figure survives." % [ransom_cost, squad["name"]], "rally_icon"])
							else:
								if on_event.is_valid():
									on_event.call("ability_triggered", [active_card_id, "↳ Ransom unpaid! Instant execution resolved on %s." % squad["name"], "axe_icon"])
								
								_destroy_figure(squad, idx, side["opp_role"], on_event)

#endregion

#region Effect Resolvers database (IMPORTANT)

# Resolvers for instant effects
static var EFFECT_RESOLVERS = {
	CardData.EffectType.CHOICE: _execute_choice_selection,
	CardData.EffectType.CONDITIONAL: _execute_generic_conditional,
	
	CardData.EffectType.GAIN_DICE: _execute_gain_dice,
	CardData.EffectType.GAIN_SPECIFIC_DICE: _execute_gain_specific_dice,
	CardData.EffectType.LOSE_DICE: _execute_lose_dice,
	CardData.EffectType.LOSE_SPECIFIC_DICE: _execute_lose_specific_dice,
	CardData.EffectType.CONVERT_DICE_TO_SPECIFIC_DICE: _execute_convert_dice_to_specific_dice,
	CardData.EffectType.CONVERT_DICE_TO_RANDOM_DIFFERENT_DICE: _execute_convert_dice_to_random_different_dice,
	CardData.EffectType.REROLL: _execute_reroll,
	CardData.EffectType.REROLL_ALL_SPECIFIC_DICE: _execute_reroll_all_specific_dice,
	CardData.EffectType.REROLL_SPECIFIC_DICE_FOR_EACH_UNIT: _execute_reroll_specific_dice_for_each_unit,
	CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS: _execute_spend_specific_dice_to_gain_tokens,
	
	CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS: _execute_gain_or_lose_combat_tokens,
	CardData.EffectType.GAIN_TOKEN_PER_SPECIFIC_DICE: _execute_gain_token_per_specific_dice,
	CardData.EffectType.GAIN_TOKEN_PER_UNROUTED_UNIT: _execute_gain_token_per_unrouted_unit,
	
	CardData.EffectType.RALLY: _execute_rally, 
	CardData.EffectType.RALLY_ALL_FRIENDLY_UNITS: _execute_rally_all_friendly_units,
	
	CardData.EffectType.ROUT_LOWEST_TIER: _execute_rout_lowest_tier,
	CardData.EffectType.ROUT_LOWEST_TIER_OR_SPEND_DICE: _execute_rout_lowest_tier_or_spend_dice_unconditional,
	CardData.EffectType.ROUT_HIGHEST_TIER: _execute_rout_highest_tier,
	
	CardData.EffectType.DRAW_COMBAT_CARDS: _execute_draw_combat_cards,
	CardData.EffectType.DISCARD_RANDOM_CARD_FROM_HAND: _execute_discard_random_card_from_hand,
	CardData.EffectType.DISCARD_WORST_FACEUP_CARD: _execute_discard_worst_faceup_card,
	CardData.EffectType.DISCARD_BEST_FACEUP_CARD: _execute_discard_best_faceup_card,
	CardData.EffectType.DISCARD_STEAL_ICONS: _execute_discard_steal_icons,
	CardData.EffectType.PLAY_RANDOM_CARD_DO_NOT_RESOLVE_ABILITIES: _execute_play_random_card_do_not_resolve_abilities,
	
	
	CardData.EffectType.SPAWN_UNIT: _execute_spawn_unit,
	CardData.EffectType.SPAWN_REINFORCEMENT_TOKEN: _execute_spawn_reinforcement_token,
	
	CardData.EffectType.DESTROY_LOWEST_TIER: _execute_destroy_lowest_tier,
	CardData.EffectType.DESTROY_HIGHEST_TIER_ROUTED_UNIT: _execute_destroy_highest_tier_routed_unit,
	
	
	# SM
	CardData.EffectType.PREVENT_ROUTING_THIS_ROUND: _execute_prevent_routing_this_round, # Show No Fear
	CardData.EffectType.ADDITIONAL_ASSESS_DAMAGE_STEP_THIS_ROUND: _execute_additional_assess_damage_step_this_round, # Armoured Advance
	CardData.EffectType.CONVERT_SAFE_DICE_TO_MORALE: _execute_convert_safe_dice_to_morale, # Emperor's Glory
	
	# CSM
	CardData.EffectType.CHAOS_UNITED_UNIT_ABILITY: _execute_chaos_united_unit_ability, # Chaos United
	CardData.EffectType.DEATH_AND_DESPAIR_GENERAL_ABILITY_2: _execute_death_and_despair_general_ability_2, # Death and Despair
	CardData.EffectType.ROUT_ALL_COMMAND_LEVEL_0_UNITS: _execute_rout_all_command_level_0_units, # Chaos Victorious
	
	# ORK
	CardData.EffectType.DESTROY_OR_SPEND_DICE_BASED_ON_TIER: _execute_destroy_or_spend_dice_based_on_tier, # Smasher Gargant
	
	# Eldar
	CardData.EffectType.PREVENT_OPPONENT_GAINING_DEFENSE_TOKENS_THIS_ROUND: _execute_prevent_opponent_gaining_defense_tokens_this_round,
	CardData.EffectType.ALL_UNITS_GAIN_DAMAGE_IMMUNITY_THIS_ROUND: _execute_all_units_gain_damage_immunity_this_round,
}

#endregion


#region Main Resolvers (IMPORTANT)

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
				on_event.call("ability_triggered", [active_card_id, "Passive Threat Primed: Any units routed this round face destruction!", "warning_icon"])

		if not is_unit_fx and not general_phase_started:
			general_phase_started = true
			if on_event.is_valid(): on_event.call("ability_block_started", [role_label, "General"])
		elif is_unit_fx and not unit_phase_started:
			unit_phase_started = true
			if on_event.is_valid(): on_event.call("ability_block_started", [role_label, "Unit"])
		
		if EFFECT_RESOLVERS.has(effect_type):
			EFFECT_RESOLVERS[effect_type].call(fx, token_pools, side_data, role_label, active_card_id, has_valid_units, on_event)
		else:
			if effect_type != CardData.EffectType.DESTROY_ON_ROUT_OR_SPEND \
			and effect_type != CardData.EffectType.MIRROR_OPPONENT_TOKEN_GAINS:
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
			on_event.call("ability_triggered", [card_id, "↳ Tactical Choice: %s elected to pass on their optional action." % role, "brain_icon"])
		return

	if EFFECT_RESOLVERS.has(sub_effect_type):
		EFFECT_RESOLVERS[sub_effect_type].call(chosen_sub_fx, token_pools, side_data, role, card_id, units_valid, on_event)

#endregion

#region Condition selector (IMPORTANT)

static func _execute_generic_conditional(fx: Array, token_pools: Array, side_data: Dictionary, role: String, card_id: int, units_valid: bool, on_event: Callable) -> void:
	var sub_effects: Array = fx[2]
	var condition_rule: int = fx[7] if fx.size() > 7 else 0
	var else_effects: Array = fx[10] if fx.size() > 10 else [] # Grab our flattened fallback track
	
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return
		
	var is_attacker := (role == "Attacker")
	var opp_side_data: Dictionary = parent_state.get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
	
	# Pre-calculate opponent token index parameters for our conditions
	var opp_role := "Defender" if is_attacker else "Attacker"
	var _opp_base_idx := 0 if opp_role == "Attacker" else 2

	var condition_passed := false
	match condition_rule:
		CardData.ConditionType.OUTNUMBERING:
			condition_passed = _has_more_unrouted_units_than_opponent(side_data, opp_side_data)
		CardData.ConditionType.IS_ATTACKING:
			condition_passed = is_attacker
		CardData.ConditionType.IS_DEFENDING:
			condition_passed = not is_attacker
		
		# --- PLAYER DICE POOL CHECKS ---
		CardData.ConditionType.HAS_OFFENCE_DICE:
			condition_passed = _has_specific_dice(side_data, 1, 1)
		CardData.ConditionType.HAS_NO_OFFENCE_DICE:
			condition_passed = not _has_specific_dice(side_data, 1, 1)
		CardData.ConditionType.HAS_DEFENCE_DICE:
			condition_passed = _has_specific_dice(side_data, 2, 1)
		CardData.ConditionType.HAS_NO_DEFENCE_DICE:
			condition_passed = not _has_specific_dice(side_data, 2, 1)
		CardData.ConditionType.HAS_MORALE_DICE:
			condition_passed = _has_specific_dice(side_data, 3, 1)
		CardData.ConditionType.HAS_NO_MORALE_DICE:
			condition_passed = not _has_specific_dice(side_data, 3, 1)
			
		# --- OPPONENT DICE POOL CHECKS ---
		CardData.ConditionType.OPPONENT_HAS_OFFENCE_DICE:
			condition_passed = _has_specific_dice(opp_side_data, 1, 1)
		CardData.ConditionType.OPPONENT_HAS_NO_OFFENCE_DICE:
			condition_passed = not _has_specific_dice(opp_side_data, 1, 1)
		CardData.ConditionType.OPPONENT_HAS_DEFENCE_DICE:
			condition_passed = _has_specific_dice(opp_side_data, 2, 1)
		CardData.ConditionType.OPPONENT_HAS_NO_DEFENCE_DICE:
			condition_passed = not _has_specific_dice(opp_side_data, 2, 1)
		CardData.ConditionType.OPPONENT_HAS_MORALE_DICE:
			condition_passed = _has_specific_dice(opp_side_data, 3, 1)
		CardData.ConditionType.OPPONENT_HAS_NO_MORALE_DICE:
			condition_passed = not _has_specific_dice(opp_side_data, 3, 1)
		
		CardData.ConditionType.HAS_MORE_MORALE_THAN_OPPONENT:
			condition_passed = _has_more_specific_dice_than_opponent(side_data, opp_side_data, 3)
		
		# --- PLAYER UNIT STATUS CHECKS ---
		CardData.ConditionType.HAS_UNITS:
			condition_passed = _has_units(side_data)
		CardData.ConditionType.HAS_ROUTED_UNITS:
			condition_passed = _has_any_routed_units(side_data)
		CardData.ConditionType.HAS_NO_ROUTED_UNITS:
			condition_passed = not _has_any_routed_units(side_data)
		CardData.ConditionType.HAS_UNROUTED_UNITS:
			condition_passed = _has_any_unrouted_units(side_data)
		CardData.ConditionType.HAS_NO_UNROUTED_UNITS:
			condition_passed = not _has_any_unrouted_units(side_data)
			
		# --- OPPONENT UNIT STATUS CHECKS ---
		CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS:
			condition_passed = _has_any_routed_units(opp_side_data)
		CardData.ConditionType.OPPONENT_HAS_NO_ROUTED_UNITS:
			condition_passed = not _has_any_routed_units(opp_side_data)
		CardData.ConditionType.OPPONENT_HAS_UNROUTED_UNITS:
			condition_passed = _has_any_unrouted_units(opp_side_data)
		CardData.ConditionType.OPPONENT_HAS_NO_UNROUTED_UNITS:
			condition_passed = not _has_any_unrouted_units(opp_side_data)
		
		CardData.ConditionType.HAS_TIER_0_UNITS:
			condition_passed = has_tier_0_units(side_data)
		
		# --- FACTION SPECIFIC ATOMIC CHECKS ---
		CardData.ConditionType.OPPONENT_HAS_TWO_OR_MORE_DEFENSE_TOKENS:
			condition_passed = get_token_amount(token_pools, opp_role, 2) >= 2
		CardData.ConditionType.OPPONENT_HAS_FEWER_THAN_TWO_DEFENSE_TOKENS:
			condition_passed = get_token_amount(token_pools, opp_role, 2) < 2
		CardData.ConditionType.HAS_CULTISTS:
			condition_passed = has_specific_unit(side_data, CardData.UnitType.CULTISTS)
		CardData.ConditionType.CANNOT_GAIN_DEFENSE_TOKENS_THIS_ROUND_IS_ACTIVE:
			condition_passed = _is_cannot_gain_defense_tokens_active(side_data)
		CardData.ConditionType.CANNOT_GAIN_DEFENSE_TOKENS_THIS_ROUND_IS_NOT_ACTIVE:
			condition_passed = not _is_cannot_gain_defense_tokens_active(side_data)
		CardData.ConditionType.IS_FIRST_COMBAT_ROUND:
			condition_passed = (_get_current_combat_round_index(side_data) == 0)
		CardData.ConditionType.IS_NOT_FIRST_COMBAT_ROUND:
			condition_passed = not (_get_current_combat_round_index(side_data) == 0)
		CardData.ConditionType.ALL_UNITS_HAVE_DAMAGE_IMMUNITY:
			condition_passed = is_damage_immunity_active(side_data)
		
		_:
			condition_passed = true
			
	if condition_passed:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Executing inner abilities.", "inner_ability_icon"])
		
		for sub_fx in sub_effects:
			var sub_effect_type: int = sub_fx[0]
			if EFFECT_RESOLVERS.has(sub_effect_type):
				EFFECT_RESOLVERS[sub_effect_type].call(sub_fx, token_pools, side_data, role, card_id, units_valid, on_event)
	else:
		#  THE ELSE BRANCH PIPELINE
		if not else_effects.is_empty():
			if on_event.is_valid():
				on_event.call("ability_triggered", [card_id, "↳ Checking fallback conditions.", "fallback_condition_icon"])
			
			for else_fx in else_effects:
				var else_effect_type: int = else_fx[0]
				if EFFECT_RESOLVERS.has(else_effect_type):
					EFFECT_RESOLVERS[else_effect_type].call(else_fx, token_pools, side_data, role, card_id, units_valid, on_event)
		else:
			# Default fallback when no else branch is provided
			if on_event.is_valid():
				on_event.call("ability_triggered", [card_id, "↳ Conditions not fulfilled. Ability skipped.", "x_icon"])

#endregion


#region Generic Dice functions
# --- GENERIC RANDOM DICE EXECUTOR ---
static func _execute_gain_dice(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	if fx[2] is Array: return
	var target_type: int = fx[1]
	var requested_val: int = fx[2]
	
	var target_side_data := side_data
	var target_role := role
	if target_type != 0:
		target_role = "Defender" if role == "Attacker" else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if role == "Attacker" else Side.ATTACKER, {})
		
	if target_side_data.is_empty(): return

	# Pass '0' as pool_type to trigger the random dice rolling branches safely!
	_add_dice_to_pool(target_side_data, target_role, requested_val, 0, card_id, side_data, on_event)


# --- SPECIFIC DICE TYPE EXECUTOR ---
static func _execute_gain_specific_dice(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	if fx[2] is Array: return
	var target_type: int = fx[1]
	var requested_val: int = fx[2]
	var pool_type: int = fx[3] # 1 = Offence, 2 = Defence, 3 = Morale
	
	var target_side_data := side_data
	var target_role := role
	if target_type != 0:
		target_role = "Defender" if role == "Attacker" else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if role == "Attacker" else Side.ATTACKER, {})
		
	if target_side_data.is_empty(): return

	# Passes the exact requested pool_type directly through
	_add_dice_to_pool(target_side_data, target_role, requested_val, pool_type, card_id, side_data, on_event)

static func _execute_lose_dice(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	if fx[2] is Array: return
	var target_type: int = fx[1]
	var requested_val: int = fx[2]
	
	var target_side_data := side_data
	var target_role := role
	if target_type != 0:
		target_role = "Defender" if role == "Attacker" else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if role == "Attacker" else Side.ATTACKER, {})
		
	if target_side_data.is_empty(): return

	# Pass '0' as pool_type to trigger the random lottery loss branch safely!
	_remove_dice_from_pool(target_side_data, target_role, requested_val, 0, card_id, side_data, on_event)

static func _execute_lose_specific_dice(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	if fx[2] is Array: return
	var target_type: int = fx[1]
	var requested_val: int = fx[2] # Accept numbers normally (e.g. 1 means drop 1 die)
	var pool_type: int = fx[3]     # 0 = Random, 1 = Off, 2 = Def, 3 = Morale
	
	# --- SYSTEM ROUTING ---
	var target_side_data := side_data
	var target_role := role
	if target_type != 0: # Target Opponent
		target_role = "Defender" if role == "Attacker" else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if role == "Attacker" else Side.ATTACKER, {})
		
	if target_side_data.is_empty(): return
	# ----------------------

	# Pipe directly through the subtraction pipeline
	_remove_dice_from_pool(target_side_data, target_role, requested_val, pool_type, card_id, side_data, on_event)

static func _execute_convert_dice_to_specific_dice(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var target_type: int = fx[1]      # fx[1] = target_type (0 = SELF, 1 = OPPONENT)
	var max_to_convert: int = fx[2]   # fx[2] = count values limit
	var target_pool_type: int = fx[3] # fx[3] = pool target category type
	var source_pool_type: int = fx[6] if fx.size() > 6 else -1 #  Index 6 extracts strict source constraints
	
	var is_attacker := (role == "Attacker")
	var targets_self := (target_type == 0)
	
	# --- SYSTEM ROUTING ---
	var target_side_data := side_data
	var target_role := role
	if not targets_self:
		target_role = "Defender" if is_attacker else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
		
	if target_side_data.is_empty():
		return

	# Handoff operations along with the source restriction configuration downstream
	_convert_dice_in_pool(target_side_data, target_role, max_to_convert, target_pool_type, card_id, side_data, on_event, source_pool_type)

static func _execute_convert_dice_to_random_different_dice(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	if fx[2] is Array: return
	var target_type: int = fx[1]      # fx[1] = target_type (0 = SELF, 1 = OPPONENT)
	var max_to_convert: int = fx[2]   # fx[2] = count values limit
	var source_pool_type: int = fx[3] # fx[3] = source pool to convert FROM (e.g., 3 = Morale)
	
	var is_attacker := (role == "Attacker")
	var targets_self := (target_type == 0)
	
	# --- SYSTEM ROUTING ---
	var target_side_data := side_data
	var target_role := role
	if not targets_self:
		target_role = "Defender" if is_attacker else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
		
	if target_side_data.is_empty():
		return
	# ----------------------

	# Handoff operations entirely to the decoupled central alternative conversion pipeline
	_convert_dice_to_random_different_dice(target_side_data, target_role, max_to_convert, source_pool_type, card_id, side_data, on_event)

static func _execute_reroll(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	if fx[2] is Array:
		return
		
	var val: int = fx[2]           # Count value or -1 sentinel indicator value
	var target_type: int = fx[1]   # 0 = Self, 1 = Opponent
	var pool_type: int = fx[3] if fx.size() > 3 else 0
	
	var is_attacker := (role == "Attacker")
	var targets_self := (target_type == 0)
	
	# --- SYSTEM ROUTING ---
	var target_side_data: Dictionary = side_data
	var target_role := role
	if not targets_self:
		target_role = "Defender" if is_attacker else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
		
	if target_side_data.is_empty():
		return
	# ----------------------

	# Handoff operations entirely to the centralized helper manager pipeline
	_reroll_dice_in_pool(target_side_data, target_role, val, pool_type, card_id, on_event)


static func _execute_reroll_all_specific_dice(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var target_type: int = fx[1] # fx[1] = target_type (0 = SELF, 1 = OPPONENT)
	var pool_type: int = fx[3]   # fx[3] = pool_type (1 = Offence, 2 = Defence, 3 = Morale)
	
	var targets_self: bool = (target_type == 0)
	
	# --- SYSTEM ROUTING ---
	var target_side_data := side_data
	var target_role := role
	if not targets_self:
		var is_attacker := (role == "Attacker")
		target_role = "Defender" if is_attacker else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
		
	if target_side_data.is_empty():
		return
	# ----------------------

	_reroll_dice_in_pool(target_side_data, target_role, -1, pool_type, card_id, on_event)

static func _execute_reroll_specific_dice_for_each_unit(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var target_type: int = fx[1]      # fx[1] = target_type (0 = SELF, 1 = OPPONENT)
	var target_unit_type: int = fx[2] # fx[2] = unit_type ID to scan and scale from
	var pool_type: int = fx[3]        # fx[3] = pool_type (1 = Offence, 2 = Defence, 3 = Morale)
	
	var is_attacker := (role == "Attacker")
	var targets_self := (target_type == 0)
	
	# --- SYSTEM ROUTING ---
	var caster_side := side_data
	var opponent_side: Dictionary = side_data.get("parent_state", {}).get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
	
	if opponent_side.is_empty():
		return

	# Preserves the exact functional relationship of your original rule setup:
	# - Targeting Opponent: Scans Caster units to Reroll Opponent dice.
	# - Targeting Self: Scans Opponent units to Reroll Caster dice.
	var scanned_side_data := caster_side if not targets_self else opponent_side
	var reroll_side_data := opponent_side if not targets_self else caster_side
	var reroll_role := ("Defender" if is_attacker else "Attacker") if not targets_self else role

	# --- 1. UNIT SCALING ANALYSIS ---
	var unit_count := 0
	for squad in scanned_side_data.get("squads", []):
		var squad_type: int = int(squad.get("unit_type", 0))
		if squad_type == target_unit_type:
			# Adheres to your 1-man-per-entry individual figure tracking design
			for i in range(squad.get("alive_figures", []).size()):
				if squad["alive_figures"][i] > 0 and not squad["figures_routed"][i]:
					unit_count += 1
					
	if unit_count <= 0:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Disruptive Presence failed: No active scaling units found.", "x_icon"])
		return

	if on_event.is_valid():
		on_event.call("ability_triggered", [card_id, "↳ Disruptive Presence: Scanned %d active scaling unit(s)." % unit_count, "scan_icon"])

	# --- 2. PIPED THROUGH CENTRAL HELPER ---
	_reroll_dice_in_pool(reroll_side_data, reroll_role, unit_count, pool_type, card_id, on_event)

#endregion


#region Generic Token functions

static func _execute_gain_or_lose_combat_tokens(fx: Array, token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	if fx[2] is Array:
		return
		
	var target_type: int = fx[1]   # fx[1] = target_type
	var val: int = fx[2]           # fx[2] = value (Can be positive or negative!)
	var pool_type: int = fx[3]     # fx[3] = pool_type (Maps to token enum value at Index 3)
	
	var is_opponent: bool = (target_type != 0)
	
	# 1. Resolve true target identities for precise telemetry logs
	var target_role := role
	if is_opponent:
		target_role = "Defender" if role == "Attacker" else "Attacker"
		
	#  Type Validation: Align log outputs with strict CombatTokenType enum rules
	var effective_token := _validate_token_type(pool_type)
	var label := "Offence" if effective_token == CardData.CombatTokenType.OFFENSE else "Defence"
	
	# 2. Dynamic Telemetry formatting based on token sign direction
	if on_event.is_valid():
		if val >= 0:
			on_event.call("ability_triggered", [card_id, "Resolved GAIN_COMBAT_TOKEN: %s gained +%d %s Token(s)." % [target_role, val, label], "token_icon"])
		else:
			on_event.call("ability_triggered", [card_id, "Resolved LOSE_COMBAT_TOKEN: %s lost %d %s Token(s)." % [target_role, abs(val), label], "token_icon"])
		
	# 3. Piped through your central helper WITH the required parent state payload
	var parent_state: Dictionary = side_data.get("parent_state", {})
	_gain_or_lose_tokens(token_pools, role, effective_token, val, is_opponent, parent_state)

	# 4. Broadcast master state update to sync visual UI counters
	if on_event.is_valid():
		var target_base_idx := 0 if target_role == "Attacker" else 2
		on_event.call("tokens_updated", [target_role, token_pools[target_base_idx], token_pools[target_base_idx + 1]])

static func _execute_gain_token_per_specific_dice(fx: Array, token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var target_type: int = fx[1]                                    # fx[1] = target_type (0 = SELF, 1 = OPPONENT)
	var multiplier: int = int(fx[2])                               # fx[2] = value (multiplier)
	var source_pool_type: int = int(fx[3])                          # fx[3] = pool_type to scan
	var target_token_type: int = int(fx[6]) if fx.size() > 6 else 0 # fx[6] = token type to award (0 = RANDOM)
	
	# --- 1. SYSTEM ROUTING ---
	var is_attacker := (role == "Attacker")
	var targets_self := (target_type == 0)
	
	var target_side_data := side_data
	var target_role := role
	var is_opponent := not targets_self
	
	if is_opponent:
		target_role = "Defender" if is_attacker else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
		
	if target_side_data.is_empty():
		return

	# --- 2. MAP SOURCE DICE POOL ---
	var source_stat := Stat.OFFENCE
	var source_label := "Offence ⚔️"
	
	match source_pool_type:
		CardData.DicePoolType.DEFENSE:
			source_stat = Stat.DEFENCE
			source_label = "Defence 🛡️"
		CardData.DicePoolType.MORALE:
			source_stat = Stat.MORALE
			source_label = "Morale 🎖️"

	# Scan the resolved target's board state
	var current_dice: int = target_side_data.get(source_stat, 0)
	if current_dice <= 0:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Scaling failed: 0 %s dice in %s's pool." % [source_label, target_role], "x_icon"])
		return
		
	var total_allocations := current_dice * multiplier
	if total_allocations <= 0:
		return

	# --- 3. PROCESS REWARD TOKEN ROUTING ---
	var chosen_token_type := target_token_type
	if chosen_token_type == 0: # RANDOM choice evaluation
		chosen_token_type = CardData.CombatTokenType.OFFENSE if (randi() % 2 == 0) else CardData.CombatTokenType.DEFENSE
		
	#  Type Validation: Protect telemetry layers from cross-enum garbage
	var verified_token := _validate_token_type(chosen_token_type)
	var token_label := "Offence" if verified_token == CardData.CombatTokenType.OFFENSE else "Defence"

	# --- 4. PIPED THROUGH CENTRAL HELPER WITH PASSED STATE CONTEXT ---
	var parent_state: Dictionary = side_data.get("parent_state", {})
	_gain_or_lose_tokens(token_pools, role, verified_token, total_allocations, is_opponent, parent_state)

	# --- 5. CONSOLIDATED TELEMETRY PASS ---
	if on_event.is_valid():
		on_event.call("ability_triggered", [card_id, "↳ Scanned %d %s dice on %s's side (x%d payout). Awarded +%d %s token(s)." % [current_dice, source_label, target_role, multiplier, total_allocations, token_label], "scan_icon"])
		
		# Dynamically resolve index base offsets to update the correct visual component panels
		var target_base_idx := 0 if target_role == "Attacker" else 2
		on_event.call("tokens_updated", [target_role, token_pools[target_base_idx], token_pools[target_base_idx + 1]])


## Consumes all available dice of a specified type to generate tokens.
static func _execute_spend_specific_dice_to_gain_tokens(fx: Array, token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	# --- 1. STRICT SPECIFICATION CHECK (FAIL FAST) ---
	assert(fx.size() > 9 and fx[9] > 0, "CRITICAL ARCHITECTURE ERROR: Card ID %d executed 'SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS' but forgot to specify an explicit payout token type at Index 9 (gain_token_type)!" % card_id)
	
	var token_multiplier: int = fx[2]
	var pool_type: int = fx[3]
	var max_spend: int = fx[6] if fx.size() > 6 else -1
	var gain_token_type: int = fx[9]
	
	# ─── 🛡️ COMBAT IMMUNITY ENGINE GUARD ───
	# Short-circuit conversion logic entirely if damage immunity rules are active this round
	if is_damage_immunity_active(side_data):
		if on_event.is_valid():
			on_event.call("ability_triggered", [
				card_id, "↳ Conversion blocked: Bypassing resource trade.", "x_icon"])
		return # Abort immediately to preserve dice pools

	# ─── 🛑 SUPPRESSION STATE ENGINE GUARD ───
	# Block defense token payouts specifically if a suppression modifier status is active on this side
	if gain_token_type == 2 and _is_cannot_gain_defense_tokens_active(side_data):
		if on_event.is_valid():
			on_event.call("ability_triggered", [
				card_id, "↳ Conversion blocked: Suppression Active!", "x_icon"])
		return # Abort immediately to preserve dice pools

	var source_stat := Stat.OFFENCE
	var stat_label := "⚔"
	
	match pool_type:
		CardData.DicePoolType.DEFENSE:
			source_stat = Stat.DEFENCE
			stat_label = "🛡️"
		CardData.DicePoolType.MORALE:
			source_stat = Stat.MORALE
			stat_label = "🎖️"

	var spend_amount: int = side_data[source_stat]
	if max_spend > 0:
		spend_amount = min(spend_amount, max_spend)

	if spend_amount <= 0:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Conversion skipped: 0 %s dice available to trade." % stat_label, "x_icon"])
		return

	if not _spend_die_to_continue(side_data, source_stat, spend_amount, role, on_event):
		return

	# --- 2. CALCULATE YIELD & COMMIT DETERMINISTIC TOKENS ---
	var tokens_gained := spend_amount * token_multiplier
	var parent_state: Dictionary = side_data.get("parent_state", {})
	_gain_or_lose_tokens(token_pools, role, gain_token_type, tokens_gained, false, parent_state)

	# --- 3. DYNAMIC TELEMETRY MATCHING ---
	if on_event.is_valid():
		var verified_token := _validate_token_type(gain_token_type)
		var token_label := "🛡️" if verified_token == CardData.CombatTokenType.DEFENSE else "⚔️"
		on_event.call("ability_triggered", [card_id, "↳ Converted %d %s dice into +%d %s tokens!" % [spend_amount, stat_label, tokens_gained, token_label], "token_icon"])


static func _execute_gain_token_per_unrouted_unit(fx: Array, token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var multiplier: int = int(fx[2])
	var token_type: int = int(fx[3])  # Maps directly to your type-safe CombatTokenType enum now
	var filter_mode: int = int(fx[4]) # Extracted from card effect configuration
	
	# Safe extraction: Reads allowed types from payload array slot 5 if available
	var allowed_unit_types: Array = fx[5] if fx.size() > 5 and fx[5] is Array else []
	
	var matching_unit_count := 0
	var counted_names: Array[String] = []
	
	# 1. Loop through side assets and find matching unrouted figures
	for squad in side_data.get("squads", []):
		var squad_type: int = int(squad.get("unit_type", 0))
		var squad_tier: int = int(squad.get("tier", 0))
		
		# Evaluate matching rule explicitly using the enum configuration
		var is_match := false
		match filter_mode:
			CardData.UnitFilterMode.REQUIRED_TYPES:
				is_match = allowed_unit_types.has(squad_type)
			CardData.UnitFilterMode.ALL_UNITS:
				is_match = true
			CardData.UnitFilterMode.TIER_0:
				is_match = (squad_tier == 0)
			CardData.UnitFilterMode.TIER_1:
				is_match = (squad_tier == 1)
			CardData.UnitFilterMode.TIER_2:
				is_match = (squad_tier == 2)
			CardData.UnitFilterMode.TIER_3:
				is_match = (squad_tier == 3)
				
		if is_match:
			for i in range(squad["alive_figures"].size()):
				if squad["alive_figures"][i] > 0 and not squad["figures_routed"][i]:
					matching_unit_count += 1
					if not counted_names.has(squad["name"]):
						counted_names.append(squad["name"])
						
	# 2. Hard exit block if no qualified units exist on the dynamic field state
	if matching_unit_count <= 0:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Scaling failed: Zero qualified unrouted units found on battlefield.", "x_icon"])
		return
		
	# 3. Process payouts and calculate scratchpad target slot updates
	var tokens_to_gain = matching_unit_count * multiplier
	var base_idx := 0 if role == "Attacker" else 2
	
	# 🛡️ Forward side state context down to intercept passive suppression blocks during unit scaling
	var parent_state: Dictionary = side_data.get("parent_state", {})
	_gain_or_lose_tokens(token_pools, role, token_type, tokens_to_gain, false, parent_state)
	
	# 4. Dispatch completely generic event logging without card-specific flavors
	if on_event.is_valid():
		var verified_token := _validate_token_type(token_type)
		var pool_label := "Offence ⚔️" if verified_token == CardData.CombatTokenType.OFFENSE else "Defence 🛡️"
		var units_list_string := ", ".join(counted_names)
		
		on_event.call("ability_triggered", [card_id, "↳ Scaling: Found %d unrouted figures (%s). Gained +%d %s tokens." % [matching_unit_count, units_list_string, tokens_to_gain, pool_label], "token_icon"])
		on_event.call("tokens_updated", [role, token_pools[base_idx], token_pools[base_idx + 1]])


#endregion

#region Generic Rally functions

static func _execute_rally(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	if fx[2] is Array:
		return
		
	if not _has_any_routed_units(side_data):
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Rally skipped: All units already standing.", "fast_forward_icon"])
		return

	var val: int = fx[2]
	if on_event.is_valid():
		on_event.call("ability_triggered", [card_id, "Resolved RALLY effect (Max Targets: %d)" % val, "rally_icon"])
		
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


static func _execute_rally_all_friendly_units(_fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	# 1. Early escape bottleneck if the entire army frontline is already steady
	if not _has_any_routed_units(side_data):
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Rally skipped: All squads are already steady.", "fast_forward_icon"])
		return

	var squads: Array = side_data["squads"]
	var total_figures_rallied := 0
	
	# 2. Execute a high-speed primitive iteration pass over all army assets
	for squad in squads:
		for i in range(squad["figures_routed"].size()):
			# Target only living figures that are actively flagged as routed
			if squad["figures_routed"][i] and squad["alive_figures"][i] > 0:
				squad["figures_routed"][i] = false
				total_figures_rallied += 1
				
				# Fire localized UI animation trigger hooks per individual squad restoration
				if on_event.is_valid():
					on_event.call("unit_rallied", [role, squad["name"], squad["alive_figures"][i], card_id])

	# 3. Dispatch finalized state telemetry adjustments to refresh frontend panels
	if on_event.is_valid() and total_figures_rallied > 0:
		on_event.call("ability_triggered", [card_id, "↳ Unconditional Restoration: Rallied %d figures across the frontline!" % total_figures_rallied, "rally_icon"])
		
		var parent_state: Dictionary = side_data.get("parent_state", {})
		if not parent_state.is_empty():
			log_current_army_statuses(parent_state, on_event, "damage_step")
#endregion

#region Generic Rout functions

static func _execute_rout_lowest_tier(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return
		
	var is_attacker := (role == "Attacker")
	var opp_role := "Defender" if is_attacker else "Attacker"
	var opp_side_data: Dictionary = parent_state.get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
	
	#  THE FIX: Read the target type from index 1 of the effect array
	var target_type: int = fx[1] if fx.size() > 1 else CardData.TargetType.OPPONENT
	
	# Dynamically choose which side we are slicing into
	var target_side_data := side_data
	var target_role := role
	
	if target_type == CardData.TargetType.OPPONENT:
		target_side_data = opp_side_data
		target_role = opp_role
	
	# Find the selected target side's lowest tier living, unrouted unit
	var target_unit := _find_lowest_tier_unrouted_unit(target_side_data.get("squads", []))
	
	if not target_unit.is_empty():
		var squad: Dictionary = target_unit["squad"]
		var idx: int = target_unit["index"]
		
		# Unconditionally rout the unit
		squad["figures_routed"][idx] = true
		
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Forced routing resolved on %s." % squad["name"], "rout_icon"])
			on_event.call("unit_routed", [target_role, squad["name"], 0]) # Tracks correctly for friendly or enemy logs
		
		if typeof(parent_state) == TYPE_DICTIONARY:
			log_current_army_statuses(parent_state, on_event, "damage_step")
	else:
		if on_event.is_valid():
			var side_label := "Opponent" if target_type == CardData.TargetType.OPPONENT else "Friendly side"
			on_event.call("ability_triggered", [card_id, "↳ Routing failed: %s has no unrouted units on the field." % side_label, "fast_forward_icon"])


static func _execute_rout_highest_tier(_fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return
		
	var is_attacker := (role == "Attacker")
	var opp_role := "Defender" if is_attacker else "Attacker"
	var opp_side_data: Dictionary = parent_state.get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
	
	# Find the opponent's highest tier living, unrouted unit
	var target_unit := _find_highest_tier_unrouted_unit(opp_side_data.get("squads", []))
	
	if not target_unit.is_empty():
		var squad: Dictionary = target_unit["squad"]
		var idx: int = target_unit["index"]
		
		# Unconditionally rout the unit figure
		squad["figures_routed"][idx] = true
		
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Forced routing resolved on highest-tier unit: %s." % squad["name"], "rout_icon"])
			on_event.call("unit_routed", [opp_role, squad["name"], 0])
		
		# Update game log state safely
		if typeof(parent_state) == TYPE_DICTIONARY:
			log_current_army_statuses(parent_state, on_event, "damage_step")
	else:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Routing failed: Opponent has no unrouted units on the field.", "fast_forward_icon"])


static func _execute_rout_lowest_tier_or_spend_dice_unconditional(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return
		
	var is_attacker := (role == "Attacker")
	var opp_role := "Defender" if is_attacker else "Attacker"
	var opp_side_data: Dictionary = parent_state.get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
	
	var penalty_amount: int = int(fx[2])
	var pool_type: int = int(fx[3])
	
	var stat_map := {1: Stat.OFFENCE, 2: Stat.DEFENCE, 3: Stat.MORALE}
	var labels := {1: "Offence ⚔️", 2: "Defence 🛡️", 3: "Morale 🎖️"}
	
	if not pool_type in stat_map:
		push_error("CRITICAL ENGINE ERROR: Card ID %d used ROUT_OR_SPEND_UNCONDITIONAL but has an invalid or missing pool_type index (%d)!" % [card_id, pool_type])
		return
		
	var target_stat = stat_map[pool_type]
	var target_label = labels[pool_type]
	
	_perform_rout_or_spend_tax(opp_side_data, opp_role, target_stat, target_label, penalty_amount, card_id, parent_state, on_event)

#endregion

#region Generic Card functions

static func _execute_discard_steal_icons(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return
		
	var card_db: Dictionary = parent_state.get("card_db", {})
	if card_db.is_empty():
		return

	#  Dynamic Target Routing (Who are we harvesting icons from?)
	var target_type: int = fx[1] if fx.size() > 1 else CardData.TargetType.OPPONENT
	var is_self := (target_type == CardData.TargetType.SELF)
	
	var target_side: Dictionary = side_data if is_self else parent_state.get(Side.DEFENDER if (role == "Attacker") else Side.ATTACKER, {})
	var target_role: String = role if is_self else ("Defender" if (role == "Attacker") else "Attacker")
	
	# Extract and validate the target deck container
	var deck: Array = target_side.get("combat_deck", [])
	if deck.is_empty():
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Harvest Failed: %s's combat deck is completely dry!" % target_role, "x_icon"])
		return

	# Strip the top Card ID off their active pile
	var stolen_card_id: int = deck.pop_front()
	var flat_card_data = card_db.get(stolen_card_id)
	
	if flat_card_data == null or not flat_card_data is Array:
		deck.push_front(stolen_card_id) # Safety rewind rollback
		return

	# Parse flat profile fields: [0: Offence, 1: Defence, 2: Morale]
	var stolen_offence: int = int(flat_card_data[0])
	var stolen_defence: int = int(flat_card_data[1])
	var stolen_morale: int = int(flat_card_data[2])
	
	# Apply stolen metrics directly into the caster's extra_icons array structure
	var extra_icons: Array = side_data.get("extra_icons", [0, 0, 0])
	extra_icons[0] += stolen_offence
	extra_icons[1] += stolen_defence
	extra_icons[2] += stolen_morale
	side_data["extra_icons"] = extra_icons # Re-assign to guarantee data synchronizations
	
	if on_event.is_valid():
		var source_label := "their own" if is_self else "top enemy"
		on_event.call("ability_triggered", [card_id, "↳  Salvage: Harvested %s card! Extra icons gained: +%d⚔️ | +%d🛡️ | +%d🎖️" % [source_label, stolen_offence, stolen_defence, stolen_morale], "discard_harvest_icon"])

	# Recycling Rule: Route card safely straight back into its original deck
	add_specific_card_to_combat_deck(target_side, stolen_card_id)

	# Broadcast telemetry sync mapping pass
	if on_event.is_valid():
		var atk_side: Dictionary = parent_state.get(Side.ATTACKER, {})
		var def_side: Dictionary = parent_state.get(Side.DEFENDER, {})
		
		if not atk_side.is_empty() and not def_side.is_empty():
			var atk_ex: Array = atk_side.get("extra_icons", [0, 0, 0])
			var def_ex: Array = def_side.get("extra_icons", [0, 0, 0])
			log_current_extra_icons(on_event, atk_ex, def_ex, "damage_step")


static func _execute_play_random_card_do_not_resolve_abilities(_fx: Array, _token_pools: Array, side_data: Dictionary, _role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return
		
	var hand: Array = side_data.get("cards_in_hand", [])
	if hand.is_empty():
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Play failed: No cards remaining in hand.", "x_icon"])
		return
		
	# --- 1. EXTRACT RANDOM CARD FROM HAND ---
	var rand_idx := randi() % hand.size()
	var chosen_card_id: int = hand.pop_at(rand_idx)
	
	# --- 2. INJECT INTO PLAY AREA VIA HELPER ---
	_add_card_to_play_area(side_data, chosen_card_id, -1)
	
	# --- 3. TELEMETRY LOG PASS ---
	# Passing chosen_card_id lets the backend resolve its real name automatically!
	if on_event.is_valid():
		on_event.call("ability_triggered", [chosen_card_id, "↳ Played from hand via ability. No abilities resolved for this card.", "cards_played_icon"])

static func _execute_discard_worst_faceup_card(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return

	var current_round: int = parent_state.get("current_round_index", 0)
	var card_db: Dictionary = parent_state.get("card_db", {})

	#  Dynamic target resolution
	var target_type: int = fx[1] if fx.size() > 1 else CardData.TargetType.OPPONENT
	var is_self := (target_type == CardData.TargetType.SELF)
	
	var target_side: Dictionary = side_data if is_self else parent_state.get(Side.DEFENDER if (role == "Attacker") else Side.ATTACKER, {})
	var target_role: String = role if is_self else ("Defender" if (role == "Attacker") else "Attacker")

	# Safe index isolation: Protect active cards from self-discard
	var ignored_idx := current_round if (is_self or role == "Attacker") else -1

	# Find worst card using your built-in filter
	var target_idx: int = _find_faceup_card_with_least_icons(target_side, card_db, ignored_idx)
	
	if target_idx == -1:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Discard skipped: %s has no valid faceup combat cards to target." % target_role, "reroll_icon"])
		return

	# Mutate and track
	var discarded_card_id := _discard_and_recycle_faceup_card(target_side, target_idx)
	
	if on_event.is_valid():
		on_event.call("opponent_card_discarded", [card_id, target_role, discarded_card_id, target_idx])


static func _execute_discard_best_faceup_card(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return

	var current_round: int = parent_state.get("current_round_index", 0)
	var card_db: Dictionary = parent_state.get("card_db", {})

	#  Dynamic target resolution
	var target_type: int = fx[1] if fx.size() > 1 else CardData.TargetType.OPPONENT
	var is_self := (target_type == CardData.TargetType.SELF)
	
	var target_side: Dictionary = side_data if is_self else parent_state.get(Side.DEFENDER if (role == "Attacker") else Side.ATTACKER, {})
	var target_role: String = role if is_self else ("Defender" if (role == "Attacker") else "Attacker")

	# Safe index isolation: Protect active cards from self-discard
	var ignored_idx := current_round if (is_self or role == "Attacker") else -1

	# Find best card using your premium-weight card scanner
	var target_idx: int = _find_faceup_card_with_most_icons(target_side, card_db, ignored_idx)
	
	if target_idx == -1:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Discard skipped: %s has no valid faceup combat cards to target." % target_role, "fast_forward_icon"])
		return

	# Mutate and track
	var discarded_card_id := _discard_and_recycle_faceup_card(target_side, target_idx)
	
	if on_event.is_valid():
		on_event.call("opponent_card_discarded", [card_id, target_role, discarded_card_id, target_idx])


static func _execute_draw_combat_cards(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty(): 
		return
		
	# Determine target configurations instantly using flat checks
	var target_type: int = fx[1] if fx.size() > 1 else CardData.TargetType.SELF
	var is_self := (target_type == CardData.TargetType.SELF)
	
	var target_side: Dictionary = side_data if is_self else parent_state.get(Side.DEFENDER if (role == "Attacker") else Side.ATTACKER, {})
	var target_role: String = role if is_self else ("Defender" if (role == "Attacker") else "Attacker")
	
	# Execute draw operation via the isolated helper pass
	var draw_count: int = fx[2] if fx.size() > 2 else 1
	var actual_drawn: int = _draw_cards_from_combat_deck(target_side, draw_count)
	
	if on_event.is_valid():
		if actual_drawn > 0:
			on_event.call("ability_triggered", [card_id, "↳ %s draws %d card(s) into their hand." % [target_role, actual_drawn], "cards_played_icon"])
		else:
			on_event.call("ability_triggered", [card_id, "↳ Draw failed: %s's combat deck is empty." % target_role, "x_icon"])


static func _execute_discard_random_card_from_hand(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return
		
	# Instant target assignment using your flat layout pattern
	var target_type: int = fx[1] if fx.size() > 1 else CardData.TargetType.OPPONENT
	var is_self := (target_type == CardData.TargetType.SELF)
	
	var target_side: Dictionary = side_data if is_self else parent_state.get(Side.DEFENDER if (role == "Attacker") else Side.ATTACKER, {})
	var target_role: String = role if is_self else ("Defender" if (role == "Attacker") else "Attacker")
	
	# Run the state mutation logic pass via the new helper
	var discarded_id: int = _discard_random_card_from_hand(target_side)
	
	if on_event.is_valid():
		if discarded_id != -1:
			on_event.call("ability_triggered", [discarded_id, "was discarded by an effect.", "cards_played_icon"])
		else:
			on_event.call("ability_triggered", [card_id, "↳ Disruption failed: %s's hand is already empty." % target_role, "fast_forward_icon"])

#endregion

#region Generic Destroy unit functions

static func _execute_destroy_lowest_tier(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var target_type: int = fx[1]
	var count_to_destroy: int = fx[2]
	var target_mode: int = fx[8] if fx.size() > 8 else CardData.DestructionMode.ANY

	# --- 1. LEAN SYSTEM ROUTING ---
	var target_side_data := side_data
	var target_role := role
	
	if target_type != 0: # 0 = Self, anything else = Opponent
		target_role = "Defender" if role == "Attacker" else "Attacker"
		target_side_data = side_data.get("parent_state", {}).get(Side.DEFENDER if role == "Attacker" else Side.ATTACKER, {})
		
	if target_side_data.is_empty():
		return

	# --- 2. DESTRUCTION PROCESSING ---
	var destroyed_count := 0
	var victim_names: Array[String] = []

	while destroyed_count < count_to_destroy:
		var target_squad: Dictionary = {}
		var target_fig_idx: int = -1
		var lowest_tier: int = 999
		
		for squad in target_side_data["squads"]:
			var squad_tier: int = squad.get("tier", 0)
			
			for i in range(squad["alive_figures"].size()):
				if squad["alive_figures"][i] <= 0:
					continue
					
				# Tight filter screens: drop out early if status conditions mismatch
				var is_routed: bool = squad["figures_routed"][i]
				if target_mode == CardData.DestructionMode.ROUTED and not is_routed: continue
				if target_mode == CardData.DestructionMode.UNROUTED and is_routed: continue
					
				# Found a strictly lower tier unit -> Instant target upgrade
				if squad_tier < lowest_tier:
					lowest_tier = squad_tier
					target_squad = squad
					target_fig_idx = i
				
				# Tier Tie-Breaker -> If tiers match and target mode allows either, prioritize the routed unit
				elif squad_tier == lowest_tier and target_mode == CardData.DestructionMode.ANY:
					var current_target_routed: bool = target_squad["figures_routed"][target_fig_idx]
					if is_routed and not current_target_routed:
						target_squad = squad
						target_fig_idx = i
						
		if not target_squad.is_empty() and target_fig_idx != -1:
			victim_names.append(target_squad["name"])
			_destroy_figure(target_squad, target_fig_idx, target_role, on_event)
			destroyed_count += 1
		else:
			break # Loop breaks safely on its own if no valid targets match criteria

	# --- 3. CONSOLIDATED TELEMETRY PASS ---
	if on_event.is_valid():
		if not victim_names.is_empty():
			var list_string := ", ".join(victim_names)
			on_event.call("ability_triggered", [card_id, "↳ Destroyed %s lowest-tier unit(s): [%s]" % [target_role, list_string], "skull_icon"])
		elif target_mode == CardData.DestructionMode.ROUTED:
			on_event.call("ability_triggered", [card_id, "↳ Effect skipped: No routed units found on %s's board." % target_role, "fast_forward_icon"])


static func _execute_destroy_highest_tier_routed_unit(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var target_type: int = fx[1] if fx.size() > 1 else 1 # 0 = Self, 1 = Opponent
	var count_to_destroy: int = fx[2] if fx.size() > 2 else 1

	# --- 1. SYSTEM SIDE ROUTING ---
	var target_side_data := side_data
	var target_role := role
	
	if target_type != 0: 
		target_role = "Defender" if role.to_lower() == "attacker" else "Attacker"
		var opp_side = SimCombatEngine.Side.DEFENDER if role.to_lower() == "attacker" else SimCombatEngine.Side.ATTACKER
		target_side_data = side_data.get("parent_state", {}).get(opp_side, {})
		
	if target_side_data.is_empty():
		return

	# --- 2. DESTRUCTION PROCESSING ---
	var destroyed_count := 0
	var victim_names: Array[String] = []

	while destroyed_count < count_to_destroy:
		# Dynamically look up the current highest-tier routed unit
		var target_info := _find_highest_tier_routed_unit(target_side_data.get("squads", []))
		
		if not target_info.is_empty():
			var target_squad: Dictionary = target_info["squad"]
			var target_fig_idx: int = target_info["index"]
			
			victim_names.append(target_squad.get("name", "Unknown"))
			_destroy_figure(target_squad, target_fig_idx, target_role, on_event)
			destroyed_count += 1
		else:
			break # Exit cleanly if no routed targets remain mid-loop

	# --- 3. CONSOLIDATED TELEMETRY PASS ---
	if on_event.is_valid():
		if not victim_names.is_empty():
			var list_string := ", ".join(victim_names)
			on_event.call("ability_triggered", [card_id, "↳ Destroyed %s highest-tier routed unit(s): [%s]" % [target_role, list_string], "skull_icon"])
			
			var parent_state: Dictionary = side_data.get("parent_state", {})
			if not parent_state.is_empty():
				log_current_army_statuses(parent_state, on_event, "damage_step")
		else:
			on_event.call("ability_triggered", [card_id, "↳ Effect skipped: No routed units found on %s's board." % target_role, "fast_forward_icon"])

#endregion

#region Generic Spawn unit functions

static func _execute_spawn_unit(fx: Array, _token_pools: Array, side_data: Dictionary, _role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return
		
	var unit_type: int = fx[3]
	var spawn_count: int = fx[2] if fx[2] is int else 1
	var faction_id: int = side_data.get("faction_id", 0)
	
	# 1. Grab the faction's unit list from your existing database
	var faction_data: Dictionary = FactionRegistry.get_database().get(faction_id, {})
	var units_list: Array = faction_data.get("units", [])
	
	# 2. Scan for the specific unit blueprint match
	var blueprint: Dictionary = {}
	for unit in units_list:
		if unit.get("unit_type") == unit_type:
			blueprint = unit
			break
			
	if blueprint.is_empty():
		return

	# 3. Deploy the squads using the exact database values
	if spawn_count > 0:
		for i in range(spawn_count):
			_spawn_unit(
				side_data,
				blueprint.get("unit_name", ""),
				unit_type,
				blueprint.get("tier", 0),
				blueprint.get("combat_value", 1),
				blueprint.get("health_value", 2),
				blueprint.get("morale_value", 2),
				blueprint.get("is_ship", false)
			)
			
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Reinforcements Deployed: Added %d unrouted %s squad(s)." % [spawn_count, blueprint.get("unit_name", "")], "guard_icon"])
			log_current_army_statuses(parent_state, on_event, "damage_step")

static func _execute_spawn_reinforcement_token(_fx: Array, _token_pools: Array, side_data: Dictionary, _role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return
		
	var is_ground: bool = parent_state.get("is_ground_combat", true)
	var faction: int = side_data.get("faction_id", 0)
	
	# 1. Fetch the faction's entry from your registry data
	var faction_db := FactionRegistry.get_database()
	var faction_data: Dictionary = faction_db.get(faction, {})
	var units_list: Array = faction_data.get("units", [])
	
	# 2. Dynamically scan for the matching Tier 0 unit configuration
	var target_unit_cfg := {}
	for unit in units_list:
		if unit.get("tier") == 0 and unit.get("is_ship") == (not is_ground):
			target_unit_cfg = unit
			break
			
	# 3. Deploy if a valid configuration was found
	if not target_unit_cfg.is_empty():
		var unit_name: String = target_unit_cfg["unit_name"]
		var unit_type: int = target_unit_cfg["unit_type"]
		var combat_val: int = target_unit_cfg["combat_value"]
		var health_val: int = target_unit_cfg["health_value"]
		var morale_val: int = target_unit_cfg["morale_value"]
		
		_spawn_unit(side_data, unit_name, unit_type, 0, combat_val, health_val, morale_val, not is_ground)
		
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Reinforcements Deployed: Added 1 unrouted %s squad." % unit_name, "guard_icon"])
			log_current_army_statuses(parent_state, on_event, "damage_step")
	else:
		push_warning("Spawn skipped: No Tier 0 unit matching is_ship=%s found for Faction ID %d." % [str(not is_ground), faction])

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


#region Faction Instant Card abilities

# SM Show No Fear general ability
static func _execute_prevent_routing_this_round(fx: Array, _token_pools: Array, side_data: Dictionary, _role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var target_type: int = int(fx[1])
	
	# Dynamically branch behavior based on the card's target designator definition
	if target_type == CardData.TargetType.BOTH: # Affects both sides globally
		var parent_state: Dictionary = side_data.get("parent_state", {})
		if not parent_state.is_empty():
			# Loop through the match state to catch both Attacker and Defender sub-states
			for side_key in parent_state.keys():
				if parent_state[side_key] is Dictionary:
					parent_state[side_key]["cannot_route"] = true
					
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Global Status: A battlefield-wide effect prevents ANY unit from routing this round!", "global_effect_icon"])
			
	else: # Default behavior: CardData.TargetType.SELF / FRIENDLY
		side_data["cannot_route"] = true
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Status Activated: Friendly units cannot be routed this round.", "shield_icon"])


## Unit Ability: Schedules an additional complete assess damage step to resolve this round.
# SM Armoured Advance unit ability
static func _execute_additional_assess_damage_step_this_round(_fx: Array, _token_pools: Array, side_data: Dictionary, _role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return

	# Safely increment the round's dynamic damage loop execution counter
	var current_extras: int = parent_state.get("extra_damage_steps_this_round", 0)
	parent_state["extra_damage_steps_this_round"] = current_extras + 1

	if on_event.is_valid():
		on_event.call("ability_triggered", [card_id, "↳ Armoured Advance! An additional Assess Damage step has been scheduled for this round.", "sword_icon"])


## Converts all Offence dice and any excess surplus Defence dice into Morale.
## Only triggers on Round 3.
# SM Emperor's Glory unit ability
static func _execute_convert_safe_dice_to_morale(_fx: Array, token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	var card_db: Dictionary = parent_state.get("card_db", {})
	if parent_state.is_empty() or card_db.is_empty():
		return

	var round_idx: int = parent_state.get("current_round_index", 0)

	# Strict round checking restriction (0 = Round 1, 1 = Round 2, 2 = Round 3)
	if round_idx != 2:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Conversion skipped: Strategic reallocation is restricted to Round 3.", "fast_forward_icon"])
		return

	var is_attacker := (role == "Attacker")
	var enemy_side_id := Side.DEFENDER if is_attacker else Side.ATTACKER
	var enemy_data: Dictionary = parent_state[enemy_side_id]
	var enemy_role := "Defender" if is_attacker else "Attacker"

	# 1. Calculate our current Total Defence baseline (including temporary modifiers/tokens)
	var our_card_icons: Array = _get_live_card_icons(side_data, card_db, round_idx)
	var our_ex: Array = side_data.get("extra_icons", [0, 0, 0])
	var our_def_token_idx := _get_token_index(role, CardData.DicePoolType.DEFENSE, false)
	
	var total_defence: int = side_data[Stat.DEFENCE] + our_card_icons[1] + token_pools[our_def_token_idx] + our_ex[1]

	# 2. Calculate enemy's Total Offence baseline
	var enemy_card_icons := [0, 0, 0]
	if is_attacker:
		# Fog of War: Attacker cannot see the defender's card choice for this round yet!
		if round_idx > 0:
			enemy_card_icons = _get_live_card_icons(enemy_data, card_db, round_idx - 1)
	else:
		# Defender acts second and has full visibility of the attacker's round card layout
		enemy_card_icons = _get_live_card_icons(enemy_data, card_db, round_idx)

	var enemy_ex: Array = enemy_data.get("extra_icons", [0, 0, 0])
	var enemy_atk_token_idx := _get_token_index(enemy_role, CardData.DicePoolType.OFFENSE, false)
	
	var enemy_total_offence: int = enemy_data[Stat.OFFENCE] + enemy_card_icons[0] + token_pools[enemy_atk_token_idx] + enemy_ex[0]

	# 3. Determine safe conversion limits without falling into the damage window
	var safe_defence_to_spend := 0
	if total_defence > enemy_total_offence:
		var defensive_surplus := total_defence - enemy_total_offence
		# We can only convert physical dice we hold in our hand wallet, not passive icons
		safe_defence_to_spend = min(side_data[Stat.DEFENCE], defensive_surplus)

	# Offence dice never prevent incoming damage, making them 100% safe to trade away
	var offence_to_spend: int = side_data[Stat.OFFENCE]
	var total_converted_yield := safe_defence_to_spend + offence_to_spend

	if total_converted_yield <= 0:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Conversion skipped: No surplus dice available to safely swap.", "fast_forward_icon"])
		return

	# 4. Mutate core dice state parameters inside the player's profile data
	side_data[Stat.OFFENCE] -= offence_to_spend
	side_data[Stat.DEFENCE] -= safe_defence_to_spend
	side_data[Stat.MORALE] += total_converted_yield

	# 5. Broadcast generic frameworks logs out to the UI layout panel
	if on_event.is_valid():
		on_event.call("ability_triggered", [card_id, "↳ Strategic Reallocation: Converted %d safe dice into +%d Morale dice!" % [total_converted_yield, total_converted_yield], "dice_icon"])

# Orks Smasher Gargant unit ability
static func _execute_destroy_or_spend_dice_based_on_tier(_fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return
		
	var is_attacker := (role == "Attacker")
	var opp_role := "Defender" if is_attacker else "Attacker"
	var opp_side_data: Dictionary = parent_state.get(Side.DEFENDER if is_attacker else Side.ATTACKER, {})
	
	# 1. Search for highest tier unrouted target first
	var target_data := _find_highest_tier_unrouted_unit(opp_side_data["squads"])
	
	# 2. Fallback to highest tier routed target if no unrouted choices exist
	if target_data.is_empty():
		target_data = _find_highest_tier_routed_unit(opp_side_data["squads"])
		
	# 3. Handle complete field elimination safety sweep
	if target_data.is_empty():
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Smasher Gargant: Opponent has no eligible figures left on the field.", "fast_forward_icon"])
		return
		
	var squad: Dictionary = target_data["squad"]
	var idx: int = target_data["index"]
	var tier_level: int = target_data["tier"]
	
	# Establish a minimum cost floor of 1 so Starter / Tier 0 items still levy a minor toll
	var tax_cost: int = max(1, tier_level)
	var total_available_dice: int = opp_side_data[Stat.OFFENCE] + opp_side_data[Stat.DEFENCE] + opp_side_data[Stat.MORALE]
	
	# 4. Process conditional tax payment or mechanical deletion
	if total_available_dice >= tax_cost:
		var remaining := tax_cost
		# Greedy extraction chain: Spend resource pools in order of general priority (Morale -> Defence -> Offence)
		for stat in [Stat.MORALE, Stat.DEFENCE, Stat.OFFENCE]:
			if opp_side_data[stat] >= remaining:
				opp_side_data[stat] -= remaining
				remaining = 0
				break
			else:
				remaining -= opp_side_data[stat]
				opp_side_data[stat] = 0
				
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ %s spent %d dice to save '%s' from obliteration." % [opp_role, tax_cost, squad["name"]], "saved_from_destruction"])
			on_event.call("dice_updated", [opp_role, opp_side_data[Stat.OFFENCE], opp_side_data[Stat.DEFENCE], opp_side_data[Stat.MORALE]])
	else:
		# Insufficient funds available to meet total tax -> Inflict absolute destruction 
		squad["alive_figures"][idx] = 0
		
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ %s could not pay %d dice! '%s' was destroyed." % [opp_role, tax_cost, squad["name"]],"skull_icon"])
			
		log_current_army_statuses(parent_state, on_event, "damage_step")

# CSM Chaos United
@warning_ignore("unused_parameter")
static func _execute_chaos_united_unit_ability(fx: Array, token_pools: Array, side_data: Dictionary, role_label: String, active_card_id: int, has_valid_units: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return
		
	# 1. Use the helper function to count the living Tier 0 units (Cultists)
	var tier_0_count = get_specific_unit_amount_in_this_combat(side_data, CardData.UnitType.CULTISTS)

	# 2. Map the tier count (capped at 3) directly to the corresponding UnitType Enum
	var spawned_tier := mini(tier_0_count, 3)
	var target_unit_type: int = CardData.UnitType.CULTISTS
	
	match spawned_tier:
		0: target_unit_type = CardData.UnitType.CULTISTS
		1: target_unit_type = CardData.UnitType.CHAOS_SPACE_MARINES
		2: target_unit_type = CardData.UnitType.HELBRUTES
		3: target_unit_type = CardData.UnitType.CHAOS_REAVER_TITANS

	# 3. Query the FactionRegistry database exactly like your execute logic does
	var faction_id: int = side_data.get("faction_id", 0)
	var faction_data: Dictionary = FactionRegistry.get_database().get(faction_id, {})
	var units_list: Array = faction_data.get("units", [])
	
	var blueprint: Dictionary = {}
	for unit in units_list:
		if unit.get("unit_type") == target_unit_type:
			blueprint = unit
			break
			
	if blueprint.is_empty():
		return
		
	# 4. Spawns the unit dynamically using the database data
	_spawn_unit(
		side_data,
		blueprint.get("unit_name", ""),
		target_unit_type,
		blueprint.get("tier", 0),
		blueprint.get("combat_value", 1),
		blueprint.get("health_value", 2),
		blueprint.get("morale_value", 2),
		blueprint.get("is_ship", false)
	)
	
	# 5. Emit UI/Log notifications following your architecture's standard pattern
	if on_event.is_valid():
		on_event.call("ability_triggered", [
			active_card_id, 
			"↳ Chaos United: Spawned Tier %d unit (%s) based on %d Cultists." % [
				blueprint.get("tier", 0), 
				blueprint.get("unit_name", ""), 
				tier_0_count
			], "guard_icon"])
		log_current_army_statuses(parent_state, on_event, "damage_step")


# CSM Death and Despair
@warning_ignore("unused_parameter")
static func _execute_death_and_despair_general_ability_2(fx: Array, token_pools: Array, side_data: Dictionary, role_label: String, active_card_id: int, has_valid_units: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty(): return

	# 1. Direct Opponent Mapping via Enum removes the manual dictionary scan loop
	var opp_side = SimCombatEngine.Side.DEFENDER if role_label.to_lower() == "attacker" else SimCombatEngine.Side.ATTACKER
	var opponent_data: Dictionary = parent_state.get(opp_side, {})
	if opponent_data.is_empty(): return
		
	# 2. Asset Evaluation
	var morale_dice_available := count_specific_dice_amount(side_data, Stat.MORALE)
	var opp_tier_0_count := count_tier_0_units(opponent_data)
	var dice_to_spend := mini(morale_dice_available, opp_tier_0_count)
	
	if dice_to_spend <= 0:
		if on_event.is_valid():
			on_event.call("ability_triggered", [active_card_id, "↳ Death and Despair skipped: Prerequisites not met.", "x_icon"])
		return

	# 3. Spend resources through official framework channel (3 = Morale Pool Type)
	_remove_dice_from_pool(side_data, role_label, dice_to_spend, 3, active_card_id, side_data, on_event)

	# 4. Streamlined Processing: Linear progression tracking removes flag boilerplate
	var destroyed_count := 0
	for squad in opponent_data.get("squads", []):
		if destroyed_count >= dice_to_spend: break
		if int(squad.get("tier", -1)) == 0:
			var alive_figures: Array = squad.get("alive_figures", [])
			for idx in range(alive_figures.size()):
				if destroyed_count >= dice_to_spend: break
				if alive_figures[idx] > 0:
					alive_figures[idx] = 0 
					destroyed_count += 1

	# 5. Pipeline Logs
	if on_event.is_valid():
		on_event.call("ability_triggered", [active_card_id, "↳ Death and Despair: Spent %d Morale dice to destroy %d opponent Tier 0 unit figure(s)." % [dice_to_spend, destroyed_count], "skull_icon"])
		log_current_army_statuses(parent_state, on_event, "damage_step")


## CSM Chaos Victorious
static func _execute_rout_all_command_level_0_units(fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return
		
	var target_type: int = fx[1] if fx.size() > 1 else 1 # 0 = SELF, 1 = OPPONENT, 2 = BOTH
	
	var self_side_enum = Side.ATTACKER if role.to_lower() == "attacker" else Side.DEFENDER
	var opp_side_enum = Side.DEFENDER if role.to_lower() == "attacker" else Side.ATTACKER
	
	# --- 1. BUILD TARGET QUEUE BASED ON TARGET TYPE ---
	var execution_queue: Array[Dictionary] = []
	
	if target_type == 0 or target_type == 2: # SELF or BOTH
		execution_queue.append({
			"side_data": parent_state.get(self_side_enum, side_data),
			"role_label": "Attacker" if role.to_lower() == "attacker" else "Defender"
		})
		
	if target_type == 1 or target_type == 2: # OPPONENT or BOTH
		execution_queue.append({
			"side_data": parent_state.get(opp_side_enum, {}),
			"role_label": "Defender" if role.to_lower() == "attacker" else "Attacker"
		})

	# --- 2. DESTRUCTION PROCESSING ---
	var total_routed_overall := 0
	
	for target in execution_queue:
		var target_side: Dictionary = target["side_data"]
		var target_role: String = target["role_label"]
		
		if target_side.is_empty():
			continue
			
		var side_routed_count := 0
		
		for squad in target_side.get("squads", []):
			# Match command level 0 units (Tier 0)
			if int(squad.get("tier", -1)) == 0:
				var alive_figures: Array = squad.get("alive_figures", [])
				var figures_routed: Array = squad.get("figures_routed", [])
				
				for i in range(alive_figures.size()):
					# Target living figures that aren't already routed
					if alive_figures[i] > 0 and not figures_routed[i]:
						figures_routed[i] = true
						side_routed_count += 1
						total_routed_overall += 1
						
						if on_event.is_valid():
							on_event.call("unit_routed", [target_role, squad.get("name", "Unknown"), 0])
		
		# Log target side specific resolution
		if side_routed_count > 0 and on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Forced routing resolved on %s's Command Level 0 units (Count: %d)." % [target_role, side_routed_count], "rout_icon"])

	# --- 3. CONSOLIDATED TELEMETRY PASS ---
	if total_routed_overall > 0:
		if typeof(parent_state) == TYPE_DICTIONARY:
			log_current_army_statuses(parent_state, on_event, "damage_step")
	else:
		if on_event.is_valid():
			on_event.call("ability_triggered", [card_id, "↳ Routing skipped: No unrouted Command Level 0 units found on specified targets.", "fast_forward_icon"])

## Eldar Fire Dragon's Vengeance general ability
static func _execute_prevent_opponent_gaining_defense_tokens_this_round(_fx: Array, _token_pools: Array, side_data: Dictionary, role: String, card_id: int, _units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return
		
	var is_attacker := (role == "Attacker")
	var opp_side = Side.DEFENDER if is_attacker else Side.ATTACKER
	var opp_side_data: Dictionary = parent_state.get(opp_side, {})
	
	if opp_side_data.is_empty():
		return
		
	# Apply the passive suppression restriction directly to the opponent's reference state
	opp_side_data["cannot_gain_defense_tokens"] = true
	
	if on_event.is_valid():
		var opp_role := "Defender" if is_attacker else "Attacker"
		on_event.call("ability_triggered", [card_id, "↳ Suppression active: %s cannot gain Defence tokens this round." % opp_role, "crystal_ball_icon"])

# Eldar Spiritseer Guidance
@warning_ignore("unused_parameter")
static func _execute_all_units_gain_damage_immunity_this_round(fx: Array, token_pools: Array, side_data: Dictionary, role: String, card_id: int, units_valid: bool, on_event: Callable) -> void:
	var parent_state: Dictionary = side_data.get("parent_state", {})
	if parent_state.is_empty():
		return
		
	parent_state["all_units_damage_immune"] = true
	
	if on_event.is_valid():
		on_event.call("ability_triggered", [card_id, "↳ All units on both sides gain total damage immunity!", "shield_icon"])

#endregion
