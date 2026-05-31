extends Control
class_name DiagnosticsView

# --- SCENE REFERENCES ---
const FACTION_BAR_SCENE_H := preload("uid://lxbnnqywg5un")
const FACTION_BAR_SCENE_V := preload("uid://bpwm0ac0xfcbw")
const MATCHUP_OVERALL_PANEL_SCENE = preload("uid://cu1crqrtqyfop")
const FACTION_TAB_SCENE = preload("uid://n4uue0fn6735")

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
@export_group("Matchup Matrix Containers")
@onready var matchups_overall_values: VBoxContainer = %MatchupsOverallValues
@onready var matchups_overall_attacker_values: VBoxContainer = %MatchupsOverallAttackerValues
@onready var matchups_overall_defender_values: VBoxContainer = %MatchupsOverallDefenderValues

@onready var matchups_early_stage_overall_values: VBoxContainer = %MatchupsEarlyStageOverallValues
@onready var matchups_middle_stage_overall_values: VBoxContainer = %MatchupsMiddleStageOverallValues
@onready var matchups_late_stage_overall_values: VBoxContainer = %MatchupsLateStageOverallValues

@onready var matchups_early_stage_attacker_values: VBoxContainer = %MatchupsEarlyStageAttackerValues
@onready var matchups_middle_stage_attacker_values: VBoxContainer = %MatchupsMiddleStageAttackerValues
@onready var matchups_late_stage_attacker_values: VBoxContainer = %MatchupsLateStageAttackerValues

@onready var matchups_early_stage_defender_values: VBoxContainer = %MatchupsEarlyStageDefenderValues
@onready var matchups_middle_stage_defender_values: VBoxContainer = %MatchupsMiddleStageDefenderValues
@onready var matchups_late_stage_defender_values: VBoxContainer = %MatchupsLateStageDefenderValues

