extends Node

@export var is_combat_debugger_used: bool = true
@export var total_iterations: int = 1000000

enum GameStage { EARLY, MID, LATE }
@export var current_stage: GameStage = GameStage.EARLY

@export var attacker_faction: FactionRegistry.FactionID = FactionRegistry.FactionID.SM
@export var defender_faction: FactionRegistry.FactionID = FactionRegistry.FactionID.ORKS

var is_ground_combat := true

@onready var card_db: Dictionary = CardRegistry.get_database()


func _ready() -> void:
	if is_combat_debugger_used:
		print("--- COUPLING SINGLE MATCH OBSERVER SANDBOX ---")
		run_single_logged_battle()
	else:
		print("--- DISPATCHING PRODUCTION MASS RUNS ---")
		# Pure high-speed loop logic goes here when ready...

func run_single_logged_battle() -> void:
	var raw_cards: Dictionary = CardRegistry.get_database()
	var raw_factions: Dictionary = FactionRegistry.get_database()
	
	var flat_card_db: Dictionary = _flatten_card_database(raw_cards)
	
	# 1. Randomize battle scale (1-2 Small, 3 Med, 4-5 Large)
	var att_count := randi_range(1, 5)
	var def_count := randi_range(1, 5)
	
	# 2. Compile type-hinted arrays of compliant tiers matching stage constraints
	var attacker_tiers := _generate_stage_tiers(current_stage, att_count)
	var defender_tiers := _generate_stage_tiers(current_stage, def_count)
	
	# 3. Pull unit specifications out of registry records via generated profiles
	var attacker_blueprint: Dictionary = _prepare_faction_blueprint(attacker_faction, raw_factions, attacker_tiers)
	var defender_blueprint: Dictionary = _prepare_faction_blueprint(defender_faction, raw_factions, defender_tiers)
	
	var attacker_power: int = _calculate_squads_weight(attacker_blueprint["selected_units"])
	var defender_power: int = _calculate_squads_weight(defender_blueprint["selected_units"])
	
	var match_state: Dictionary = _instantiate_match_state(attacker_blueprint, defender_blueprint)
	
	# --- YOUR LOGGING OBSERVER CALLBACK ---
	var debugger_hook: Callable = func(event_type: String, data: Array):
		match event_type:
			"combat_start":
				var atk_side: Dictionary = data[0]
				var def_side: Dictionary = data[1]
				var stage_str: String = GameStage.keys()[current_stage].capitalize()
				print("\n==================  STARTED COMBAT ==================")
				print("Game stage: %s" % stage_str)
				print("Matchup Scale Classification: %s" % _get_weighted_matchup_string(attacker_power, defender_power))
				print("Attacker Forces: %s" % _format_squad_composition_string(atk_side["squads"]))
				print("Defender Forces: %s" % _format_squad_composition_string(def_side["squads"]))
			"dice_pool_calculated":
				print("Calculated Combat Values -> Attacker: %d, Defender: %d" % [data[0], data[1]])
				print("\n=== PHASE 1.0: ROLL DICE STEP ===")
			"dice_rolled":
				print("  -> %s Rolls: %d ⚔️, %d 🛡️, %d 🦅, %d 🦅 from units)" % [data[0], data[1], data[2], data[3], data[4]])
			"cards_drawn_to_hand":
				_print_cards_drawn(data[0], data[1])
			"round_start":
				print("")
				print("\n🔄--- COMBAT ROUND %d ---" % (data[0] + 1))
			"unit_status_logged":
				print("    📊 %s units unrouted: %s" % [data[0], data[1]])
				print("    📊 %s units routed: %s" % [data[0], data[2]])
			"card_icons_calculated":
				print("    🎴 %s Card Icons on play area -> Offence: %d, Defence: %d, Morale: %d" % [data[0], data[1], data[2], data[3]])
			"ability_block_started":
				print("")
				var role: String = data[0]
				var block_label: String = data[1] # "General" or "Unit"
				print(" [%s] Processing %s Abilities..." % [role, block_label])
			"ability_triggered":
				var card_id: int = data[0]
				var card_name: String = get_card_metadata(card_id, "card_name")
				print("  [*] %s. %s" % [card_name, data[1]])
			"pools_updated":
				print("")
				print("  Current Action Frame -> %s Pool: %d ⚔️, %d 🛡️" % [data[0], data[1], data[2]])
			"damage_calculated":
				print("")
				print("  -----[ASSESS DAMAGE STEP]-----")
				print("Net Impact: Defender suffers %d 💥 | Attacker suffers %d 💥" % [data[0], data[1]])
			"unit_routed":
				print("    -> 🏳️ %s '%s' took %d damage and was forced to ROUT!" % [data[0], data[1], data[2]])
			"unit_rallied":
				var role: String = data[0]
				var squad_name: String = data[1]
				var health: int = data[2]
				var card_name: String = get_card_metadata(data[3], "card_name")
				print("    -> 🤝 %s successfully RALLIED '%s' (Health: %d) using %s!" % [role, squad_name, health, card_name])
			"unit_ability_not_resolved":
				var role: String = data[0]
				var card_id: int = data[1]
				var card_name: String = get_card_metadata(card_id, "card_name")
				var req_unit: String = get_card_metadata(card_id, "required_unit_types")
				
				print("    -> 🚫 %s Unit Ability SKIPPED: '%s' requires an unrouted '%s' unit." % [role, card_name, req_unit])
			"damage_absorbed":
				print("    -> 🛡️ %s '%s' safely absorbed %d damage while routed." % [data[0], data[1], data[2]])
			"unit_destroyed":
				var cond = "ROUTED" if data[3] else "HEALTHY"
				print("    -> 💀 %s '%s' (%s) took %d damage and was completely DESTROYED!" % [data[0], data[1], cond, data[2]])
			"early_termination":
				print("\n[ALERT] Sudden Death! An entire side has been eliminated from the theater.")
			"victory_wipeout":
				print("\n[RESULT] Victory achieved! Tactical deployment complete. Winner: %s by clean wipeout." % data[0])
			"tiebreaker_figures":
				print("\n[STALEMATE] End of Phase 3. Counting standing figures -> Attacker: %d, Defender: %d" % [data[0], data[1]])
			"tiebreaker_morale":
				print("[STALEMATE] Figure parity detected. Evaluating final Morale Pools -> Attacker: %d, Defender: %d" % [data[0], data[1]])
			"bonus_dice_rolled":
				print("   ↳ 🎲 %s Dice roll: +%d ⚔️ | +%d 🛡️ | +%d 🦅 " % [
		data[0], data[1], data[2], data[3]])
			
	# Run the combat crucible sandbox using your custom logging strings
	var attacker_won: bool = SimCombatEngine.run_full_match(match_state, flat_card_db, debugger_hook)
	
	print("\n[SANDBOX FINISHED] Combat evaluation engine sequence complete. Winner evaluated: %s" % ("ATTACKER" if attacker_won else "DEFENDER"))

