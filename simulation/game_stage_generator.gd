extends RefCounted
class_name GameStageGenerator

enum Stage { EARLY, MID, LATE }

# --- SHORTCUT ALIASES FOR ENUMS ---
const STARTER = CardData.CardTier.STARTER
const TIER_0  = CardData.CardTier.TIER_0
const TIER_2  = CardData.CardTier.TIER_2
const TIER_3  = CardData.CardTier.TIER_3

# =========================================================================
# --- CONFIGURABLE BALANCING TUNERS ---
# =========================================================================

# --- UNIT SELECTION PROBABILITIES (TIER 0, TIER 1, TIER 2, TIER 3) ---
static var early_unit_weights := PackedFloat32Array([0.65, 0.30, 0.05, 0.00])
static var mid_unit_weights   := PackedFloat32Array([0.35, 0.40, 0.25, 0.00])
static var late_unit_weights  := PackedFloat32Array([0.15, 0.25, 0.35, 0.25])

# --- CARD UPGRADE TOTAL COUNT PROBABILITIES ---
# Index maps directly to total card counts: [1 Card, 2 Cards, 3 Cards, 4 Cards, 5 Cards]
static var early_card_upgrade_count_weights := PackedFloat32Array([0.30, 0.50, 0.20, 0.00, 0.00]) # 1 to 3 cards
static var mid_card_upgrade_count_weights   := PackedFloat32Array([0.00, 0.00, 0.50, 0.50, 0.00]) # 3 to 4 cards
static var late_card_upgrade_count_weights  := PackedFloat32Array([0.00, 0.00, 0.00, 0.80, 0.20]) # 4 to 5 cards

# --- CARD UPGRADE TIER SELECTION PROBABILITIES ---
# Index maps directly to upgrade card pools: [Index 0 = Tier 0 Pool, Index 1 = Tier 2 Pool, Index 2 = Tier 3 Pool]
static var early_card_tier_weights := PackedFloat32Array([1.00, 0.00, 0.00]) # 100% Tier 0 upgrades
static var mid_card_tier_weights   := PackedFloat32Array([0.5714, 0.4286, 0.00]) # Matches 2x T0 + 1.5x T2 average
static var late_card_tier_weights  := PackedFloat32Array([0.2381, 0.4762, 0.2857]) # Matches 1x T0 + 2x T2 + 1.2x T3 average

# --- MASTER ENGINE DEBUG OVERRIDES ---
static var use_debug_deck_for_testing := false
static var debug_deck_uses_1_card := true

# =========================================================================


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
		max_counts_by_tier[unit_data["tier"]] = unit_data.get("unit_count", 99)

	# 2. Generate the randomized composition tiers matching stage weights AND database limits
	var randomized_tiers := generate_composition(stage, unit_count, is_ground_combat, max_counts_by_tier)
	
	# 3. Compile standalone single-figure instances safely using deep duplication
	var selected_units_blueprints: Array = []
	for tier in randomized_tiers:
		if registry_units_by_tier.has(tier):
			selected_units_blueprints.append(registry_units_by_tier[tier].duplicate(true))
		elif is_ground_combat:
			push_error("Faction %d lacks ground units for Tier %d!" % [faction_id, tier])

	# 4. Compile the structural combat deck using our pair-replacement upgrade logic
	var compiled_deck := compile_combat_deck(faction_raw, stage)

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


