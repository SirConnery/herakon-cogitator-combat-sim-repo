extends Control

@onready var start_new_combat_btn: Button = $MainLayout/UserControls/StartNewCombatBtn

@onready var ui: UI = owner

func _ready() -> void:
	init_connections()

func init_connections() -> void:
	start_new_combat_btn.pressed.connect(start_new_combat_btn_pressed)

func start_new_combat_btn_pressed() -> void:
	ui.start_single_logged_combat()