# --- Progression Rule Setup Utilities ---

func _generate_stage_tiers(stage: GameStage, total_units: int) -> PackedInt32Array:
	var tiers := PackedInt32Array()
	var weights := PackedFloat32Array()
	var counts := [0, 0, 0, 0] # Tracks [T0, T1, T2, T3] generated inside this call
	
	match stage:
		GameStage.EARLY:
			weights = PackedFloat32Array([0.65, 0.30, 0.05, 0.00])
		GameStage.MID:
			weights = PackedFloat32Array([0.35, 0.40, 0.25, 0.00])
		GameStage.LATE:
			weights = PackedFloat32Array([0.15, 0.25, 0.35, 0.25])

	while tiers.size() < total_units:
		var rolled_tier := _roll_weighted_index(weights)
		var valid := true
		
		match stage:
			GameStage.EARLY:
				if rolled_tier == 2 and counts[2] >= 1: valid = false
			GameStage.MID:
				if rolled_tier == 2 and counts[2] >= 2: valid = false
			GameStage.LATE:
				if rolled_tier == 0 and counts[0] >= 2: valid = false
				if rolled_tier == 3 and counts[3] >= 1: valid = false
				
		if valid:
			tiers.append(rolled_tier)
			counts[rolled_tier] += 1
			
	return tiers

func _roll_weighted_index(weights: PackedFloat32Array) -> int:
	var sum := 0.0
	for w in weights: 
		sum += w
		
	var roll := randf() * sum
	var run_sum := 0.0
	for i in range(weights.size()):
		run_sum += weights[i]
		if roll <= run_sum: 
			return i
	return 0

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
	
	# Define a tolerance threshold (e.g., within 15% of each other is considered an "Equal" fight)	
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
			effects_list.append(_flatten_single_effect(fx, true, CardData.UnitType.NONE))
			
		for fx in card.unit_ability:
			effects_list.append(_flatten_single_effect(fx, false, card.required_unit_types))
				
		flat_db[card_id] = [
			card.offence_icons,  # Index 0
			card.defence_icons,  # Index 1
			card.morale_icons,   # Index 2
			effects_list         # Index 3
		]
	return flat_db

