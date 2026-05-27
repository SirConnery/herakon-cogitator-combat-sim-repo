extends Control
class_name UI

# --- CORE CONTROLLERS ---
@onready var sim_controller: SimController = $SimController


func _ready() -> void:
	pass

## Triggers the mass round-robin simulation batch process matrix
func start_mass_combat_sim() -> void:
	sim_controller.run_mass_combat_simulation()
