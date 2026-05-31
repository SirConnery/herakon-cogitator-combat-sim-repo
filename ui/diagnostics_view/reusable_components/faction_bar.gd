extends Container
class_name FactionBar

var faction_name: Label
var win_rate_bar: ProgressBar
var win_count_label: Label

var clamp_value_x := 20.0
var clamp_value_y := 80.0

func populate_bar(faction_name_label: String, rate: float, total_wins: int) -> void:
	faction_name.text = faction_name_label
	win_count_label.text = "(%d Wins)" % total_wins
	
	#Zoom the bar's axis limits to focus on the competitive baseline
	# This forces a 40% vs 60% win rate to look bigger on screen.
	win_rate_bar.min_value = 20.0
	win_rate_bar.max_value = 75.0
	
	# Clamp the incoming percentage to prevent the bar filling out of bounds
	win_rate_bar.value = clamp(rate, clamp_value_x, clamp_value_y)
