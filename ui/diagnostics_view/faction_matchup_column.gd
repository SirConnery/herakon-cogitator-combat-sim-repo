extends VBoxContainer
class_name FactionMatchupColumn

@onready var faction_name_label: Label = $FactionName
@onready var info_label: Label = $InfoLabel
@onready var atk_bar: ProgressBar = $BarCluster/AtkBar
@onready var def_bar: ProgressBar = $BarCluster/DefBar

## Updates this vertical column slot with twin posturing metrics
func populate_column(enemy_name: String, atk_rate: float, def_rate: float, total_matches: int) -> void:
	if not is_inside_tree():
		await ready
		
	faction_name_label.text = enemy_name
	
	# Set the bar heights
	atk_bar.value = atk_rate
	def_bar.value = def_rate
	
	# Display quick glance text context at the top of the column
	# e.g., "A:54% / D:42%"
	info_label.text = "A:%d%%\nD:%d%%" % [round(atk_rate), round(def_rate)]
