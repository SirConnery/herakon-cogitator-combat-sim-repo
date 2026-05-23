extends Control
class_name UI

# --- SCENE REFERENCES ---
@onready var round_panel_scene: PackedScene = preload("res://ui/combat_round_panel.tscn")

# --- UI ELEMENT NODES ---
@onready var game_stage_label: Label = $MainLayout/HeaderPanel/HeaderContainer/HLayout/GameStage

@onready var round_1_container: VBoxContainer = $MainLayout/CentralCombatView/RoundsContainer/Round1
@onready var round_2_container: VBoxContainer = $MainLayout/CentralCombatView/RoundsContainer/Round2
@onready var round_3_container: VBoxContainer = $MainLayout/CentralCombatView/RoundsContainer/Round3


func _ready() -> void:
	_initialize_logger_session()
	_build_and_register_combat_panels()
	_start_simulation_subsystem()


func _initialize_logger_session() -> void:
	G_Logger.clear_session()


## Instantiates, configures, and hooks the combat panels up to the backend tracking arrays
func _build_and_register_combat_panels() -> void:
	var round_containers := [
		round_1_container,
		round_2_container,
		round_3_container
	]

	# Build exactly one tracking module layer per active conflict step
	for i in range(3):
		var panel_instance = round_panel_scene.instantiate() as CombatRoundPanel

		# Bind to its parent structural anchor node layout
		round_containers[i].add_child(panel_instance)

		# Configure the localized text string layout values
		panel_instance.set_round_header_labels(i + 1)

		# Append to the global logger monitoring registry list
		G_Logger.active_round_panels.append(panel_instance)


## Spawns the decoupled execution controller and updates structural visual header labels
func _start_simulation_subsystem() -> void:
	var sim = SimController.new()
	add_child(sim)
	
	update_game_stage_header(sim.current_stage)


## Maps the backend GameStageGenerator.Stage enum value to a thematic string text presentation
func update_game_stage_header(stage_val: GameStageGenerator.Stage) -> void:
	if game_stage_label == null: 
		return
		
	var stage_text := ""
	match stage_val:
		GameStageGenerator.Stage.EARLY:
			stage_text = "🪵 Early Conflict"
		GameStageGenerator.Stage.MID:
			stage_text = "⚙️ Mid-War Escalation"
		GameStageGenerator.Stage.LATE:
			stage_text = "🌋 Late-Stage Armageddon"
		_:
			stage_text = "❓ Unknown Stage"
			
	game_stage_label.text = stage_text
