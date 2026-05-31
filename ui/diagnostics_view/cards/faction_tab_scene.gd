extends TabContainer

const FACTION_BAR_V = preload("uid://bpwm0ac0xfcbw")
const MATCHUP_OVERALL_PANEL = preload("uid://cu1crqrtqyfop")

@onready var faction_card_overall_values: HBoxContainer = %FactionCardOverallValues
@onready var faction_card_attacker_values: HBoxContainer = %FactionCardAttackerValues
@onready var faction_card_defender_values: HBoxContainer = %FactionCardDefenderValues

@onready var faction_card_matchups_overall_values: VBoxContainer = %FactionCardMatchupsOverallValues
@onready var faction_card_matchups_attacker_values: VBoxContainer = %FactionCardMatchupsAttackerValues
@onready var faction_card_matchups_defender_values: VBoxContainer = %FactionCardMatchupsDefenderValues


## Accepts independent datasets to update all bar containers and matchup matrices simultaneously
func initialize_faction_card_rows(overall_data: Array[Dictionary], atk_data: Array[Dictionary], def_data: Array[Dictionary], matchup_data: Array[Dictionary]) -> void:
	_populate_container(faction_card_overall_values, overall_data)
	_populate_container(faction_card_attacker_values, atk_data)
	_populate_container(faction_card_defender_values, def_data)
	_populate_matchup_matrix(matchup_data)


## Reusable factory loop that flushes and rebuilds a targeted node cluster
func _populate_container(container: Control, sorted_card_data: Array[Dictionary]) -> void:
	if container == null:
		return
		
	# Clear out old visual nodes
	for child in container.get_children():
		child.queue_free()
		
	# Spawn and assign telemetry profiles
	for card in sorted_card_data:
		var bar_instance = FACTION_BAR_V.instantiate()
		container.add_child(bar_instance)
		bar_instance.populate_bar(card["name"], card["rate"], card["wins"])


## 🎯 UPDATED: Instantiates cross-faction matchup grids for Overall, Attacker, and Defender lanes
func _populate_matchup_matrix(matchup_data: Array[Dictionary]) -> void:
	var matrix_containers = [
		faction_card_matchups_overall_values,
		faction_card_matchups_attacker_values,
		faction_card_matchups_defender_values
	]
	
	# Flush previous generation rows across all target boxes safely
	for container in matrix_containers:
		if container != null:
			for child in container.get_children():
				child.queue_free()
				
	# Map each card profile to its respective matrix row feeds
	for card_profile in matchup_data:
		
		# 1. Populate Overall Card Matchups Row
		if faction_card_matchups_overall_values != null:
			var row_overall = MATCHUP_OVERALL_PANEL.instantiate()
			faction_card_matchups_overall_values.add_child(row_overall)
			row_overall.initialize_real_matchup_row(
				card_profile["card_name"],
				card_profile["matchups"],
				"overall_rate",
				"overall_wins"
			)
			
		# 2. Populate Attacker Card Matchups Row
		if faction_card_matchups_attacker_values != null:
			var row_atk = MATCHUP_OVERALL_PANEL.instantiate()
			faction_card_matchups_attacker_values.add_child(row_atk)
			row_atk.initialize_real_matchup_row(
				card_profile["card_name"],
				card_profile["matchups"],
				"atk_rate",
				"atk_wins"
			)
			
		# 3. Populate Defender Card Matchups Row
		if faction_card_matchups_defender_values != null:
			var row_def = MATCHUP_OVERALL_PANEL.instantiate()
			faction_card_matchups_defender_values.add_child(row_def)
			row_def.initialize_real_matchup_row(
				card_profile["card_name"],
				card_profile["matchups"],
				"def_rate",
				"def_wins"
			)
