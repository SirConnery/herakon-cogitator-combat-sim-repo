extends Control
class_name DiagnosticsView

# --- SCENE REFERENCES ---
const FACTION_BAR_SCENE := preload("uid://lxbnnqywg5un")
const MATCHUP_OVERALL_PANEL_SCENE = preload("uid://cu1crqrtqyfop")

# --- UI ELEMENT NODES (Scene Unique Names) ---
@export_group("Global Win Rates")
@onready var overall_faction_winrates: VBoxContainer = %OverallWinrates
@onready var attacker_win_rates: VBoxContainer = %AttackerWinRates
@onready var defender_win_rates: VBoxContainer = %DefenderWinRates

@export_group("Early Stage Win Rates")
@onready var overall_early_stage_win_rates: VBoxContainer = %OverallEarlyStageWinRates
@onready var attacker_early_stage_win_rates: VBoxContainer = %AttackerEarlyStageWinRates
@onready var defender_early_stage_win_rates: VBoxContainer = %DefenderEarlyStageWinRates

@export_group("Middle Stage Win Rates")
@onready var overall_middle_stage_win_rates: VBoxContainer = %OverallMiddleStageWinRates
@onready var attacker_middle_stage_win_rates: VBoxContainer = %AttackerMiddleStageWinRates
@onready var defender_middle_stage_win_rates: VBoxContainer = %DefenderMiddleStageWinRates

@export_group("Late Stage Win Rates")
@onready var overall_late_stage_win_rates: VBoxContainer = %OverallLateStageWinRates
@onready var attacker_late_stage_win_rates: VBoxContainer = %AttackerLateStageWinRates
@onready var defender_late_stage_win_rates: VBoxContainer = %DefenderLateStageWinRates

# -- MATCHUP NODES ---
@onready var matchups_overall_values: VBoxContainer = %MatchupsOverallValues

# --- CONTROLLER REFS ---
@onready var ui: UI = owner
var sim_controller: SimController


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible:
		populate_diagnostics_dashboard()


func populate_diagnostics_dashboard() -> void:
	if ui == null or ui.sim_controller == null:
		return
		
	sim_controller = ui.sim_controller
	
	# 💡 UPDATED: Points to our dedicated ground dataset by default (or update as needed)
	var binary_path := "user://simulation_ground_data.dat"
	
	# 1. PURGE ALL 13 CONTAINERS CLEANLY
	var all_containers: Array[VBoxContainer] = [
		overall_faction_winrates, attacker_win_rates, defender_win_rates,
		overall_early_stage_win_rates, attacker_early_stage_win_rates, defender_early_stage_win_rates,
		overall_middle_stage_win_rates, attacker_middle_stage_win_rates, defender_middle_stage_win_rates,
		overall_late_stage_win_rates, attacker_late_stage_win_rates, defender_late_stage_win_rates,
		matchups_overall_values # Purge old matchup skyscrapers
	]
	for container in all_containers:
		UI_Utils.clear_children(container)
		
	if not FileAccess.file_exists(binary_path):
		return

	# 2. INITIALIZE TRACKING DATA STRUCTURE FOR LEADBOARDS
	var matrix_cache := {}
	for stage_idx in [-1, 0, 1, 2]:
		matrix_cache[stage_idx] = {}
		for f_id in sim_controller.factions_to_sim:
			matrix_cache[stage_idx][f_id] = {
				"atk_wins": 0, "atk_games": 0,
				"def_wins": 0, "def_games": 0
			}

	# 🎯 NEW: Initialize 2D Cross-Faction Data Structure for Matchups Matrix
	var head_to_head_matrix := {}
	for f_id in sim_controller.factions_to_sim:
		head_to_head_matrix[f_id] = {}
		for enemy_id in sim_controller.factions_to_sim:
			if f_id != enemy_id:
				head_to_head_matrix[f_id][enemy_id] = {
					"atk_wins": 0, "atk_games": 0,
					"def_wins": 0, "def_games": 0
				}

	# 3. HIGH-SPEED SINGLE PASS BINARY STREAM PARSER
	var file = FileAccess.open(binary_path, FileAccess.READ)
	while file.get_position() < file.get_length():
		var data = file.get_var()
		if data is Array and data.size() >= 5:
			var stage_id: int = data[1]
			var atk_id: int = data[2]
			var def_id: int = data[3]
			var atk_won: bool = bool(data[4])
			
			# Filter and record metrics if the factions are part of the active tracking pool
			if matrix_cache[-1].has(atk_id) and matrix_cache[-1].has(def_id):
				# Append to Global Data Pool (-1)
				matrix_cache[-1][atk_id]["atk_games"] += 1
				matrix_cache[-1][def_id]["def_games"] += 1
				if atk_won:
					matrix_cache[-1][atk_id]["atk_wins"] += 1
				else:
					matrix_cache[-1][def_id]["def_wins"] += 1
				
				# 🎯 NEW: Populate cross-faction interaction matrix profiles
				head_to_head_matrix[atk_id][def_id]["atk_games"] += 1
				head_to_head_matrix[def_id][atk_id]["def_games"] += 1
				if atk_won:
					head_to_head_matrix[atk_id][def_id]["atk_wins"] += 1
				else:
					head_to_head_matrix[def_id][atk_id]["def_wins"] += 1
				
				# Append to Specific Stage Data Pool (0, 1, or 2)
				if matrix_cache.has(stage_id):
					matrix_cache[stage_id][atk_id]["atk_games"] += 1
					matrix_cache[stage_id][def_id]["def_games"] += 1
					if atk_won:
						matrix_cache[stage_id][atk_id]["atk_wins"] += 1
					else:
						matrix_cache[stage_id][def_id]["def_wins"] += 1
	file.close()

	# 4. RESOLVE IDENTITY NAMING STRINGS
	var raw_factions: Dictionary = FactionRegistry.get_database()

	# 5. PROCESS, SORT, AND FILL ALL 4 DASHBOARD GROUPS
	_process_and_render_group(matrix_cache[-1], overall_faction_winrates, attacker_win_rates, defender_win_rates, raw_factions)
	_process_and_render_group(matrix_cache[0], overall_early_stage_win_rates, attacker_early_stage_win_rates, defender_early_stage_win_rates, raw_factions)
	_process_and_render_group(matrix_cache[1], overall_middle_stage_win_rates, attacker_middle_stage_win_rates, defender_middle_stage_win_rates, raw_factions)
	_process_and_render_group(matrix_cache[2], overall_late_stage_win_rates, attacker_late_stage_win_rates, defender_late_stage_win_rates, raw_factions)

	# 🎯 NEW: Process and deploy the custom interactive matchup matrix feed
	_render_matchup_skyline_feed(head_to_head_matrix, raw_factions)


