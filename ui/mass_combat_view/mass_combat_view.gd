extends Control

@onready var simulate_mass_combat_btn: Button = %SimulateMassCombatBtn
@onready var mass_sim_progress_bar: ProgressBar = %MassSimProgressBar

@onready var ui: UI = owner

var sim: SimController
var ui_refresh_timer: Timer


func _ready() -> void:
	init_connections()
	setup_heartbeat_timer()


func init_connections() -> void:
	simulate_mass_combat_btn.pressed.connect(simulate_mass_combat_btn_pressed)
	G_SimEvents.mass_sim_completed.connect(_on_mass_sim_completed)


func setup_heartbeat_timer() -> void:
	# Create a dedicated UI polling timer childed completely inside this view
	ui_refresh_timer = Timer.new()
	ui_refresh_timer.wait_time = 1.5 # Check progress every 1.5 seconds
	ui_refresh_timer.timeout.connect(_on_ui_refresh_timer_timeout)
	add_child(ui_refresh_timer)


func simulate_mass_combat_btn_pressed() -> void:
	mass_sim_progress_bar.value = 0
	mass_sim_progress_bar.max_value = 100
	simulate_mass_combat_btn.disabled = true
	
	# Pass execution up to the orchestrator, then start ticking visually
	ui.start_mass_combat_sim()
	ui_refresh_timer.start()


func _on_ui_refresh_timer_timeout() -> void:
	if sim and sim.total_chunks > 0:
		update_mass_sim_progress_bar(sim.completed_chunks, sim.total_chunks)


func update_mass_sim_progress_bar(current_progress: int, total_progress: int) -> void:
	mass_sim_progress_bar.max_value = total_progress
	mass_sim_progress_bar.value = current_progress


func _on_mass_sim_completed() -> void:
	ui_refresh_timer.stop()
	if sim:
		update_mass_sim_progress_bar(sim.total_chunks, sim.total_chunks)
	
	simulate_mass_combat_btn.disabled = false
	
