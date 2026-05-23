extends Node
class_name SimController

@export var is_combat_debugger_used: bool = true
@export var total_iterations: int = 1000000

@export var current_stage: GameStageGenerator.Stage = GameStageGenerator.Stage.EARLY
#@export var current_stage: GameStageGenerator.Stage = randi_range(0, 2) # change to this for random stages

@export var attacker_faction: FactionRegistry.FactionID = FactionRegistry.FactionID.SM
@export var defender_faction: FactionRegistry.FactionID = FactionRegistry.FactionID.ORKS

var is_ground_combat := true

@onready var card_db: Dictionary = CardRegistry.get_database()


#region Variables for UI

var attacker_starting_hand := []
var defender_starting_hand := []
var attacker_faction_name := ""
var defender_faction_name := ""

#endregion

func _ready() -> void:
	if is_combat_debugger_used:
		print("--- COUPLING SINGLE MATCH OBSERVER SANDBOX ---")
		run_single_logged_battle()
	else:
		print("--- DISPATCHING PRODUCTION MASS RUNS ---")
		# Pure high-speed loop logic goes here when ready...


func show_ui() -> void:
	pass


func run_single_logged_battle() -> void:
	var raw_cards: Dictionary = CardRegistry.get_database()
	var raw_factions: Dictionary = FactionRegistry.get_database()
	
	var flat_card_db: Dictionary = _flatten_card_database(raw_cards)
	
	# 1. Randomize battle scale boundaries (1-2 Small, 3 Med, 4-5 Large)
	var att_count := randi_range(1, 5)
	var def_count := randi_range(1, 5)
	
	# 2. Directly compile faction packages via centralized Scenario Director Generator
	var attacker_blueprint: Dictionary = GameStageGenerator.generate_faction_blueprint(attacker_faction, current_stage, att_count, is_ground_combat, raw_factions)
	var defender_blueprint: Dictionary = GameStageGenerator.generate_faction_blueprint(defender_faction, current_stage, def_count, is_ground_combat, raw_factions)
	
	# Capture and store frozen copies of starting hands for decoupled UI pulling passes
	attacker_starting_hand = attacker_blueprint["cards_in_hand"].duplicate()
	defender_starting_hand = defender_blueprint["cards_in_hand"].duplicate()
	
	var attacker_power: int = _calculate_squads_weight(attacker_blueprint["selected_units"])
	var defender_power: int = _calculate_squads_weight(defender_blueprint["selected_units"])
	
	var match_state: Dictionary = _instantiate_match_state(attacker_blueprint, defender_blueprint)
	
	# Inject the flat card database directly into the state container context
	match_state["card_db"] = flat_card_db
	
	var atk_profile = raw_factions.get(attacker_faction)
	var def_profile = raw_factions.get(defender_faction)

	# Extracting via your active "name" property key, fallback to stringified enum on missing entry
	var atk_name_string: String = atk_profile.get("name", FactionRegistry.FactionID.keys()[attacker_faction])
	var def_name_string: String = def_profile.get("name", FactionRegistry.FactionID.keys()[defender_faction])

	# UPDATED: Cache resolved faction name strings for dynamic UI pulling passes
	attacker_faction_name = atk_name_string
	defender_faction_name = def_name_string

	match_state[SimCombatEngine.Side.ATTACKER]["name"] = atk_name_string
	match_state[SimCombatEngine.Side.DEFENDER]["name"] = def_name_string
	
	# Package dynamic helper metadata into a context block for G_Logger to consume asynchronously
	var logging_context := {
		"game_stage_string": GameStageGenerator.Stage.keys()[current_stage].capitalize(),
		"matchup_scale": _get_weighted_matchup_string(attacker_power, defender_power),
		"attacker_composition": _format_squad_composition_string(match_state[SimCombatEngine.Side.ATTACKER]["squads"]),
		"defender_composition": _format_squad_composition_string(match_state[SimCombatEngine.Side.DEFENDER]["squads"]),
		"controller_ref": self
	}
	
	# Initialize our logging channel with references to the active engine calculations
	G_Logger.initialize_battle_logger(logging_context)
	
	# Broadcast open-hand draw configuration metrics to UI hook arrays manually 
	G_Logger.engine_callback("cards_drawn_to_hand", [
		match_state[SimCombatEngine.Side.ATTACKER]["cards_in_hand"],
		match_state[SimCombatEngine.Side.DEFENDER]["cards_in_hand"]
	])
	
	# Run the high-speed crucible engine loop using the centralized direct singleton router
	var attacker_won: bool = SimCombatEngine.run_full_match(match_state, flat_card_db, G_Logger.engine_callback)
	
	G_Logger.finalize_battle_logger(attacker_won)


## Calculates the total structural combat weight of a generated squad list
func _calculate_squads_weight(selected_units: Array) -> int:
	var total_weight := 0
	for unit in selected_units:
		total_weight += unit["combat_value"] + unit["health_value"] + unit["morale_value"]
	return total_weight


## Compares the total calculated power weights to classify the matchup thresholds
func _get_weighted_matchup_string(atk_weight: int, def_weight: int) -> String:
	var max_weight := float(max(atk_weight, def_weight))
	if max_weight == 0: return "Equal Matchup"
	
	var difference_pct = abs(atk_weight - def_weight) / max_weight
	
	# Define a tolerance threshold (e.g., within 25% of each other is considered an "Equal" fight)    
	if difference_pct <= 0.25:
		return "Equal Matchup (Power: %d vs %d)" % [atk_weight, def_weight]
	elif atk_weight > def_weight:
		return "AttLarger (Power: %d vs %d)" % [atk_weight, def_weight]
	else:
		return "AttSmaller (Power: %d vs %d)" % [atk_weight, def_weight]


# --- Data Flattening Infrastructure Utilities ---

func _flatten_card_database(raw_db: Dictionary) -> Dictionary:
	var flat_db: Dictionary = {}
	for card_id in raw_db:
		var card: CardData = raw_db[card_id]
		var effects_list: Array = []
		
		# Always treat abilities as clean sequential loops
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
		req_unit_types          # Index 5 - Stores the flat requirement Array directly
	]


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
		
		# Each instance block rolled by the generator translates into 1 tracked combat squad item.
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


#region Helper functions

## Helper function to dynamically count duplicates and pretty-print composition rosters
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
#endregion
