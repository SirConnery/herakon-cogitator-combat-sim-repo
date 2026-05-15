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

	# --- PHASE 2: THE 3-ROUND CARD PLAY LOOP ---
	for round_index in range(3):
		if _count_living_units(atk) == 0 or _count_living_units(def) == 0:
			if on_event.is_valid(): on_event.call("early_termination", [])
			break
		
		var atk_offence_pool: int = atk_dice_offence
		var atk_defence_pool: int = atk_dice_defence
		atk_card_morale = 0
		
		var def_offence_pool: int = def_dice_offence
		var def_defence_pool: int = def_dice_defence
		def_card_morale = 0
		
		var atk_card_id: int = atk["combat_deck"][randi() % atk["combat_deck"].size()]
		var def_card_id: int = def["combat_deck"][randi() % def["combat_deck"].size()]
		
		atk["play_area"][round_index] = atk_card_id
		def["play_area"][round_index] = def_card_id
		
		if on_event.is_valid(): on_event.call("round_start", [round_index, atk_card_id, def_card_id])
		
		# Card stack evaluation
		for i in range(round_index + 1):
			var atk_c_stats: Array = card_db[atk["play_area"][i]]
			var def_c_stats: Array = card_db[def["play_area"][i]]
			
			atk_offence_pool += atk_c_stats[0]
			atk_defence_pool += atk_c_stats[1]
			atk_card_morale += atk_c_stats[2]
			
			def_offence_pool += def_c_stats[0]
			def_defence_pool += def_c_stats[1]
			def_card_morale += def_c_stats[2]
			
			# Basic Ability Hook Sandbox
			if atk["play_area"][i] == 2:
				for squad in atk["squads"]:
					if squad["tier"] == 1 and squad["alive_figures"].size() > 0:
						atk_offence_pool += 2
						if on_event.is_valid(): on_event.call("ability_triggered", ["Attacker", "Card ID 2 grants +2 Offence"])

		if on_event.is_valid():
			on_event.call("pools_updated", ["Attacker", atk_offence_pool, atk_defence_pool])
			on_event.call("pools_updated", ["Defender", def_offence_pool, def_defence_pool])

		# --- ASSESS DAMAGE STEP ---
		var net_damage_to_defender: int = max(0, atk_offence_pool - def_defence_pool)
		var net_damage_to_attacker: int = max(0, def_offence_pool - atk_defence_pool)
		
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