## Compiles the combat deck by mutating starter pairs from the database with rolled upgrade choices
static func compile_combat_deck(faction_raw: Dictionary, stage: Stage) -> Array:
	# --- HANDLE MASTER TESTING DEBUG OVERRIDES ---
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
	
	# --- INITIALIZE DIRECTLY FROM DATABASE REGISTRY CONTRACT ---
	var compiled_deck: Array = faction_raw.get("starting_combat_deck", []).duplicate()
	
	if compiled_deck.is_empty():
		push_error("Faction configuration missing 'starting_combat_deck'. Falling back to default deck pool.")
		compiled_deck = faction_raw.get("combat_deck", []).duplicate()
		if compiled_deck.is_empty():
			return []
		
	var valid_starter_cards := compiled_deck.duplicate()
	
	# --- SORT AVAILABLE SELECTION CARDS INTO TIER BUCKETS ---
	var upgrade_pool: Array = faction_raw.get("upgrade_deck", [])
	var local_fallback: Array = upgrade_pool.duplicate() # Duplicate for unique fallback popping safety
	var tier_0_pool: Array[int] = []
	var tier_2_pool: Array[int] = []
	var tier_3_pool: Array[int] = []
	
	var card_db: Dictionary = CardRegistry.get_database()
	for card_id in upgrade_pool:
		var card_profile = card_db.get(card_id)
		if card_profile == null:
			continue
			
		var card_tier = card_profile.get("card_tier")
		
		match card_tier:
			TIER_0:
				tier_0_pool.append(card_id)
			TIER_2:
				tier_2_pool.append(card_id)
			TIER_3:
				tier_3_pool.append(card_id)

	# --- RESOLVE TOTAL UPGRADE COUNT AND TIERS DYNAMICALLY VIA MATRIX ---
	var total_upgrades := 0
	var tier_weights := PackedFloat32Array()
	
	match stage:
		Stage.EARLY:
			total_upgrades = choose_weighted(early_card_upgrade_count_weights) + 1
			tier_weights = early_card_tier_weights
		Stage.MID:
			total_upgrades = choose_weighted(mid_card_upgrade_count_weights) + 1
			tier_weights = mid_card_tier_weights
		Stage.LATE:
			total_upgrades = choose_weighted(late_card_upgrade_count_weights) + 1
			tier_weights = late_card_tier_weights

	var upgrade_work_queue: Array[int] = []
	
	# Process each rolled card slot individually against the active tier weights
	for c in range(total_upgrades):
		var rolled_tier_idx := choose_weighted(tier_weights)
		var chosen_id := -1
		
		match rolled_tier_idx:
			0: chosen_id = _pop_random_from_pool(tier_0_pool)
			1: chosen_id = _pop_random_from_pool(tier_2_pool)
			2: chosen_id = _pop_random_from_pool(tier_3_pool)
			
		if chosen_id == -1:
			chosen_id = _pop_random_from_pool(local_fallback)
			
		if chosen_id != -1:
			upgrade_work_queue.append(chosen_id)
			tier_0_pool.erase(chosen_id)
			tier_2_pool.erase(chosen_id)
			tier_3_pool.erase(chosen_id)
			local_fallback.erase(chosen_id)

	# --- EXECUTE PAIR SWAP EXTRACTION MUTATION LOOPS ---
	for upgrade_id in upgrade_work_queue:
		var target_pair_id := -1
		
		for card_id in compiled_deck:
			if valid_starter_cards.has(card_id) and compiled_deck.count(card_id) >= 2:
				target_pair_id = card_id
				break
				
		if target_pair_id != -1:
			compiled_deck.erase(target_pair_id)
			compiled_deck.erase(target_pair_id)
			
			valid_starter_cards.erase(target_pair_id)
			valid_starter_cards.erase(target_pair_id)
			
			compiled_deck.append(upgrade_id)
			compiled_deck.append(upgrade_id)
		else:
			compiled_deck.append(upgrade_id)
			compiled_deck.append(upgrade_id)

	return compiled_deck


## Pops an item entirely out of pool memory array references to ensure unique draws without replacement
static func _pop_random_from_pool(source_pool: Array) -> int:
	if source_pool.is_empty():
		return -1
	var random_idx := randi() % source_pool.size()
	return source_pool.pop_at(random_idx)


## Generates a randomized list of unit tiers based on game stage, target unit count, and database pool limits
static func generate_composition(stage: Stage, unit_count: int, is_ground_combat: bool, max_counts_by_tier: Dictionary) -> PackedInt32Array:
	var composition := PackedInt32Array()
	var base_weights := PackedFloat32Array()
	var tier_counts := [0, 0, 0, 0]
	
	match stage:
		Stage.EARLY:
			base_weights = early_unit_weights.duplicate()
		Stage.MID:
			base_weights = mid_unit_weights.duplicate()
		Stage.LATE:
			base_weights = late_unit_weights.duplicate()

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
		for tier in range(active_weights.size()):
			if max_counts_by_tier.has(tier):
				if tier_counts[tier] >= max_counts_by_tier[tier]:
					active_weights[tier] = 0.0

		# --- EMERGENCY ESCAPE HATCH ---
		var total_weight_pool := 0.0
		for w in active_weights:
			total_weight_pool += w
			
		if total_weight_pool <= 0.0:
			push_warning("GameStageGenerator: Generation stopped. Pools are exhausted at %d units." % composition.size())
			break

		var chosen_tier := choose_weighted(active_weights)
		
		composition.append(chosen_tier)
		tier_counts[chosen_tier] += 1
			
	return composition
