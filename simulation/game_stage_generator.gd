class_name GameStageGenerator

enum Stage { EARLY, MID, LATE }

## Master testing toggle: When true, forces blueprints to bypass dynamic generation and use debug pools
static var use_debug_deck_for_testing := false
static var debug_deck_uses_1_card := true


static func choose_weighted(weights: PackedFloat32Array) -> int:
	var sum := 0.0
	for w in weights:
		sum += w
	
	var roll := randf() * sum
	var running_sum := 0.0
	for i in range(weights.size()):
		running_sum += weights[i]
		if roll <= running_sum:
			return i
	return 0


## High-level scenario manager that constructs, compiles, and delivers the complete operational faction deployment bundle
static func generate_faction_blueprint(faction_id: int, stage: Stage, unit_count: int, is_ground_combat: bool, factions_db: Dictionary) -> Dictionary:
	var faction_raw = factions_db[faction_id]
	
	# 1. Map theater-compliant units and extract their absolute capacity thresholds
	var max_counts_by_tier := {}
	var registry_units_by_tier := {}
	
	for unit_data in faction_raw["units"]:
		if is_ground_combat == unit_data["is_ship"]:
			continue # Skip mismatching units
			
		registry_units_by_tier[unit_data["tier"]] = unit_data
		# Cache the hard limit directly from the database entry (e.g., 3 for Titans, 6 for Scouts)
		max_counts_by_tier[unit_data["tier"]] = unit_data.get("unit_count", 99)

	# 2. Generate the randomized composition tiers matching stage weights AND database limits
	var randomized_tiers := generate_composition(stage, unit_count, is_ground_combat, max_counts_by_tier)
	
	# 3. Compile standalone single-figure instances safely using deep duplication
	var selected_units_blueprints: Array = []
	for tier in randomized_tiers:
		if registry_units_by_tier.has(tier):
			# .duplicate(true) ensures each figure has its own individual memory reference for tracking damage/routing!
			selected_units_blueprints.append(registry_units_by_tier[tier].duplicate(true))
		elif is_ground_combat:
			push_error("Faction %d lacks ground units for Tier %d!" % [faction_id, tier])

	# 4. Compile the structural combat deck using our decoupled routing handler
	var compiled_deck := compile_combat_deck(faction_raw)

	# 5. Shuffle the compiled deck to randomize card distribution order
	compiled_deck.shuffle()

	# 6. Extract exactly 5 cards directly off the top into your initial starting hand
	var drawn_hand: Array = []
	var draw_count: int = min(5, compiled_deck.size())
	for i in range(draw_count):
		drawn_hand.append(compiled_deck.pop_at(0))

	return {
		"upgrade_deck": faction_raw.get("upgrade_deck", []).duplicate(),
		"combat_deck": compiled_deck,
		"cards_in_hand": drawn_hand,
		"selected_units": selected_units_blueprints
	}


## Compiles the combat deck based on current test configurations or upgrade deck drafting rules
static func compile_combat_deck(faction_raw: Dictionary) -> Array:
	if use_debug_deck_for_testing:
		var debug_pool: Array = faction_raw.get("debug_deck", [])
		
		if debug_deck_uses_1_card:
			assert(debug_pool.size() > 0, "CRITICAL CONFIG ERROR: debug_deck is empty but debug_deck_uses_1_card is enabled!")
			
			var target_card = debug_pool[0]
			var single_card_deck: Array = []
			for i in range(10):
				single_card_deck.append(target_card)
			return single_card_deck
			
		return debug_pool.duplicate()
	
	var upgrade_pool: Array = faction_raw.get("upgrade_deck", [])
	var compiled_deck: Array = []
	
	if upgrade_pool.is_empty():
		return faction_raw.get("combat_deck", []).duplicate()
		
	for i in range(10):
		var random_idx := randi() % upgrade_pool.size()
		compiled_deck.append(upgrade_pool[random_idx])
		
	return compiled_deck


## Generates a randomized list of unit tiers based on game stage, target unit count, and database pool limits
static func generate_composition(stage: Stage, unit_count: int, is_ground_combat: bool, max_counts_by_tier: Dictionary) -> PackedInt32Array:
	var composition := PackedInt32Array()
	
	var base_weights := PackedFloat32Array()
	var tier_counts := [0, 0, 0, 0] # Tracks [T0, T1, T2, T3] generated figures so far
	
	match stage:
		Stage.EARLY:
			base_weights = PackedFloat32Array([0.65, 0.30, 0.05, 0.00])
		Stage.MID:
			base_weights = PackedFloat32Array([0.35, 0.40, 0.25, 0.00])
		Stage.LATE:
			base_weights = PackedFloat32Array([0.15, 0.25, 0.35, 0.25])

	# --- VOID THEATER WEIGHT REBALANCING ---
	if not is_ground_combat:
		base_weights[1] = 0.0
		base_weights[3] = 0.0
		
		var remaining_sum = base_weights[0] + base_weights[2]
		if remaining_sum > 0.0:
			base_weights[0] = base_weights[0] / remaining_sum
			base_weights[2] = base_weights[2] / remaining_sum
		else:
			base_weights[0] = 0.70
			base_weights[2] = 0.30

	# Loop to fill the requested unit count
	while composition.size() < unit_count:
		var active_weights := base_weights.duplicate()
		
		# --- DYNAMIC DATABASE LIMIT ENFORCEMENT ---
		# Cycles through your tiers and kills the selection weight if the figure count hits the database cap
		for tier in range(active_weights.size()):
			if max_counts_by_tier.has(tier):
				if tier_counts[tier] >= max_counts_by_tier[tier]:
					active_weights[tier] = 0.0

		# --- EMERGENCY ESCAPE HATCH ---
		var total_weight_pool := 0.0
		for w in active_weights:
			total_weight_pool += w
			
		if total_weight_pool <= 0.0:
			push_warning("GameStageGenerator: Generation stopped. Available matching unit pools are completely exhausted at %d units." % composition.size())
			break

		# Roll using our safe, mutated weight array
		var chosen_tier := choose_weighted(active_weights)
		
		# Lock it in
		composition.append(chosen_tier)
		tier_counts[chosen_tier] += 1
			
	return composition
