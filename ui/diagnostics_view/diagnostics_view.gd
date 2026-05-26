extends Control
class_name DiagnosticsView

# --- SCENE REFERENCES ---
@onready var faction_bar_scene := preload("res://ui/diagnostics_view/faction_bar_row.tscn")

# --- UI ELEMENT NODES ---
@onready var attack_bar_container: VBoxContainer = $PageScroll/CenterConstraint/ContentContainer/FactionWinrates/HLayout/AttackerWinRatesPanel/AttackerWinRates
@onready var defense_bar_container: VBoxContainer = $PageScroll/CenterConstraint/ContentContainer/FactionWinrates/HLayout/DefenderWinratesPanel/DefenderWinRates

# --- CONTROLLER REFS ---
@onready var ui: UI = owner
var sim_controller: SimController

# ─── LISTEN TO TAB ACTIVATION ───

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	UI_Utils.clear_children(attack_bar_container)
	UI_Utils.clear_children(defense_bar_container)
	
	populate_diagnostics_dashboard()

func populate_diagnostics_dashboard() -> void:
	sim_controller = ui.sim_controller
	
	# Clear out previous visual rows
	UI_Utils.clear_children(attack_bar_container)
	UI_Utils.clear_children(defense_bar_container)
	
	# 1. Instantiate analyzer and pull data from binary space
	var analyzer := SimDiagnostics.new()
	var binary_path := "user://simulation_raw_data.dat"
	
	# Pass the matrix faction pool straight down to allocate dictionary structures
	if not analyzer.load_and_parse_binary(binary_path, sim_controller.factions_to_sim):
		return
		
	# 2. Extract database registry mappings to resolve ID integers to readable names
	var raw_factions: Dictionary = FactionRegistry.get_database()
	
	var attack_leaderboard: Array[Dictionary] = []
	var defense_leaderboard: Array[Dictionary] = []
	
	# 3. Compile separate lists for Attack vs Defense math processing
	for f_id in analyzer.faction_stats:
		var stats: Dictionary = analyzer.faction_stats[f_id]
		var faction_profile = raw_factions.get(f_id)
		var name_string: String = faction_profile.get("name", FactionRegistry.FactionID.keys()[f_id])
		
		# Crunch Attack metrics row
		var atk_rate := 0.0
		if stats["atk_games"] > 0:
			atk_rate = (float(stats["atk_wins"]) / float(stats["atk_games"])) * 100.0
		
		attack_leaderboard.append({
			"name": name_string,
			"rate": atk_rate,
			"wins": stats["atk_wins"]
		})
		
		# Crunch Defense metrics row
		var def_rate := 0.0
		if stats["def_games"] > 0:
			def_rate = (float(stats["def_wins"]) / float(stats["def_games"])) * 100.0
			
		defense_leaderboard.append({
			"name": name_string,
			"rate": def_rate,
			"wins": stats["def_wins"]
		})
		
	# 4. SORTING ENGINE: Sort both arrays completely independently by their win rate margins
	attack_leaderboard.sort_custom(func(a, b): return a["rate"] > b["rate"])
	defense_leaderboard.sort_custom(func(a, b): return a["rate"] > b["rate"])
	
	# 5. GENERATE VISUAL BARS IN THE LEADERBOARD COLUMNS
	_spawn_leaderboard_bars(attack_leaderboard, attack_bar_container)
	_spawn_leaderboard_bars(defense_leaderboard, defense_bar_container)


## Helper utility instantiation wrapper loop
func _spawn_leaderboard_bars(sorted_data: Array[Dictionary], target_container: VBoxContainer) -> void:
	for faction in sorted_data:
		var bar_instance = faction_bar_scene.instantiate()
		target_container.add_child(bar_instance)
		
		# Update values inside our Progress bar component row
		bar_instance.populate_bar(faction["name"], faction["rate"], faction["wins"])
