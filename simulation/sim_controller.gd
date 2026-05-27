extends Node
class_name SimController


#region Mass Combat Sim variables
# ─── RUN MODE CONFIGURATION ───
var iterations_per_matchup: int = 1000

# ─── MATRIX BATCH CONFIGURATION ───
var factions_to_sim: Array[FactionRegistry.FactionID] = [
	FactionRegistry.FactionID.ORKS,
	FactionRegistry.FactionID.SPACE_MARINES
]

#endregion

#region Single Combat variables
# ─── SINGLE SANBOX CONFIGURATION ───
var random_factions_in_single_combat: bool = false
var attacker_faction_in_single_combat: FactionRegistry.FactionID = FactionRegistry.FactionID.ORKS
var defender_faction_in_single_combat: FactionRegistry.FactionID = FactionRegistry.FactionID.SPACE_MARINES


# ─── ENVIRONMENT & FORMATS ───
var is_random_stage := true
var debug_stage: GameStageGenerator.Stage = GameStageGenerator.Stage.LATE
var random_combat_type: bool = false
var is_ground_combat := true

# ─── CUSTOM DECK OVERRIDES ───
var use_custom_combat_decks: bool = false
var custom_attacker_combat_deck: Array[int] = []
var custom_defender_combat_deck: Array[int] = []

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
	exporter.clear_previous_data()

	var global_match_index := 0

	print("============ STARTING MATRIX SIMULATION ============")
	print("Pool Size: %d factions  |  Matches per pairing: %d" % [factions_to_sim.size(), iterations_per_matchup])
	print("Streaming raw records to disk stream...")

	for atk_id in factions_to_sim:
		for def_id in factions_to_sim:
			if atk_id == def_id:
				continue
				
			var atk_profile = raw_factions.get(atk_id)
			var def_profile = raw_factions.get(def_id)
			var atk_name_string: String = atk_profile.get("name", FactionRegistry.FactionID.keys()[atk_id])
			var def_name_string: String = def_profile.get("name", FactionRegistry.FactionID.keys()[def_id])

			print(" -> Simulating Pairing Matrix Block: [Atk] %s vs [Def] %s..." % [atk_name_string, def_name_string])

			for i in range(iterations_per_matchup):
				current_stage = get_current_stage()
				
				var att_count := randi_range(1, 5)
				var def_count := randi_range(1, 5)
				
				var attacker_blueprint: Dictionary = GameStageGenerator.generate_faction_blueprint(atk_id, current_stage, att_count, is_ground_combat, raw_factions)
				var defender_blueprint: Dictionary = GameStageGenerator.generate_faction_blueprint(def_id, current_stage, def_count, is_ground_combat, raw_factions)
				
				var atk_initial_hand: Array = attacker_blueprint["cards_in_hand"].duplicate()
				var def_initial_hand: Array = defender_blueprint["cards_in_hand"].duplicate()
				
				var match_state: Dictionary = _instantiate_match_state(attacker_blueprint, defender_blueprint)
				
				match_state["card_db"] = flat_card_db
				match_state["is_ground_combat"] = is_ground_combat
				
				match_state[SimCombatEngine.Side.ATTACKER]["faction_id"] = atk_id
				match_state[SimCombatEngine.Side.DEFENDER]["faction_id"] = def_id
				match_state[SimCombatEngine.Side.ATTACKER]["name"] = atk_name_string
				match_state[SimCombatEngine.Side.DEFENDER]["name"] = def_name_string
				
				var attacker_won: bool = SimCombatEngine.run_full_match(match_state, flat_card_db, Callable())
				
				exporter.log_match(
					global_match_index, 
					int(current_stage), 
					atk_id,
					def_id,
					attacker_won, 
					atk_initial_hand, 
					def_initial_hand
				)
				
				global_match_index += 1
					
	exporter.flush_to_disk()
	print("============ MATRIX SIMULATION COMPLETE ============")
	print("Total Global Matches Run across All Matrices: %d" % global_match_index)

#endregion

#region Single Combat simulation

## Runs a single, highly configurable battle sandbox with full step-by-step logging telemetry
func run_single_logged_combat() -> void:
	print("🚨 run_single_logged_battle() is executing!")
	
	# 1. RESOLVE CONFIGURABLE ENVIRONMENT RULES
	current_stage = get_current_stage()
	
	var active_ground_combat := is_ground_combat
	if random_combat_type:
		active_ground_combat = (randi() % 2 == 0)
		
	# 2. RESOLVE CONFIGURABLE MATCHUP IDENTITIES
	var current_atk_id: FactionRegistry.FactionID
	var current_def_id: FactionRegistry.FactionID
	
	if random_factions_in_single_combat:
		if factions_to_sim.size() < 2:
			push_error("Single Combat Error: factions_to_sim must contain at least 2 unique factions for random generation.")
			return
		var available_factions = factions_to_sim.duplicate()
		var atk_index := randi_range(0, available_factions.size() - 1)
		current_atk_id = available_factions[atk_index]
		available_factions.remove_at(atk_index)
		
		var def_index := randi_range(0, available_factions.size() - 1)
		current_def_id = available_factions[def_index]
	else:
		current_atk_id = attacker_faction_in_single_combat
		current_def_id = defender_faction_in_single_combat
		
	# 3. EXTRACT DATABASES & BLUEPRINTS
	var raw_cards: Dictionary = CardRegistry.get_database()
	var raw_factions: Dictionary = FactionRegistry.get_database()
	var flat_card_db: Dictionary = _flatten_card_database(raw_cards)
	
	var att_count := randi_range(1, 5)
	var def_count := randi_range(1, 5)
	
	var attacker_blueprint: Dictionary = GameStageGenerator.generate_faction_blueprint(current_atk_id, current_stage, att_count, active_ground_combat, raw_factions)
	var defender_blueprint: Dictionary = GameStageGenerator.generate_faction_blueprint(current_def_id, current_stage, def_count, active_ground_combat, raw_factions)
	
	# 4. OVERRIDE CUSTOM TESTING DECKS IF SPECIFIED
	if use_custom_combat_decks:
		if not custom_attacker_combat_deck.is_empty():
			attacker_blueprint["combat_deck"] = custom_attacker_combat_deck.duplicate()
		if not custom_defender_combat_deck.is_empty():
			defender_blueprint["combat_deck"] = custom_defender_combat_deck.duplicate()
			
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
	
	if raw_effect_type == CardData.EffectType.CHOICE:
		var flattened_choices: Array = []
		var raw_choices = fx.choices
		
		if not raw_choices.is_empty():
			for sub_fx in raw_choices:
				if sub_fx != null:
					var flat_sub = _flatten_single_effect(sub_fx, is_general_ability, req_unit_types)
					flattened_choices.append(flat_sub)
					
		value_slot = flattened_choices
	else:
		if value_slot is Array:
			value_slot = 1
		else:
			value_slot = int(value_slot)
			
	var ability_block_type_id: int = 0 if is_general_ability else 1
			
	return [
		fx.effect_type,          # Index 0
		fx.target_type,          # Index 1
		value_slot,              # Index 2
		fx.pool_type,            # Index 3
		ability_block_type_id,  # Index 4
		req_unit_types          # Index 5
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
