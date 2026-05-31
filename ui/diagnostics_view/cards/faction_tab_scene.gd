extends TabContainer

const FACTION_BAR_V = preload("uid://bpwm0ac0xfcbw")

@onready var faction_card_overall_values: HBoxContainer = %FactionCardOverallValues

## Dynamically populates this specific tab sheet with horizontal scoreboard bar metrics
func initialize_faction_card_rows(sorted_card_data: Array[Dictionary], bar_scene: PackedScene) -> void:
	if faction_card_overall_values == null:
		return
		
	# Clear out any editor placeholder/sample nodes cleanly
	for child in faction_card_overall_values.get_children():
		child.queue_free()
		
	# Spawn a specialized performance bar row for every card in the compiled dataset
	for card in sorted_card_data:
		var bar_instance = FACTION_BAR_V.instantiate()
		faction_card_overall_values.add_child(bar_instance)
		
		# Reuse your horizontal scorebar node formatting method to draw name, win rate %, and total wins
		bar_instance.populate_bar(card["name"], card["rate"], card["wins"])