# -- CARD NODES ---
@export_group("Card Performance Containers")
@onready var cards_all_factions_overall_values: VBoxContainer = %CardsAllFactionsOverallValues
@onready var cards_add_factions_tab: TabContainer = %CardsAddFactionsTab


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
	var binary_path := "user://simulation_ground_data.dat"
	
	# 🎯 REGISTERED: Added cards_add_factions_tab to automated cleanup wipe loop
	var all_containers: Array[Control] = [
		overall_faction_winrates, attacker_win_rates, defender_win_rates,
		overall_early_stage_win_rates, attacker_early_stage_win_rates, defender_early_stage_win_rates,
		overall_middle_stage_win_rates, attacker_middle_stage_win_rates, defender_middle_stage_win_rates,
		overall_late_stage_win_rates, attacker_late_stage_win_rates, defender_late_stage_win_rates,
		matchups_overall_values, matchups_overall_attacker_values, matchups_overall_defender_values,
		matchups_early_stage_overall_values, matchups_middle_stage_overall_values, matchups_late_stage_overall_values,
		matchups_early_stage_attacker_values, matchups_middle_stage_attacker_values, matchups_late_stage_attacker_values,
		matchups_early_stage_defender_values, matchups_middle_stage_defender_values, matchups_late_stage_defender_values,
		cards_all_factions_overall_values, cards_add_factions_tab
	]
	for container in all_containers:
		if container != null:
			UI_Utils.clear_children(container)
		
	if not FileAccess.file_exists(binary_path):
		return

	# 2. INITIALIZE TRACKING DATA STRUCTURE FOR LEADERBOARDS
	var matrix_cache := {}
	for stage_idx in [-1, 0, 1, 2]:
		matrix_cache[stage_idx] = {}
		for f_id in sim_controller.factions_to_sim:
			matrix_cache[stage_idx][f_id] = {
				"atk_wins": 0, "atk_games": 0,
				"def_wins": 0, "def_games": 0
			}

	# Multi-Stage Cross-Faction Matchup Tracking Matrix Initialization
	var head_to_head_matrix := {}
	for stage_idx in [-1, 0, 1, 2]:
		head_to_head_matrix[stage_idx] = {}
		for f_id in sim_controller.factions_to_sim:
			head_to_head_matrix[stage_idx][f_id] = {}
			for enemy_id in sim_controller.factions_to_sim:
				if f_id != enemy_id:
					head_to_head_matrix[stage_idx][f_id][enemy_id] = {
						"atk_wins": 0, "atk_games": 0,
						"def_wins": 0, "def_games": 0
					}

	# 🎯 UPDATED: Map cache to handle both Global Overall [-1] and individual faction keys
	var card_stats_cache := {} 
	card_stats_cache[-1] = {}
	for f_id in sim_controller.factions_to_sim:
		card_stats_cache[f_id] = {}

	# 3. HIGH-SPEED SINGLE PASS BINARY STREAM PARSER
	var file = FileAccess.open(binary_path, FileAccess.READ)
	while file.get_position() < file.get_length():
		var data = file.get_var()
		if data is Array and data.size() >= 7:
			var stage_id: int = data[1]
			var atk_id: int = data[2]
			var def_id: int = data[3]
			var atk_won: bool = bool(data[4])
			var atk_deck: Array = data[5]
			var def_deck: Array = data[6]
			
			if matrix_cache[-1].has(atk_id) and matrix_cache[-1].has(def_id):
				# Leaderboard global updates
				matrix_cache[-1][atk_id]["atk_games"] += 1
				matrix_cache[-1][def_id]["def_games"] += 1
				if atk_won:
					matrix_cache[-1][atk_id]["atk_wins"] += 1
				else:
					matrix_cache[-1][def_id]["def_wins"] += 1
				
				# Matchups Global Matrix (-1) updates
				head_to_head_matrix[-1][atk_id][def_id]["atk_games"] += 1
				head_to_head_matrix[-1][def_id][atk_id]["def_games"] += 1
				if atk_won:
					head_to_head_matrix[-1][atk_id][def_id]["atk_wins"] += 1
				else:
					head_to_head_matrix[-1][def_id][atk_id]["def_wins"] += 1
				
				# Stage-specific calculations
				if matrix_cache.has(stage_id):
					matrix_cache[stage_id][atk_id]["atk_games"] += 1
					matrix_cache[stage_id][def_id]["def_games"] += 1
					if atk_won:
						matrix_cache[stage_id][atk_id]["atk_wins"] += 1
					else:
						matrix_cache[stage_id][def_id]["def_wins"] += 1
						
					# Matchups Stage-Specific Matrix updates
					head_to_head_matrix[stage_id][atk_id][def_id]["atk_games"] += 1
					head_to_head_matrix[stage_id][def_id][atk_id]["def_games"] += 1
					if atk_won:
						head_to_head_matrix[stage_id][atk_id][def_id]["atk_wins"] += 1
					else:
						head_to_head_matrix[stage_id][def_id][atk_id]["def_wins"] += 1
						
			# HIGH-SPEED IN-LINE DEDUPLICATION AND AGGREGATION METRIC LOOPS
			var unique_atk_cards := {}
			var unique_def_cards := {}
			for card_id in atk_deck: unique_atk_cards[int(card_id)] = true
			for card_id in def_deck: unique_def_cards[int(card_id)] = true
			
			# Tabulate Attacker Deck Card performance values (Global + Faction)
			for card_id in unique_atk_cards:
				if not card_stats_cache[-1].has(card_id): card_stats_cache[-1][card_id] = {"wins": 0, "games": 0}
				if not card_stats_cache[atk_id].has(card_id): card_stats_cache[atk_id][card_id] = {"wins": 0, "games": 0}
				
				card_stats_cache[-1][card_id]["games"] += 1
				card_stats_cache[atk_id][card_id]["games"] += 1
				if atk_won:
					card_stats_cache[-1][card_id]["wins"] += 1
					card_stats_cache[atk_id][card_id]["wins"] += 1
					
			# Tabulate Defender Deck Card performance values (Global + Faction)
			for card_id in unique_def_cards:
				if not card_stats_cache[-1].has(card_id): card_stats_cache[-1][card_id] = {"wins": 0, "games": 0}
				if not card_stats_cache[def_id].has(card_id): card_stats_cache[def_id][card_id] = {"wins": 0, "games": 0}
				
				card_stats_cache[-1][card_id]["games"] += 1
				card_stats_cache[def_id][card_id]["games"] += 1
				if not atk_won:
					card_stats_cache[-1][card_id]["wins"] += 1
					card_stats_cache[def_id][card_id]["wins"] += 1
	file.close()

	# 4. RESOLVE IDENTITY NAMING STRINGS
	var raw_factions: Dictionary = FactionRegistry.get_database()
	var raw_cards: Dictionary = CardRegistry.get_database()

	# 5. PROCESS, SORT, AND FILL ALL 4 DASHBOARD GROUPS
	_process_and_render_group(matrix_cache[-1], overall_faction_winrates, attacker_win_rates, defender_win_rates, raw_factions)
	_process_and_render_group(matrix_cache[0], overall_early_stage_win_rates, attacker_early_stage_win_rates, defender_early_stage_win_rates, raw_factions)
	_process_and_render_group(matrix_cache[1], overall_middle_stage_win_rates, attacker_middle_stage_win_rates, defender_middle_stage_win_rates, raw_factions)
	_process_and_render_group(matrix_cache[2], overall_late_stage_win_rates, attacker_late_stage_win_rates, defender_late_stage_win_rates, raw_factions)

	# DEPLOY TARGETED MATCHUP FEEDS TO ALL STAGE SUBSYSTEMS
	_render_matchup_stage_group(head_to_head_matrix[-1], matchups_overall_values, "overall_rate", "overall_wins", raw_factions)
	_render_matchup_stage_group(head_to_head_matrix[-1], matchups_overall_attacker_values, "atk_rate", "atk_wins", raw_factions)
	_render_matchup_stage_group(head_to_head_matrix[-1], matchups_overall_defender_values, "def_rate", "def_wins", raw_factions)
	
	_render_matchup_stage_group(head_to_head_matrix[0], matchups_early_stage_overall_values, "overall_rate", "overall_wins", raw_factions)
	_render_matchup_stage_group(head_to_head_matrix[0], matchups_early_stage_attacker_values, "atk_rate", "atk_wins", raw_factions)
	_render_matchup_stage_group(head_to_head_matrix[0], matchups_early_stage_defender_values, "def_rate", "def_wins", raw_factions)
	
	_render_matchup_stage_group(head_to_head_matrix[1], matchups_middle_stage_overall_values, "overall_rate", "overall_wins", raw_factions)
	_render_matchup_stage_group(head_to_head_matrix[1], matchups_middle_stage_attacker_values, "atk_rate", "atk_wins", raw_factions)
	_render_matchup_stage_group(head_to_head_matrix[1], matchups_middle_stage_defender_values, "def_rate", "def_wins", raw_factions)
	
	_render_matchup_stage_group(head_to_head_matrix[2], matchups_late_stage_overall_values, "overall_rate", "overall_wins", raw_factions)
	_render_matchup_stage_group(head_to_head_matrix[2], matchups_late_stage_attacker_values, "atk_rate", "atk_wins", raw_factions)
	_render_matchup_stage_group(head_to_head_matrix[2], matchups_late_stage_defender_values, "def_rate", "def_wins", raw_factions)

	# ─── CARD LEADERBOARD UI COMPILATION AND INLINE LAMBDA SORTING (ALL FACTIONS) ───
	var sorted_card_list: Array[Dictionary] = []
	for card_id in card_stats_cache[-1]:
		var stats = card_stats_cache[-1][card_id]
		var win_rate := 0.0
		if stats["games"] > 0:
			win_rate = (float(stats["wins"]) / float(stats["games"])) * 100.0
			
		var card_profile = raw_cards.get(card_id)
		var card_name: String = "Card ID %d" % card_id
		if card_profile:
			card_name = card_profile.card_name
		
		sorted_card_list.append({
			"name": card_name,
			"rate": win_rate,
			"wins": stats["wins"]
		})
		
	sorted_card_list.sort_custom(func(a, b): return a["rate"] > b["rate"])
	_spawn_leaderboard_bars(sorted_card_list, cards_all_factions_overall_values)

	# ─── 🎯 DYNAMIC PER-FACTION SUB-TAB FACTORY LOOPS ───
	for faction_id in sim_controller.factions_to_sim:
		var faction_profile = raw_factions.get(faction_id, {})
		var faction_name: String = faction_profile.get("name", FactionRegistry.FactionID.keys()[faction_id])
		
		var faction_card_list: Array[Dictionary] = []
		var faction_stats_map: Dictionary = card_stats_cache[faction_id]
		
		for card_id in faction_stats_map:
			var stats = faction_stats_map[card_id]
			var win_rate := 0.0
			if stats["games"] > 0:
				win_rate = (float(stats["wins"]) / float(stats["games"])) * 100.0
				
			var card_profile = raw_cards.get(card_id)
			var card_name: String = "Card ID %d" % card_id
			if card_profile:
				card_name = card_profile.card_name
				
			faction_card_list.append({
				"name": card_name,
				"rate": win_rate,
				"wins": stats["wins"]
			})
			
		faction_card_list.sort_custom(func(a, b): return a["rate"] > b["rate"])
		
		# Instantiate, name, and bind the tab sheet module
		var tab_instance = FACTION_TAB_SCENE.instantiate()
		cards_add_factions_tab.add_child(tab_instance)
		tab_instance.name = faction_name
		
		if tab_instance.has_method("initialize_faction_card_rows"):
			tab_instance.initialize_faction_card_rows(faction_card_list, FACTION_BAR_SCENE_H)


