extends TabContainer

const FACTION_BAR_V = preload("uid://bpwm0ac0xfcbw")
const MATCHUP_OVERALL_PANEL = preload("uid://cu1crqrtqyfop")

@onready var faction_card_overall_values: HBoxContainer = %FactionCardOverallValues
@onready var faction_card_attacker_values: HBoxContainer = %FactionCardAttackerValues
@onready var faction_card_defender_values: HBoxContainer = %FactionCardDefenderValues

@onready var faction_card_matchups_overall_values: VBoxContainer = %FactionCardMatchupsOverallValues


## Accepts three independent datasets to update all data lanes simultaneously
func initialize_faction_card_rows(overall_data: Array[Dictionary], atk_data: Array[Dictionary], def_data: Array[Dictionary]) -> void:
	_populate_container(faction_card_overall_values, overall_data)
	_populate_container(faction_card_attacker_values, atk_data)
	_populate_container(faction_card_defender_values, def_data)


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
