class_name GameStageGenerator

enum Stage { EARLY, MID, LATE }

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

## Generates a randomized list of unit tiers based on game stage, target unit count, and theater type
static func generate_composition(stage: Stage, unit_count: int, is_ground_combat: bool = true) -> PackedInt32Array:
	var composition := PackedInt32Array()
	
	# Configure base weights based on the stage
	var base_weights := PackedFloat32Array()
	var tier_counts := [0, 0, 0, 0] # Tracks [T0, T1, T2, T3] generated so far
	
	match stage:
		Stage.EARLY:
			base_weights = PackedFloat32Array([0.65, 0.30, 0.05, 0.00])
		Stage.MID:
			base_weights = PackedFloat32Array([0.35, 0.40, 0.25, 0.00])
		Stage.LATE:
			base_weights = PackedFloat32Array([0.15, 0.25, 0.35, 0.25])

	# --- VOID THEATER WEIGHT REBALANCING ---
	# If this is a void battle, ships ONLY exist at Tier 0 and Tier 2.
	# We must zero out Tier 1 and Tier 3 entirely so the engine doesn't roll phantom units.
	if not is_ground_combat:
		base_weights[1] = 0.0
		base_weights[3] = 0.0
		
		# Re-weight the remaining legal tiers so the generator functions smoothly
		var remaining_sum = base_weights[0] + base_weights[2]
		if remaining_sum > 0.0:
			base_weights[0] = base_weights[0] / remaining_sum
			base_weights[2] = base_weights[2] / remaining_sum
		else:
			# Safety fallback: if a stage somehow had 0 weights for both T0 and T2
			base_weights[0] = 0.70
			base_weights[2] = 0.30

	# Loop to fill the requested unit count
	while composition.size() < unit_count:
		# Create a fresh copy of the weights for this specific pass
		var active_weights := base_weights.duplicate()
		
		# --- DYNAMIC WEIGHT MUTATION ---
		# Forcefully zero out weights for tiers that have breached their stage caps.
		match stage:
			Stage.EARLY:
				if tier_counts[2] >= 1: active_weights[2] = 0.0 # Max 1 Tier 2
			Stage.MID:
				if tier_counts[2] >= 2: active_weights[2] = 0.0 # Max 2 Tier 2
			Stage.LATE:
				if tier_counts[0] >= 2: active_weights[0] = 0.0 # Max 2 Tier 0
				# (Tier 3 is already forced to 0.0 in void combat above)
				if is_ground_combat and tier_counts[3] >= 1: active_weights[3] = 0.0 

		# --- EMERGENCY ESCAPE HATCH ---
		var total_weight_pool := 0.0
		for w in active_weights:
			total_weight_pool += w
			
		if total_weight_pool <= 0.0:
			# If we are in void combat, hitting a hard cap is much easier because we only have 2 tiers.
			# Instead of warning/breaking empty handed, we fallback to giving them standard Tier 0 ships
			# to fill the requested army size requirement.
			if not is_ground_combat:
				composition.append(0)
				tier_counts[0] += 1
				continue
				
			push_warning("GameStageGenerator: Generation halted. All available unit tiers for stage %s have hit hard constraints at %d units." % [Stage.keys()[stage], composition.size()])
			break

		# Roll using our safe, mutated weight array
		var chosen_tier := choose_weighted(active_weights)
		
		# Lock it in
		composition.append(chosen_tier)
		tier_counts[chosen_tier] += 1
			
	return composition
