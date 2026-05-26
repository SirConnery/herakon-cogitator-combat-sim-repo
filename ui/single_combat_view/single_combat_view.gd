extends Control

@onready var start_new_combat_btn: Button = $MainLayout/UserControls/StartNewCombatBtn
@onready var header_panel: PanelContainer = $MainLayout/HeaderPanel

@onready var ui: UI = owner

func _ready() -> void:
	init_connections()
	header_panel.hide()

func init_connections() -> void:
	start_new_combat_btn.pressed.connect(start_new_combat_btn_pressed)

func start_new_combat_btn_pressed() -> void:
	ui.start_single_logged_combat()
	header_panel.show()
