extends Control

@onready var simulate_mass_combat_btn: Button = $HBoxContainer/SimulateMassCombatBtn

@onready var ui: UI = owner

func _ready() -> void:
	init_connections()

func init_connections() -> void:
	simulate_mass_combat_btn.pressed.connect(simulate_mass_combat_btn_pressed)

func simulate_mass_combat_btn_pressed() -> void:
	ui.start_mass_combat_sim()
