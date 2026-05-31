extends Node
class_name SimController


#region Mass Combat Sim variables
# ─── RUN MODE CONFIGURATION ───
var iterations_per_matchup: int = 10

# ─── MATRIX BATCH CONFIGURATION ───
var factions_to_sim: Array[FactionRegistry.FactionID] = [
	FactionRegistry.FactionID.SPACE_MARINES,
	FactionRegistry.FactionID.CHAOS_SPACE_MARINES,
	FactionRegistry.FactionID.ORKS,
	FactionRegistry.FactionID.ELDAR
]

#endregion

#region Single Combat variables
# ─── ENVIRONMENT & FORMATS ───
var is_random_stage := true
var debug_stage: GameStageGenerator.Stage = GameStageGenerator.Stage.LATE
var random_combat_type: bool = false
var is_ground_combat := true

# ─── CUSTOM DECK OVERRIDES ───
var use_custom_combat_decks: bool = false
var custom_attacker_combat_deck: Array[int] = []
var custom_defender_combat_deck: Array[int] = []
var custom_attacker_units: Array[int] = []
var custom_defender_units: Array[int] = []

# ─── ENGINE CORE REGISTRIES ───
@onready var card_db: Dictionary = CardRegistry.get_database()
var max_stage_index: int = GameStageGenerator.Stage.keys().size() - 1
var current_stage: GameStageGenerator.Stage

#endregion

#region Variables for UI
var attacker_starting_hand := []
var defender_starting_hand := []
var attacker_faction_name := ""
var defender_faction_name := ""
#endregion

#region Ready function

func _ready() -> void:
	pass

#endregion

#region Mass Combat Simulation