func _process_and_render_group(stage_data: Dictionary, overall_box: VBoxContainer, atk_box: VBoxContainer, def_box: VBoxContainer, raw_factions: Dictionary) -> void:
	var overall_list: Array[Dictionary] = []
	var attack_list: Array[Dictionary] = []
	var defense_list: Array[Dictionary] = []
	
	for f_id in stage_data:
		var stats: Dictionary = stage_data[f_id]
		var faction_profile = raw_factions.get(f_id)
		var name_string: String = faction_profile.get("name", FactionRegistry.FactionID.keys()[f_id])
		
		var total_wins: int = stats["atk_wins"] + stats["def_wins"]
		var total_games: int = stats["atk_games"] + stats["def_games"]
		var overall_rate := 0.0
		if total_games > 0:
			overall_rate = (float(total_wins) / float(total_games)) * 100.0
		overall_list.append({"name": name_string, "rate": overall_rate, "wins": total_wins})
		
		var atk_rate := 0.0
		if stats["atk_games"] > 0:
			atk_rate = (float(stats["atk_wins"]) / float(stats["atk_games"])) * 100.0
		attack_list.append({"name": name_string, "rate": atk_rate, "wins": stats["atk_wins"]})
		
		var def_rate := 0.0
		if stats["def_games"] > 0:
			def_rate = (float(stats["def_wins"]) / float(stats["def_games"])) * 100.0
		defense_list.append({"name": name_string, "rate": def_rate, "wins": stats["def_wins"]})
		
	overall_list.sort_custom(func(a, b): return a["rate"] > b["rate"])
	attack_list.sort_custom(func(a, b): return a["rate"] > b["rate"])
	defense_list.sort_custom(func(a, b): return a["rate"] > b["rate"])
	
	_spawn_leaderboard_bars(overall_list, overall_box)
	_spawn_leaderboard_bars(attack_list, atk_box)
	_spawn_leaderboard_bars(defense_list, def_box)


