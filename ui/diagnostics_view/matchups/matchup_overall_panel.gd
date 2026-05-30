extends PanelContainer

@onready var faction_title: Label = %FactionTitle
@onready var matchup_row: HBoxContainer = %MatchupRow

func _ready() -> void:
	pass

func initialize_real_matchup_row(focus_faction_name: String, calculated_matchups_list: Array) -> void:
	faction_title.text = focus_faction_name
	
	# Clear out any old placeholder columns
	for child in matchup_row.get_children():
		child.queue_free()
	
	# Ensure layouts stretch out and fill areas properly
	var h_layout = get_node("HLayout")
	if h_layout:
		h_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	matchup_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	matchup_row.add_theme_constant_override("separation", 24)
		
	# Loop through the parsed metrics to draw the real skyscraper charts
	for data in calculated_matchups_list:
		var enemy_faction: String = data["enemy_name"]
		var real_ovr_rate: float = data["overall_rate"]
		var real_atk_rate: float = data["atk_rate"]
		var real_def_rate: float = data["def_rate"]
		
		# 🛠️ BUILD THE COLUMN NODES PURELY VIA CODE
		var col_container := VBoxContainer.new()
		
		col_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		# Forces a tight 2-pixel gap between the stacked text rows and the progress bars
		col_container.add_theme_constant_override("separation", 2)
		matchup_row.add_child(col_container)
		
		# Quick stats numeric readout label showing the real metrics
		var info_label := Label.new()
		info_label.text = "O:%d%%\nA:%d%%\nD:%d%%" % [round(real_ovr_rate), round(real_atk_rate), round(real_def_rate)]
		info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		info_label.add_theme_font_size_override("font_size", 10) # Made slightly smaller for better density
		col_container.add_child(info_label)
		
		# The horizontal cluster holding our trio of vertical bars side-by-side
		var bar_cluster := HBoxContainer.new()
		
		# 🎯 FIX 2: Ensure the bar cluster grabs all remaining vertical space at the bottom
		bar_cluster.size_flags_vertical = Control.SIZE_EXPAND_FILL
		bar_cluster.alignment = BoxContainer.ALIGNMENT_CENTER
		bar_cluster.add_theme_constant_override("separation", 3)
		col_container.add_child(bar_cluster)
		
		# Bar 1: Real Overall Win Rate
		var ovr_bar := ProgressBar.new()
		ovr_bar.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
		ovr_bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
		ovr_bar.custom_minimum_size = Vector2(14, 100) # Slightly shorter minimum base to prevent out-of-bounds pushes
		ovr_bar.show_percentage = false
		ovr_bar.value = real_ovr_rate
		bar_cluster.add_child(ovr_bar)
		
		# Bar 2: Real Attacking Win Rate
		var atk_bar := ProgressBar.new()
		atk_bar.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
		atk_bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
		atk_bar.custom_minimum_size = Vector2(14, 100) 
		atk_bar.show_percentage = false
		atk_bar.value = real_atk_rate
		bar_cluster.add_child(atk_bar)
		
		# Bar 3: Real Defending Win Rate
		var def_bar := ProgressBar.new()
		def_bar.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
		def_bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
		def_bar.custom_minimum_size = Vector2(14, 100)
		def_bar.show_percentage = false
		def_bar.value = real_def_rate
		bar_cluster.add_child(def_bar)
		
		# Enemy name label at the bottom
		var enemy_label := Label.new()
		enemy_label.text = enemy_faction
		enemy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col_container.add_child(enemy_label)