## High-speed round-robin matrix simulation. 
func run_mass_combat_simulation() -> void:
	var raw_cards: Dictionary = CardRegistry.get_database()
	var raw_factions: Dictionary = FactionRegistry.get_database()
	var flat_card_db: Dictionary = _flatten_card_database(raw_cards)

	var exporter := SimDataExporter.new()
	var global_match_index := 0

	print("============ STARTING MATRIX SIMULATION ============")
	print("Pool Size: %d factions  |  Matches per pairing: %d" % [factions_to_sim.size(), iterations_per_matchup])
	print("Streaming raw records to disk stream...")

	# THEATER BLOCK SEPARATION: Forces clean execution blocks for Ground first, then Void
	for active_ground_combat in [true, false]:
		var theater_string := "GROUND COMBAT" if active_ground_combat else "VOID COMBAT"
		var file_suffix := "ground" if active_ground_combat else "void"
		
		# Dynamically isolate target data file paths per theater block
		exporter.file_path_binary = "user://simulation_%s_data.dat" % file_suffix
		exporter.clear_previous_data() # Wipes ONLY this specific target file before the run
		
		print("\n====================================================")
		print("INITIALIZING BLOCK RUN: %s" % theater_string)
		print("Target Destination: %s" % exporter.file_path_binary)
		print("====================================================")

		for atk_id in factions_to_sim:
			for def_id in factions_to_sim:
				if atk_id == def_id:
					continue
					
				var atk_profile: Dictionary = raw_factions.get(atk_id, {})
				var def_profile: Dictionary = raw_factions.get(def_id, {})
				var atk_name_string: String = atk_profile.get("name", FactionRegistry.FactionID.keys()[atk_id])
				var def_name_string: String = def_profile.get("name", FactionRegistry.FactionID.keys()[def_id])

				print(" -> [%s] Pairing Matrix: [Atk] %s vs [Def] %s..." % [theater_string, atk_name_string, def_name_string])

				for i in range(iterations_per_matchup):
					# 1. RESOLVE CONFIGURABLE ENVIRONMENT RULES
					current_stage = get_current_stage()
					
					# 2. GENERATE COMPOSITION SCALE
					var att_count := randi_range(1, 5)
					var def_count := randi_range(1, 5)
					
					var attacker_blueprint: Dictionary = GameStageGenerator.generate_faction_blueprint(atk_id, current_stage, att_count, active_ground_combat, raw_factions)
					var defender_blueprint: Dictionary = GameStageGenerator.generate_faction_blueprint(def_id, current_stage, def_count, active_ground_combat, raw_factions)
					
					# 3. RESOLVE FACTION-SPECIFIC DEBUG DECKS OVERRIDES
					var atk_debug_deck: Array = atk_profile.get("debug_deck", [])
					if not atk_debug_deck.is_empty():
						var target_card: int = atk_debug_deck[0]
						var new_deck: Array = []
						new_deck.resize(10)
						new_deck.fill(target_card)
						new_deck.shuffle()
						
						var new_hand: Array = []
						var draw_count: int = min(5, new_deck.size())
						for h in range(draw_count):
							new_hand.append(new_deck.pop_back())
							
						attacker_blueprint["combat_deck"] = new_deck
						attacker_blueprint["cards_in_hand"] = new_hand

					var def_debug_deck: Array = def_profile.get("debug_deck", [])
					if not def_debug_deck.is_empty():
						var target_card: int = def_debug_deck[0]
						var new_deck: Array = []
						new_deck.resize(10)
						new_deck.fill(target_card)
						new_deck.shuffle()
						
						var new_hand: Array = []
						var draw_count: int = min(5, new_deck.size())
						for h in range(draw_count):
							new_hand.append(new_deck.pop_back())
							
						defender_blueprint["combat_deck"] = new_deck
						defender_blueprint["cards_in_hand"] = new_hand
					
					# 🎯 UPDATED: Combine library pile and starting hand arrays to pass down complete decklists
					var atk_full_deck: Array = attacker_blueprint["combat_deck"] + attacker_blueprint["cards_in_hand"]
					var def_full_deck: Array = defender_blueprint["combat_deck"] + defender_blueprint["cards_in_hand"]
					
					# 4. INSTANTIATE SIMULATION STATE FRAME
					var match_state: Dictionary = _instantiate_match_state(attacker_blueprint, defender_blueprint)
					
					match_state["card_db"] = flat_card_db
					match_state["is_ground_combat"] = active_ground_combat
					
					match_state[SimCombatEngine.Side.ATTACKER]["faction_id"] = atk_id
					match_state[SimCombatEngine.Side.DEFENDER]["faction_id"] = def_id
					match_state[SimCombatEngine.Side.ATTACKER]["name"] = atk_name_string
					match_state[SimCombatEngine.Side.DEFENDER]["name"] = def_name_string
					
					# 5. EXECUTE MATCH ENTIRELY WITHOUT TELEMETRY OR VISUAL OVERHEAD CALLBACKS
					var attacker_won: bool = SimCombatEngine.run_full_match(match_state, flat_card_db, Callable())
					
					# 6. STREAM RAW COOPERATIVE METRICS RECORD DIRECTLY TO EXPORTER
					exporter.log_match(
						global_match_index, 
						int(current_stage), 
						atk_id,
						def_id,
						attacker_won, 
						atk_full_deck,
						def_full_deck
					)
					
					global_match_index += 1
		
		# Force-flush residual RAM blocks BEFORE switching combat theaters!
		exporter.flush_to_disk()
		print(">> Successfully committed all %s records to disk stream." % theater_string)
						
	print("\n============ MATRIX SIMULATION COMPLETE ============")
	print("Total Global Matches Run across All Matrices: %d" % global_match_index)


#endregion

#region Single Combat simulation