func _spawn_leaderboard_bars(sorted_data: Array[Dictionary], target_container: VBoxContainer) -> void:
	for faction in sorted_data:
		var bar_instance = FACTION_BAR_SCENE_H.instantiate()
		target_container.add_child(bar_instance)
		bar_instance.populate_bar(faction["name"], faction["rate"], faction["wins"])


# ─── MODULAR MATCHUP MATRIX GENERATION SUB-ENGINE ───

func _render_matchup_stage_group(stage_matrix_slice: Dictionary, target_container: VBoxContainer, rate_key: String, wins_key: String, raw_factions: Dictionary) -> void:
	if target_container == null: return
	
	for focus_id in sim_controller.factions_to_sim:
		var focus_profile = raw_factions.get(focus_id)
		var focus_name: String = focus_profile.get("name", FactionRegistry.FactionID.keys()[focus_id])
		
		var compiled_matchups_list: Array[Dictionary] = []
		
		for enemy_id in sim_controller.factions_to_sim:
			if focus_id == enemy_id:
				continue
				
			var enemy_profile = raw_factions.get(enemy_id)
			var enemy_name: String = enemy_profile.get("name", FactionRegistry.FactionID.keys()[enemy_id])
			
			var stats: Dictionary = stage_matrix_slice[focus_id][enemy_id]
			
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
				"overall_wins": stats["atk_wins"] + stats["def_wins"],
				"atk_rate": atk_rate,
				"atk_wins": stats["atk_wins"],
				"def_rate": def_rate,
				"def_wins": stats["def_wins"]
			})
		
		var row = MATCHUP_OVERALL_PANEL_SCENE.instantiate()
		target_container.add_child(row)
		row.initialize_real_matchup_row(focus_name, compiled_matchups_list, rate_key, wins_key)
