class_name GameStageGenerator

enum Stage { EARLY, MID, LATE }

# Simple weighted random choice helper
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

## Generates a randomized list of unit tiers based on game stage and target unit count
static func generate_composition(stage: Stage, unit_count: int) -> PackedInt32Array:
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

	# Loop to fill the requested unit count
	while composition.size() < unit_count:
		# Create a fresh copy of the weights for this specific pass
		var active_weights := base_weights.duplicate()
		
		# --- DYNAMIC WEIGHT MUTATION ---
		# Forcefully zero out weights for tiers that have breached their stage caps.
		# This guarantees choose_weighted() can only select a legal tier.
		match stage:
			Stage.EARLY:
				if tier_counts[2] >= 1: active_weights[2] = 0.0 # Max 1 Tier 2
			Stage.MID:
				if tier_counts[2] >= 2: active_weights[2] = 0.0 # Max 2 Tier 2
			Stage.LATE:
				if tier_counts[0] >= 2: active_weights[0] = 0.0 # Max 2 Tier 0
				if tier_counts[3] >= 1: active_weights[3] = 0.0 # Max 1 Tier 3

		# --- EMERGENCY ESCAPE HATCH ---
		# If the requested unit_count is so high that ALL available tiers are capped out,
		# break immediately to prevent a crash, allowing the loop to return what it built.
		var total_weight_pool := 0.0
		for w in active_weights:
			total_weight_pool += w
			
		if total_weight_pool <= 0.0:
			push_warning("GameStageGenerator: Generation halted. All available unit tiers for stage %s have hit hard constraints at %d units." % [Stage.keys()[stage], composition.size()])
			break

		# Roll using our safe, mutated weight array
		var chosen_tier := choose_weighted(active_weights)
		
		# Lock it in
		composition.append(chosen_tier)
		tier_counts[chosen_tier] += 1
			
	return composition