## Runs a single, highly configurable battle sandbox with full step-by-step logging telemetry
## Config comes from single_combat_view.gd start_new_combat_btn_pressed
func run_single_logged_combat(config: Dictionary) -> void:
	print("🚨 run_single_logged_battle() is executing!")
	
	# 1. RESOLVE CONFIGURABLE ENVIRONMENT RULES
	current_stage = get_current_stage()
	
	# 🎯 FIXED: Relies strictly on the UI-selected combat theater state variable now
	var active_ground_combat := is_ground_combat
		
	# 2. RESOLVE MATCHUP IDENTITIES FROM CONFIG ENVELOPE (ANTI-MIRROR SECURE)
	var global_pool: Array = FactionRegistry.FactionID.values()
	
	var input_atk_id: int = config.get("attacker_id", 999)
	var input_def_id: int = config.get("defender_id", 999)
	
	var current_atk_id: FactionRegistry.FactionID
	var current_def_id: FactionRegistry.FactionID
	
	var is_atk_random: bool = (input_atk_id == 999)
	var is_def_random: bool = (input_def_id == 999)
	
	if is_atk_random and is_def_random:
		current_atk_id = global_pool.pick_random() as FactionRegistry.FactionID
		var filtered_pool = global_pool.filter(func(f): return int(f) != int(current_atk_id))
		current_def_id = filtered_pool.pick_random() as FactionRegistry.FactionID
		
	elif is_atk_random and not is_def_random:
		current_def_id = input_def_id as FactionRegistry.FactionID
		var allowed_attackers = global_pool.filter(func(f): return int(f) != int(current_def_id))
		current_atk_id = allowed_attackers.pick_random() as FactionRegistry.FactionID
		
	elif not is_atk_random and is_def_random:
		current_atk_id = input_atk_id as FactionRegistry.FactionID
		var allowed_defenders = global_pool.filter(func(f): return int(f) != int(current_atk_id))
		current_def_id = allowed_defenders.pick_random() as FactionRegistry.FactionID
		
	else:
		current_atk_id = input_atk_id as FactionRegistry.FactionID
		current_def_id = input_def_id as FactionRegistry.FactionID
		
	# 3. EXTRACT DATABASES & BLUEPRINTS
	var raw_cards: Dictionary = CardRegistry.get_database()
	var raw_factions: Dictionary = FactionRegistry.get_database()
	var flat_card_db: Dictionary = _flatten_card_database(raw_cards)
	
	var att_count := randi_range(1, 5)
	var def_count := randi_range(1, 5)
	
	var attacker_blueprint: Dictionary = GameStageGenerator.generate_faction_blueprint(current_atk_id, current_stage, att_count, active_ground_combat, raw_factions)
	var defender_blueprint: Dictionary = GameStageGenerator.generate_faction_blueprint(current_def_id, current_stage, def_count, active_ground_combat, raw_factions)
	
	# ----------------------------------------------------
	# STEP 3.2: OVERRIDE CUSTOM SQUAD COMPOSITIONS
	# ----------------------------------------------------
	if config.get("attacker_has_custom_units", false):
		var custom_atk_blueprints: Array = []
		var faction_units: Array = raw_factions[current_atk_id].get("units", [])
		
		for tier in custom_attacker_units:
			for unit_data in faction_units:
				if unit_data["tier"] == tier and active_ground_combat != unit_data.get("is_ship", false):
					custom_atk_blueprints.append(unit_data.duplicate(true))
					break
		attacker_blueprint["selected_units"] = custom_atk_blueprints
		
	if config.get("defender_has_custom_units", false):
		var custom_def_blueprints: Array = []
		var faction_units: Array = raw_factions[current_def_id].get("units", [])
		
		for tier in custom_defender_units:
			for unit_data in faction_units:
				if unit_data["tier"] == tier and active_ground_combat != unit_data.get("is_ship", false):
					custom_def_blueprints.append(unit_data.duplicate(true))
					break
		defender_blueprint["selected_units"] = custom_def_blueprints
	
	# 3.5. RESOLVE FACTION-SPECIFIC DEBUG DECKS OVERRIDES
	var atk_profile_data: Dictionary = raw_factions.get(current_atk_id, {})
	var atk_debug_deck: Array = atk_profile_data.get("debug_deck", [])
	if not atk_debug_deck.is_empty():
		var target_card: int = atk_debug_deck[0]
		var new_deck: Array = []
		# ⚡ OPTIMIZED: Pre-allocating and filling memory allocation footprints directly
		new_deck.resize(10)
		new_deck.fill(target_card)
		new_deck.shuffle()
		
		var new_hand: Array = []
		var draw_count: int = min(5, new_deck.size())
		for i in range(draw_count):
			# ⚡ OPTIMIZED: Constant time O(1) back popping operation prevents data array shifting loops
			new_hand.append(new_deck.pop_back())
			
		attacker_blueprint["combat_deck"] = new_deck
		attacker_blueprint["cards_in_hand"] = new_hand

	var def_profile_data: Dictionary = raw_factions.get(current_def_id, {})
	var def_debug_deck: Array = def_profile_data.get("debug_deck", [])
	if not def_debug_deck.is_empty():
		var target_card: int = def_debug_deck[0]
		var new_deck: Array = []
		# ⚡ OPTIMIZED: Pre-allocating and filling memory allocation footprints directly
		new_deck.resize(10)
		new_deck.fill(target_card)
		new_deck.shuffle()
		
		var new_hand: Array = []
		var draw_count: int = min(5, new_deck.size())
		for i in range(draw_count):
			# ⚡ OPTIMIZED: Constant time O(1) back popping operation prevents data array shifting loops
			new_hand.append(new_deck.pop_back())
			
		defender_blueprint["combat_deck"] = new_deck
		defender_blueprint["cards_in_hand"] = new_hand
	
	# 4. OVERRIDE CUSTOM TESTING DECKS AND EXTRACT HANDS
	if use_custom_combat_decks:
		if not custom_attacker_combat_deck.is_empty():
			var custom_atk_deck: Array = custom_attacker_combat_deck.duplicate()
			custom_atk_deck.shuffle()
			
			var custom_atk_hand: Array = []
			var draw_count: int = min(5, custom_atk_deck.size())
			for i in range(draw_count):
				# ⚡ OPTIMIZED: Back popping operation update
				custom_atk_hand.append(custom_atk_deck.pop_back())
				
			attacker_blueprint["combat_deck"] = custom_atk_deck
			attacker_blueprint["cards_in_hand"] = custom_atk_hand
			
		if not custom_defender_combat_deck.is_empty():
			var custom_def_deck: Array = custom_defender_combat_deck.duplicate()
			custom_def_deck.shuffle()
			
			var custom_def_hand: Array = []
			var draw_count: int = min(5, custom_def_deck.size())
			for i in range(draw_count):
				# ⚡ OPTIMIZED: Back popping operation update
				custom_def_hand.append(custom_def_deck.pop_back())
				
			defender_blueprint["combat_deck"] = custom_def_deck
			defender_blueprint["cards_in_hand"] = custom_def_hand
			
	# Save historical hand states safely for UI visualization references
	attacker_starting_hand = attacker_blueprint["cards_in_hand"].duplicate()
	defender_starting_hand = defender_blueprint["cards_in_hand"].duplicate()
	
	var attacker_power: int = _calculate_squads_weight(attacker_blueprint["selected_units"])
	var defender_power: int = _calculate_squads_weight(defender_blueprint["selected_units"])
	
	# 5. INSTANTIATE SIMULATION STATE FRAME
	var match_state: Dictionary = _instantiate_match_state(attacker_blueprint, defender_blueprint)
	
	match_state["card_db"] = flat_card_db
	match_state["is_ground_combat"] = active_ground_combat
	
	match_state[SimCombatEngine.Side.ATTACKER]["faction_id"] = current_atk_id
	match_state[SimCombatEngine.Side.DEFENDER]["faction_id"] = current_def_id
	
	var atk_profile = raw_factions.get(current_atk_id)
	var def_profile = raw_factions.get(current_def_id)
	var atk_name_string: String = atk_profile.get("name", FactionRegistry.FactionID.keys()[current_atk_id])
	var def_name_string: String = def_profile.get("name", FactionRegistry.FactionID.keys()[current_def_id])

	attacker_faction_name = atk_name_string
	defender_faction_name = def_name_string

	match_state[SimCombatEngine.Side.ATTACKER]["name"] = atk_name_string
	match_state[SimCombatEngine.Side.DEFENDER]["name"] = def_name_string
	
	# 6. INITIALIZE TELEMETRY LOGGER & RUN MATCH
	var logging_context := {
		"game_stage_string": GameStageGenerator.Stage.keys()[current_stage].capitalize(),
		"matchup_scale": _get_weighted_matchup_string(attacker_power, defender_power),
		"attacker_composition": _format_squad_composition_string(match_state[SimCombatEngine.Side.ATTACKER]["squads"]),
		"defender_composition": _format_squad_composition_string(match_state[SimCombatEngine.Side.DEFENDER]["squads"]),
		"attacker_faction_id": current_atk_id,
		"defender_faction_id": current_def_id,
		"controller_ref": self
	}
	
	G_Logger.initialize_battle_logger(logging_context)
	
	G_Logger.engine_callback("cards_drawn_to_hand", [
		match_state[SimCombatEngine.Side.ATTACKER]["cards_in_hand"],
		match_state[SimCombatEngine.Side.DEFENDER]["cards_in_hand"]
	])
	
	var attacker_won: bool = SimCombatEngine.run_full_match(match_state, flat_card_db, G_Logger.engine_callback)
	G_Logger.finalize_battle_logger(attacker_won)


