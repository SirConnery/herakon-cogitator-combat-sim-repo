extends HBoxContainer
class_name FactionBarRow

@onready var faction_name_label: Label = $FactionName
@onready var win_rate_bar: ProgressBar = $WinRateBar
@onready var win_count_label: Label = $WinCountLabel

## Updates this specific row component with computed metric data passed from the dashboard view
func populate_bar(faction_name: String, rate: float, total_wins: int) -> void:
	if not is_inside_tree():
		await ready
		
	faction_name_label.text = faction_name
	win_rate_bar.value = rate
	
	# Formats the text cell nicely, e.g., "54.2% (542 Wins)"
	win_count_label.text = "(%d Wins)" % [total_wins]
