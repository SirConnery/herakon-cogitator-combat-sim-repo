extends PanelContainer

const FACTION_BAR_SCENE_V := preload("uid://bpwm0ac0xfcbw")

@onready var faction_title: Label = %FactionTitle
@onready var matchup_row: HBoxContainer = %MatchupRow
@onready var h_layout: HBoxContainer = $MarginContainer/HLayout

func _ready() -> void:
	pass

## Generically populates this row with single-bar component scenes using your dynamic tab keys
func initialize_real_matchup_row(focus_faction_name: String, calculated_matchups_list: Array, rate_key: String, wins_key: String) -> void:
	faction_title.text = focus_faction_name
	
	# Clear out any old child scenes cleanly
	for child in matchup_row.get_children():
		child.queue_free()
	
	# Sort highest first
	calculated_matchups_list.sort_custom(func(a, b): return a[rate_key] > b[rate_key])
	
	# Ensure layouts stretch out and fill areas properly
	if h_layout:
		h_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	matchup_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	matchup_row.add_theme_constant_override("separation", 24)
	
	# 🎯 UPDATED: Infers "overall_games", "atk_games", or "def_games" from your wins_key pattern
	var matches_key: String = wins_key.replace("wins", "games")
		
	# Drop in your new specialized vertical bar component scenes
	for data in calculated_matchups_list:
		var enemy_name: String = data["enemy_name"]
		var real_rate: float = data[rate_key]
		var real_wins: int = data[wins_key]
		
		# 🎯 UPDATED: Extract context-appropriate matches, falling back to wins if key tracking misses
		var real_matches: int = data.get(matches_key, real_wins)
		
		# Instantiate your concrete vertical bar scene asset
		var col = FACTION_BAR_SCENE_V.instantiate() as FactionBarV
		matchup_row.add_child(col)
		
		# 🎯 UPDATED: Pass all 4 tracking arguments safely to the component script layout
		col.populate_bar(enemy_name, real_rate, real_wins, real_matches)