#endregion

#region Database Flattening

# --- Data Flattening Infrastructure Utilities ---

func _flatten_card_database(raw_db: Dictionary) -> Dictionary:
	var flat_db: Dictionary = {}
	for card_id in raw_db:
		var card: CardData = raw_db[card_id]
		
		assert(card.card_tier != CardData.CardTier.UNASSIGNED, 
			"CRITICAL DATA ERROR: Card '%s' (ID: %d) has an unassigned or missing CardTier property!" % [card.card_name, card_id])
		
		var effects_list: Array = []
		
		for fx in card.general_ability:
			effects_list.append(_flatten_single_effect(fx, true, []))
			
		for fx in card.unit_ability:
			effects_list.append(_flatten_single_effect(fx, false, card.required_unit_types))
				
		flat_db[card_id] = [
			card.offence_icons,  # Index 0
			card.defence_icons,  # Index 1
			card.morale_icons,   # Index 2
			effects_list         # Index 3
		]
	return flat_db


func _flatten_single_effect(fx: CardEffect, is_general_ability: bool, req_unit_types: Array) -> Array:
	var raw_effect_type: int = int(fx.effect_type)
	var value_slot: Variant = fx.value
	var flattened_else_choices: Array = [] # 🎯 Scratchpad for fallback branch data
	
	# BOTH Choice and Conditional node blocks contain packed nested child arrays
	if raw_effect_type == CardData.EffectType.CHOICE or raw_effect_type == CardData.EffectType.CONDITIONAL:
		var flattened_choices: Array = []
		var raw_choices = fx.choices
		
		if not raw_choices.is_empty():
			for sub_fx in raw_choices:
				if sub_fx != null:
					var flat_sub = _flatten_single_effect(sub_fx, is_general_ability, req_unit_types)
					flattened_choices.append(flat_sub)
					
		value_slot = flattened_choices
		
		# 🎯 RECURSIVE INTERCEPT: Flatten the false/else track for conditionals
		if raw_effect_type == CardData.EffectType.CONDITIONAL and not fx.else_choices.is_empty():
			for else_fx in fx.else_choices:
				if else_fx != null:
					var flat_else = _flatten_single_effect(else_fx, is_general_ability, req_unit_types)
					flattened_else_choices.append(flat_else)
	else:
		if value_slot is Array:
			value_slot = 1
		else:
			value_slot = int(value_slot)
			
	var ability_block_type_id: int = 0 if is_general_ability else 1
			
	return [
		fx.effect_type,          # Index 0
		fx.target_type,          # Index 1
		value_slot,              # Index 2 (Primary / True choices array)
		fx.pool_type,            # Index 3 (Dice)
		ability_block_type_id,   # Index 4
		req_unit_types,          # Index 5
		fx.max_spend,            # Index 6
		fx.condition_type,       # Index 7
		fx.destruction_mode,     # Index 8
		fx.gain_token_type,      # Index 9 (Strictly a CombatTokenType enum value)
		flattened_else_choices   # 🎯 Index 10: Fallback / Else choices array
	]

