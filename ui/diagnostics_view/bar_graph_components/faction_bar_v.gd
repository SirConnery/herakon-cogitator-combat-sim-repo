extends FactionBar
class_name FactionBarV

@onready var _faction_name: Label = %OpposingFactionName
@onready var _win_count_label: Label = %WinCountLabel
@onready var _win_rate_bar: ProgressBar = %WinRateBar
@onready var _match_count_label: Label = %MatchCountLabel


func _ready() -> void:
	setup()

func setup() -> void:
	faction_name = _faction_name
	win_rate_bar = _win_rate_bar
	win_count_label = _win_count_label
	match_count_label = _match_count_label