func _flatten_single_effect(fx: CardEffect, is_general_ability: bool, req_unit_val: int) -> Array:
	var raw_effect_type: int = int(fx.effect_type)
	var value_slot: Variant = fx.value
	
	# Future-proofed checking using the exact enum path instead of integer values
	if raw_effect_type == CardData.EffectType.CHOICE:
		var flattened_choices: Array = []
		var raw_choices = fx.choices
		
		if not raw_choices.is_empty():
			for sub_fx in raw_choices:
				if sub_fx != null:
					# Nested sub-choices within a choice container default to generic flags
					var flat_sub = _flatten_single_effect(sub_fx, true, CardData.UnitType.NONE)
					flattened_choices.append(flat_sub)
					
		value_slot = flattened_choices
	else:
		# Safeguard for atomic operations (Dice, Rally, Reroll)
		if value_slot is Array:
			value_slot = 1
		else:
			value_slot = int(value_slot)
			
	# Convert the boolean flag cleanly back into a 0 or 1 integer structure for your engine layout
	var ability_block_type_id: int = 0 if is_general_ability else 1
			
	return [
		fx.effect_type,         # Index 0
		fx.target_type,         # Index 1
		value_slot,             # Index 2
		fx.pool_type,           # Index 3
		ability_block_type_id,  # Index 4
		req_unit_val            # Index 5
	]

func _prepare_faction_blueprint(faction_id: int, factions: Dictionary, randomized_tiers: PackedInt32Array) -> Dictionary:
	var faction_raw = factions[faction_id]
	
	# Index ONLY theater-compliant registry configurations into our O(1) tier map
	var registry_units_by_tier := {}
	for unit_data in faction_raw["units"]:
		# THEATER EXCLUSION LOGIC:
		# If is_ground_combat is true, skip units where is_ship is true.
		# If is_ground_combat is false, skip units where is_ship is false.
		if is_ground_combat == unit_data["is_ship"]:
			continue # Skip this unit; it doesn't match the active theater mode
			
		registry_units_by_tier[unit_data["tier"]] = unit_data

	# Gather the database entries matching our randomized composition layout
	var selected_units_blueprints: Array = []
	for tier in randomized_tiers:
		if registry_units_by_tier.has(tier):
			selected_units_blueprints.append(registry_units_by_tier[tier])
		else:
			push_error("Faction %d lacks a theater-compliant configuration profile for Tier %d!" % [faction_id, tier])

	return {
		"combat_deck": faction_raw["combat_deck"].duplicate(), 
		"selected_units": selected_units_blueprints
	}

func _instantiate_match_state(atk_blueprint: Dictionary, def_blueprint: Dictionary) -> Dictionary:
	var atk_squads = _build_match_units(atk_blueprint["selected_units"])
	var def_squads = _build_match_units(def_blueprint["selected_units"])
	return {
		"attacker": {"name": "Attacker", "combat_deck": atk_blueprint["combat_deck"].duplicate(), "play_area": [0,0,0], "squads": atk_squads},
		"defender": {"name": "Defender", "combat_deck": def_blueprint["combat_deck"].duplicate(), "play_area": [0,0,0], "squads": def_squads}
	}

func _build_match_units(selected_units: Array) -> Array[Dictionary]:
	var runtime_squads: Array[Dictionary] = []
	
	for b in selected_units:
		var alive_figures: Array[int] = []
		var figures_routed: Array[bool] = []
		
		# Each instance block rolled by the generator translates into 1 tracked combat squad item.
		# Instantiating the structure using its native health boundary properties.
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
		# Fetch the CardData object from the dictionary
		var card: CardData = card_db.get(card_id)
		# Safe fallback just in case an ID doesn't exist in the database
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
	
	# 2. Check if the property actually exists on the CardData object
	if not property_name in card:
		push_error("Metadata Error: Property '%s' does not exist on CardData." % property_name)
		return null
		
	# 3. Dynamic lookup
	var value: Variant = card.get(property_name)
	
	# 4. Smart Conversion: If they asked for the unit type requirement, convert the enum to a pretty string
	if property_name == "required_unit_types" and value is int:
		return CardData.UnitType.keys()[value].capitalize()
		
	return value