#endregion


#region Match State Helpers

func _instantiate_match_state(atk_blueprint: Dictionary, def_blueprint: Dictionary) -> Dictionary:
	var atk_squads = _build_match_units(atk_blueprint["selected_units"])
	var def_squads = _build_match_units(def_blueprint["selected_units"])
	
	return {
		SimCombatEngine.Side.ATTACKER: {
			"name": "Attacker", 
			"upgrade_deck": atk_blueprint["upgrade_deck"].duplicate(),
			"combat_deck": atk_blueprint["combat_deck"].duplicate(),
			"cards_in_hand": atk_blueprint["cards_in_hand"].duplicate(),
			"play_area": [0,0,0], 
			"squads": atk_squads
		},
		SimCombatEngine.Side.DEFENDER: {
			"name": "Defender", 
			"upgrade_deck": def_blueprint["upgrade_deck"].duplicate(),
			"combat_deck": def_blueprint["combat_deck"].duplicate(),
			"cards_in_hand": def_blueprint["cards_in_hand"].duplicate(),
			"play_area": [0,0,0], 
			"squads": def_squads
		}
	}


func _build_match_units(selected_units: Array) -> Array[Dictionary]:
	var runtime_squads: Array[Dictionary] = []
	
	for b in selected_units:
		var alive_figures: Array[int] = []
		var figures_routed: Array[bool] = []
		
		alive_figures.append(b["health_value"])
		figures_routed.append(false)
		
		runtime_squads.append({
			"name": b["unit_name"], 
			"tier": b["tier"], 
			"unit_type": b["unit_type"],
			"is_ship": b["is_ship"], 
			"combat_value": b["combat_value"], 
			"health_value": b["health_value"], 
			"morale_value": b["morale_value"], 
			"alive_figures": alive_figures, 
			"figures_routed": figures_routed
		})
	return runtime_squads

