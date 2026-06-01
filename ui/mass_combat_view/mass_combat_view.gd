extends Control

@onready var simulate_mass_combat_btn: Button = %SimulateMassCombatBtn
@onready var mass_sim_progress_bar: ProgressBar = %MassSimProgressBar

@onready var ui: UI = owner

func _ready() -> void:
	init_connections()

func init_connections() -> void:
	simulate_mass_combat_btn.pressed.connect(simulate_mass_combat_btn_pressed)
	G_SimEvents.mass_sim_progress_updated.connect(update_mass_sim_progress_bar)

func simulate_mass_combat_btn_pressed() -> void:
	mass_sim_progress_bar.value = 0
	mass_sim_progress_bar.max_value = 100
	
	ui.start_mass_combat_sim()

func update_mass_sim_progress_bar(current_progress: int, total_progress: int) -> void:
	mass_sim_progress_bar.max_value = total_progress
	mass_sim_progress_bar.value = current_progress