## De-duplicated crunching and rendering pipeline engine
func _process_and_render_group(stage_data: Dictionary, overall_box: VBoxContainer, atk_box: VBoxContainer, def_box: VBoxContainer, raw_factions: Dictionary) -> void:
	var overall_list: Array[Dictionary] = []
	var attack_list: Array[Dictionary] = []
	var defense_list: Array[Dictionary] = []
	
	for f_id in stage_data:
		var stats: Dictionary = stage_data[f_id]
		var faction_profile = raw_factions.get(f_id)
		var name_string: String = faction_profile.get("name", FactionRegistry.FactionID.keys()[f_id])
		
		# Crunch Combined Metrics
		var total_wins: int = stats["atk_wins"] + stats["def_wins"]
		var total_games: int = stats["atk_games"] + stats["def_games"]
		var overall_rate := 0.0
		if total_games > 0:
			overall_rate = (float(total_wins) / float(total_games)) * 100.0
		overall_list.append({"name": name_string, "rate": overall_rate, "wins": total_wins})
		
		# Crunch Attacker Metrics
		var atk_rate := 0.0
		if stats["atk_games"] > 0:
			atk_rate = (float(stats["atk_wins"]) / float(stats["atk_games"])) * 100.0
		attack_list.append({"name": name_string, "rate": atk_rate, "wins": stats["atk_wins"]})
		
		# Crunch Defender Metrics
		var def_rate := 0.0
		if stats["def_games"] > 0:
			def_rate = (float(stats["def_wins"]) / float(stats["def_games"])) * 100.0
		defense_list.append({"name": name_string, "rate": def_rate, "wins": stats["def_wins"]})
		
	# Sort leaderboard segments independently by win margins
	overall_list.sort_custom(func(a, b): return a["rate"] > b["rate"])
	attack_list.sort_custom(func(a, b): return a["rate"] > b["rate"])
	defense_list.sort_custom(func(a, b): return a["rate"] > b["rate"])
	
	# Instantiate visual bars down target layouts
	_spawn_leaderboard_bars(overall_list, overall_box)
	_spawn_leaderboard_bars(attack_list, atk_box)
	_spawn_leaderboard_bars(defense_list, def_box)


## Helper utility instantiation wrapper loop
func _spawn_leaderboard_bars(sorted_data: Array[Dictionary], target_container: VBoxContainer) -> void:
	for faction in sorted_data:
		var bar_instance = FACTION_BAR_SCENE.instantiate()
		target_container.add_child(bar_instance)
		bar_instance.populate_bar(faction["name"], faction["rate"], faction["wins"])


func _render_matchup_skyline_feed(head_to_head_matrix: Dictionary, raw_factions: Dictionary) -> void:
	for focus_id in sim_controller.factions_to_sim:
		var focus_profile = raw_factions.get(focus_id)
		var focus_name: String = focus_profile.get("name", FactionRegistry.FactionID.keys()[focus_id])
		
		# Instantiate a master horizontal row panel
		var row_instance = MATCHUP_OVERALL_PANEL_SCENE.instantiate()
		matchups_overall_values.add_child(row_instance)
		
		# Build a calculated list tracking how this specific faction handles every opponent
		var compiled_matchups_list: Array[Dictionary] = []
		
		for enemy_id in sim_controller.factions_to_sim:
			if focus_id == enemy_id:
				continue # Handled dynamically inside the row layout loop
				
			var enemy_profile = raw_factions.get(enemy_id)
			var enemy_name: String = enemy_profile.get("name", FactionRegistry.FactionID.keys()[enemy_id])
			
			var stats: Dictionary = head_to_head_matrix[focus_id][enemy_id]
			
			# Extract percentages from raw values, guarding against division by zero
			var atk_rate := 0.0
			if stats["atk_games"] > 0:
				atk_rate = (float(stats["atk_wins"]) / float(stats["atk_games"])) * 100.0
				
			var def_rate := 0.0
			if stats["def_games"] > 0:
				def_rate = (float(stats["def_wins"]) / float(stats["def_games"])) * 100.0
				
			var overall_rate := 0.0
			var total_games: int = stats["atk_games"] + stats["def_games"]
			if total_games > 0:
				overall_rate = (float(stats["atk_wins"] + stats["def_wins"]) / float(total_games)) * 100.0
				
			compiled_matchups_list.append({
				"enemy_name": enemy_name,
				"overall_rate": overall_rate,
				"atk_rate": atk_rate,
				"def_rate": def_rate
			})
			
		# Feed the verified data array straight into the row panel node
		row_instance.initialize_real_matchup_row(focus_name, compiled_matchups_list)
