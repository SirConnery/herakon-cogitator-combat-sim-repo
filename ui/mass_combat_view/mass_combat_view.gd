extends Control

@onready var simulate_mass_combat_btn: Button = $HBoxContainer/SimulateMassCombatBtn

var sim_controller: SimController

func _ready() -> void:
	init_connections()

func init_connections() -> void:
	await get_tree().process_frame 
	sim_controller = owner.sim_controller
	
	simulate_mass_combat_btn.pressed.connect(simulate_mass_combat_btn_pressed)


func simulate_mass_combat_btn_pressed() -> void:
	sim_controller.run_mass_battles(sim_controller.total_iterations)
