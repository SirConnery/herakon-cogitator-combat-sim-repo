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
	
	# Configure rules based on the stage
	var weights := PackedFloat32Array()
	var tier_counts := [0, 0, 0, 0] # Tracks [T0, T1, T2, T3] generated so far
	
	match stage:
		Stage.EARLY:
			weights = PackedFloat32Array([0.65, 0.30, 0.05, 0.00])
		Stage.MID:
			weights = PackedFloat32Array([0.35, 0.40, 0.25, 0.00])
		Stage.LATE:
			weights = PackedFloat32Array([0.15, 0.25, 0.35, 0.25])

	# Loop to fill the requested unit count while respecting limits
	while composition.size() < unit_count:
		var chosen_tier := choose_weighted(weights)
		var allowed := true
		
		# Enforce stage constraints
		match stage:
			Stage.EARLY:
				if chosen_tier == 2 and tier_counts[2] >= 1: allowed = false # Max 1 Tier 2
			Stage.MID:
				if chosen_tier == 2 and tier_counts[2] >= 2: allowed = false # Max 2 Tier 2
			Stage.LATE:
				if chosen_tier == 0 and tier_counts[0] >= 2: allowed = false # Max 2 Tier 0
				if chosen_tier == 3 and tier_counts[3] >= 1: allowed = false # Max 1 Tier 3
		
		# If it passes constraints, lock it in
		if allowed:
			composition.append(chosen_tier)
			tier_counts[chosen_tier] += 1
			
	return composition
