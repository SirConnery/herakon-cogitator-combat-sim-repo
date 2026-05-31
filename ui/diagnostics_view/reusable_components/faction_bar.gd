## Inside FactionBar.gd
extends Container
class_name FactionBar

var faction_name: Label
var win_rate_bar: ProgressBar
var win_count_label: Label

func populate_bar(faction_name_label: String, rate: float, total_wins: int) -> void:
	faction_name.text = faction_name_label
	win_count_label.text = "(%d Wins)" % total_wins
	
	win_rate_bar.value = rate
	
	# 🎨 THEME VARIATION LOGIC
	if rate < 40.0:
		win_rate_bar.theme_type_variation = "ProgressBarKhorneRed"
	elif rate < 60.0:
		win_rate_bar.theme_type_variation = "ProgressBarMacraggeBlue"
	else:
		win_rate_bar.theme_type_variation = "ProgressBarCalibanGreen"
