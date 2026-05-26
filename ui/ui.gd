extends Control
class_name UI

# --- SCENE REFERENCES ---
@onready var round_panel_scene: PackedScene = preload("res://ui/single_combat_view/combat_round_panel.tscn")

# --- UI ELEMENT NODES ---
@onready var game_stage_label: Label = $MainTabs/SingleCombatView/MainLayout/HeaderPanel/HeaderContainer/HLayout/GameStage
@onready var combat_participants_value: Label = $MainTabs/SingleCombatView/MainLayout/HeaderPanel/HeaderContainer/HLayout/CombatParticipantsValue

@onready var attacker_drawn_cards_value: Label = $MainTabs/SingleCombatView/MainLayout/HeaderPanel/HeaderContainer/CardsDrawnToHandAtStart/AttackerDrawnCardsValue
@onready var defender_drawn_cards_value: Label = $MainTabs/SingleCombatView/MainLayout/HeaderPanel/HeaderContainer/CardsDrawnToHandAtStart/DefenderDrawnCardsValue

@onready var round_1_container: VBoxContainer = $MainTabs/SingleCombatView/MainLayout/CentralCombatView/RoundsContainer/Round1
@onready var round_2_container: VBoxContainer = $MainTabs/SingleCombatView/MainLayout/CentralCombatView/RoundsContainer/Round2
@onready var round_3_container: VBoxContainer = $MainTabs/SingleCombatView/MainLayout/CentralCombatView/RoundsContainer/Round3

@onready var sim_controller: SimController = $SimController

func _ready() -> void:
	pass

func start_single_logged_combat() -> void:
	_initialize_logger_session()
	_build_and_register_combat_panels()
	sim_controller.run_single_logged_battle()
	
	update_headers()

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
		var target_container = round_containers[i]
		
		for child in target_container.get_children():
			child.queue_free()
		
		var panel_instance = round_panel_scene.instantiate() as CombatRoundPanel

		# Bind to its parent structural anchor node layout
		target_container.add_child(panel_instance)

		# Configure the localized text string layout values
		panel_instance.set_round_header_labels(i + 1)

		# Append to the global logger monitoring registry list
		G_Logger.active_round_panels.append(panel_instance)


func update_headers() -> void:
	update_game_stage_header(sim_controller.current_stage)
	update_starting_cards_header(sim_controller)
	update_combat_participants_header(sim_controller)

## Queries the sim instance to parse and display the match participants
func update_combat_participants_header(sim: SimController) -> void:
	if combat_participants_value == null:
		return
		
	combat_participants_value.text = "%s vs %s" % [sim.attacker_faction_name, sim.defender_faction_name]

## Queries the sim instance to parse and display the starting hands
func update_starting_cards_header(sim: SimController) -> void:
	if attacker_drawn_cards_value == null or defender_drawn_cards_value == null: 
		return
		
	var atk_names: Array[String] = []
	for card_id in sim.attacker_starting_hand:
		atk_names.append(sim.get_card_metadata(card_id, "card_name"))
		
	var def_names: Array[String] = []
	for card_id in sim.defender_starting_hand:
		def_names.append(sim.get_card_metadata(card_id, "card_name"))
		
	attacker_drawn_cards_value.text = ", ".join(atk_names)
	defender_drawn_cards_value.text = ", ".join(def_names)


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
