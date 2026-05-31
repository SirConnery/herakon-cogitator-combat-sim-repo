extends Control
class_name UI

# --- CORE CONTROLLERS ---
@onready var sim_controller: SimController = $SimController
@onready var single_combat_view: SingleCombatView = $MainTabs/SingleCombatView
@onready var diagnostics_view: DiagnosticsView = $MainTabs/DiagnosticsView


func _ready() -> void:
	single_combat_view.sim = sim_controller

## Triggers the mass round-robin simulation batch process matrix
func start_mass_combat_sim() -> void:
	diagnostics_view.data_processed = false
	sim_controller.run_mass_combat_simulation()
