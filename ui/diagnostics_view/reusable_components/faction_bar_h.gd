extends FactionBar
class_name FactionBarH

@onready var _faction_name: Label = %MainFactionName
@onready var _win_rate_bar: ProgressBar = %WinRateBar
@onready var _win_count_label: Label = %WinCountLabel



func _ready() -> void:
	setup()

func setup() -> void:
	faction_name = _faction_name
	win_rate_bar = _win_rate_bar
	win_count_label = _win_count_label