#endregion

#region Matchup Helpers

func _calculate_squads_weight(selected_units: Array) -> int:
	var total_weight := 0
	for unit in selected_units:
		total_weight += unit["combat_value"] + unit["health_value"] + unit["morale_value"]
	return total_weight


func _get_weighted_matchup_string(atk_weight: int, def_weight: int) -> String:
	var max_weight := float(max(atk_weight, def_weight))
	if max_weight == 0: return "Equal Matchup"
	
	var difference_pct = abs(atk_weight - def_weight) / max_weight
	
	if difference_pct <= 0.25:
		return "Equal Matchup (Power: %d vs %d)" % [atk_weight, def_weight]
	elif atk_weight > def_weight:
		return "AttLarger (Power: %d vs %d)" % [atk_weight, def_weight]
	else:
		return "AttSmaller (Power: %d vs %d)" % [atk_weight, def_weight]

#endregion

#region Basic Helper functions
func _format_squad_composition_string(squads: Array) -> String:
	if squads.is_empty():
		return "None"
		
	var counts: Dictionary = {}
	for s in squads:
		var u_name: String = s["name"]
		if counts.has(u_name):
			counts[u_name] += 1
		else:
			counts[u_name] = 1
			
	var items: Array[String] = []
	for unit_name in counts:
		items.append("%dx %s" % [counts[unit_name], unit_name])
		
	return ", ".join(items)


func _print_cards_drawn(atk_drawn_ids: Array, def_drawn_ids: Array) -> void:
	print("\n=== PHASE 1.5: DRAWING COMBAT HANDS ===")
	print("Attacker Draws:")
	for card_id in atk_drawn_ids:
		var card: CardData = card_db.get(card_id)
		var card_name: String = card.card_name if card != null else "Card #" + str(card_id)
		print("  - " + card_name)
		
	print("") # Spacer
	
	print("Defender Draws:")
	for card_id in def_drawn_ids:
		var card: CardData = card_db.get(card_id)
		var card_name: String = card.card_name if card != null else "Card #" + str(card_id)
		print("  - " + card_name)
	print("=======================================")


func get_card_metadata(card_id: int, property_name: String) -> Variant:
	if not card_db.has(card_id):
		push_error("Metadata Error: Card ID %d not found." % card_id)
		return null
		
	var card: CardData = card_db[card_id]
	if not property_name in card:
		push_error("Metadata Error: Property '%s' does not exist on CardData." % property_name)
		return null
		
	var value: Variant = card.get(property_name)
	if property_name == "required_unit_types" and value is int:
		return CardData.UnitType.keys()[value].capitalize()
		
	return value


## Dynamically resolves the correct combat stage based on randomization flags
func get_current_stage() -> GameStageGenerator.Stage:
	if is_random_stage:
		return randi_range(0, max_stage_index) as GameStageGenerator.Stage
	
	return debug_stage

#endregion
