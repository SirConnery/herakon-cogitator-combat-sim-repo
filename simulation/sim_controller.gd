extends Node

@export var is_combat_debugger_used: bool = true
@export var total_iterations: int = 1000000

enum GameStage { EARLY, MID, LATE }
@export var current_stage: GameStage = GameStage.EARLY

@export var attacker_faction: FactionRegistry.FactionID = FactionRegistry.FactionID.SM
@export var defender_faction: FactionRegistry.FactionID = FactionRegistry.FactionID.ORKS

func _ready() -> void:
	if is_combat_debugger_used:
		print("--- COUPLING SINGLE MATCH OBSERVER SANDBOX ---")
		run_single_verbose_battle()
	else:
		print("--- DISPATCHING PRODUCTION MASS RUNS ---")
		# Pure high-speed loop logic goes here when ready...

func run_single_verbose_battle() -> void:
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
			"dice_rolled":
				print("  -> %s Rolls: %d Offence, %d Defence, %d Morale, %d Overall Morale)" % [data[0], data[1], data[2], data[3], data[4]])
			"round_start":
				print("\n--- COMBAT ROUND %d ---" % (data[0] + 1))
				print("  Cards Drawn -> Attacker Card ID: %d | Defender Card ID: %d" % [data[1], data[2]])
			"ability_triggered":
				print("  [*] CARD EFFECT: %s Player resolved: '%s'" % [data[0], data[1]])
			"pools_updated":
				print("  Current Action Frame -> %s Pool: %d ⚔️, %d 🛡️" % [data[0], data[1], data[2]])
			"damage_calculated":
				print("  [ASSESS DAMAGE STEP] Net Impact: Defender suffers %d 💥 | Attacker suffers %d 💥" % [data[0], data[1]])
			"unit_routed":
				print("    -> ⚠️ %s '%s' took %d damage and was forced to ROUT!" % [data[0], data[1], data[2]])
			"damage_absorbed":
				print("    -> 🛡️ %s '%s' safely absorbed %d damage while routed." % [data[0], data[1], data[2]])
			"unit_destroyed":
				var cond = "ROUTED" if data[3] else "HEALTHY"
				print("    -> 💥 %s '%s' (%s) took %d damage and was completely DESTROYED!" % [data[0], data[1], cond, data[2]])
			"early_termination":
				print("\n[ALERT] Sudden Death! An entire side has been eliminated from the theater.")
			"victory_wipeout":
				print("\n[RESULT] Victory achieved! Tactical deployment complete. Winner: %s by clean wipeout." % data[0])
			"tiebreaker_figures":
				print("\n[STALEMATE] End of Phase 3. Counting standing figures -> Attacker: %d, Defender: %d" % [data[0], data[1]])
			"tiebreaker_morale":
				print("[STALEMATE] Figure parity detected. Evaluating final Morale Pools -> Attacker: %d, Defender: %d" % [data[0], data[1]])

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

func _flatten_card_database(cards: Dictionary) -> Dictionary:
	var flat_db: Dictionary = {}
	for id in cards:
		var card: CardData = cards[id]
		var gen_type: int = CardData.EffectType.NONE
		var gen_target: int = CardData.TargetType.SELF
		var gen_value: int = 0
		if card.general_ability:
			gen_type = card.general_ability.effect_type
			gen_target = card.general_ability.target_type
			gen_value = card.general_ability.value
		flat_db[id] = [card.offence_icons, card.defence_icons, card.morale_icons, gen_type, gen_target, gen_value]
	return flat_db

func _prepare_faction_blueprint(faction_id: int, factions: Dictionary, randomized_tiers: PackedInt32Array) -> Dictionary:
	var faction_raw = factions[faction_id]
	
	# Index the registry configurations into an O(1) tier map dictionary
	var registry_units_by_tier := {}
	for unit_data in faction_raw["units"]:
		registry_units_by_tier[unit_data["tier"]] = unit_data

	# Gather the database entries matching our randomized composition layout
	var selected_units_blueprints: Array = []
	for tier in randomized_tiers:
		if registry_units_by_tier.has(tier):
			selected_units_blueprints.append(registry_units_by_tier[tier])
		else:
			push_error("Faction %d lacks a registry configuration profile for Tier %d!" % [faction_id, tier])

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
			"space_unit": b["space_unit"], 
			"combat_value": b["combat_value"], 
			"health_value": b["health_value"], 
			"morale_value": b["morale_value"], 
			"alive_figures": alive_figures, 
			"figures_routed": figures_routed
		})
	return runtime_squads

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
