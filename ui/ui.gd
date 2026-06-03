extends Control
class_name UI

@onready var main_tabs: TabContainer = $MainTabs

# --- CORE CONTROLLERS ---
@onready var sim_controller: SimController = $SimController
@onready var single_combat_view: SingleCombatView = $MainTabs/SingleCombatView
@onready var mass_combat_view: Control = $MainTabs/MassCombatView
@onready var diagnostics_view: DiagnosticsView = $MainTabs/DiagnosticsView


func _ready() -> void:
	sync_other_nodes()
	G_SimEvents.mass_sim_completed.connect(_on_mass_sim_completed)
	_disable_mass_combat_sim_for_web()

func _disable_mass_combat_sim_for_web() -> void:
	main_tabs.set_tab_disabled(2, true)

func sync_other_nodes() -> void:
	single_combat_view.sim = sim_controller
	mass_combat_view.sim = sim_controller


func start_mass_combat_sim() -> void:
	diagnostics_view.data_processed = false
	sim_controller.run_mass_combat_simulation()
	disable_nodes_until_mass_sim_completes(true)
	


func _on_mass_sim_completed() -> void:
	diagnostics_view.data_processed = true
	disable_nodes_until_mass_sim_completes(false)

func disable_nodes_until_mass_sim_completes(is_disabled: bool) -> void:
	main_tabs.set_tab_disabled(1, is_disabled)
	main_tabs.set_tab_disabled(3, is_disabled)
