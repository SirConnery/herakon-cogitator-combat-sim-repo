extends Control
class_name SingleCombatView

# --- SCENE REFERENCES ---
@onready var round_panel_scene: PackedScene = preload("res://ui/single_combat_view/combat_round_panel.tscn")

# --- UI ELEMENT NODES (Parent UI references dropped for direct encapsulation) ---
@onready var header_panel: PanelContainer = $MainLayout/HeaderPanel
@onready var game_stage_label: Label = $MainLayout/HeaderPanel/HeaderContainer/HLayout/GameStage
@onready var combat_participants_value: Label = $MainLayout/HeaderPanel/HeaderContainer/HLayout/CombatParticipantsValue

@onready var attacker_drawn_cards_value: Label = $MainLayout/HeaderPanel/HeaderContainer/CardsDrawnToHandAtStart/AttackerDrawnCardsValue
@onready var defender_drawn_cards_value: Label = $MainLayout/HeaderPanel/HeaderContainer/CardsDrawnToHandAtStart/DefenderDrawnCardsValue

@onready var round_1_container: VBoxContainer = $MainLayout/CentralCombatView/RoundsContainer/Round1
@onready var round_2_container: VBoxContainer = $MainLayout/CentralCombatView/RoundsContainer/Round2
@onready var round_3_container: VBoxContainer = $MainLayout/CentralCombatView/RoundsContainer/Round3



# Interactive Setup Controls (Scene Unique Mappings)
@onready var faction_select_attacker_btn: OptionButton = %FactionSelectAttackerBtn
@onready var faction_select_defender_btn: OptionButton = %FactionSelectDefenderBtn
@onready var stage_select_btn: OptionButton = %StageSelectBtn
@onready var is_ground_combat_btn: CheckButton = %IsGroundCombatBtn
@onready var start_new_combat_btn: Button = %StartNewCombatBtn

@onready var ui: UI = owner

const RANDOM_ID = 999


func _ready() -> void:
	header_panel.hide()
	init_connections()
	
	# Populate when this view tab actively moves into view
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible:
		_setup_dropdown_options()
		_sync_ui_to_controller_states()


func init_connections() -> void:
	start_new_combat_btn.pressed.connect(start_new_combat_btn_pressed)
	
	faction_select_attacker_btn.item_selected.connect(_on_attacker_selected)
	faction_select_defender_btn.item_selected.connect(_on_defender_selected)
	stage_select_btn.item_selected.connect(_on_stage_selected)
	is_ground_combat_btn.toggled.connect(_on_ground_combat_toggled)


# ─── COMBAT ENGINE DATA EXECUTION LINE ───

func start_new_combat_btn_pressed() -> void:
	if ui == null or ui.sim_controller == null: return
	
	_initialize_logger_session()
	_build_and_register_combat_panels()
	
	# Execute core math loop via decoupled sim controller instance
	ui.sim_controller.run_single_logged_combat()
	
	# Render the newly parsed output variables directly into local headers
	update_headers()
	header_panel.show()


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
		UI_Utils.clear_children(target_container)
		
		var panel_instance = round_panel_scene.instantiate() as CombatRoundPanel
		target_container.add_child(panel_instance)
		panel_instance.set_round_header_labels(i + 1)

		# Append to the global logger monitoring registry list
		G_Logger.active_round_panels.append(panel_instance)


# ─── LOCAL TEXT HEADER FORMATTERS ───

func update_headers() -> void:
	if ui == null or ui.sim_controller == null: return
	
	update_game_stage_header(ui.sim_controller.current_stage)
	update_starting_cards_header(ui.sim_controller)
	update_combat_participants_header(ui.sim_controller)


## Queries the sim instance to parse and display the match participants
func update_combat_participants_header(sim: SimController) -> void:
	if combat_participants_value == null: return
	combat_participants_value.text = "%s vs %s" % [sim.attacker_faction_name, sim.defender_faction_name]


## Queries the sim instance to parse and display the starting hands
func update_starting_cards_header(sim: SimController) -> void:
	if attacker_drawn_cards_value == null or defender_drawn_cards_value == null: return
		
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
	if game_stage_label == null: return
		
	var stage_text := ""
	match stage_val:
		GameStageGenerator.Stage.EARLY:
			stage_text = " Early Conflict"
		GameStageGenerator.Stage.MID:
			stage_text = " Mid-War Escalation"
		GameStageGenerator.Stage.LATE:
			stage_text = " Late-Stage Armageddon"
		_:
			stage_text = " Unknown Stage"
			
	game_stage_label.text = stage_text


# ─── DISPATCH CONFIG SIGNALS TO BACKEND CONTROLLER ───

func _setup_dropdown_options() -> void:
	faction_select_attacker_btn.clear()
	faction_select_defender_btn.clear()
	stage_select_btn.clear()
	
	faction_select_attacker_btn.add_item("Random Faction", RANDOM_ID)
	faction_select_defender_btn.add_item("Random Faction", RANDOM_ID)
	stage_select_btn.add_item("Random Stage", RANDOM_ID)
	
	var raw_factions: Dictionary = FactionRegistry.get_database()
	for f_enum in FactionRegistry.FactionID.values():
		var profile = raw_factions.get(f_enum)
		var f_name: String = profile.get("name", FactionRegistry.FactionID.keys()[f_enum].capitalize())
		faction_select_attacker_btn.add_item(f_name, f_enum)
		faction_select_defender_btn.add_item(f_name, f_enum)
		
	for stage_key in GameStageGenerator.Stage.keys():
		var stage_enum_val: int = GameStageGenerator.Stage[stage_key]
		stage_select_btn.add_item(stage_key.capitalize(), stage_enum_val)


func _sync_ui_to_controller_states() -> void:
	if ui == null or ui.sim_controller == null: return
	
	is_ground_combat_btn.button_pressed = ui.sim_controller.is_ground_combat
	
	_select_dropdown_by_id(faction_select_attacker_btn, RANDOM_ID if ui.sim_controller.attacker_is_random_in_single else ui.sim_controller.attacker_faction_in_single_combat)
	_select_dropdown_by_id(faction_select_defender_btn, RANDOM_ID if ui.sim_controller.defender_is_random_in_single else ui.sim_controller.defender_faction_in_single_combat)
	_select_dropdown_by_id(stage_select_btn, RANDOM_ID if ui.sim_controller.is_random_stage else ui.sim_controller.debug_stage)
	
	_enforce_no_mirror_options()


func _on_attacker_selected(index: int) -> void:
	if ui == null or ui.sim_controller == null: return
	
	var id = faction_select_attacker_btn.get_item_id(index)
	ui.sim_controller.attacker_is_random_in_single = (id == RANDOM_ID)
	if id != RANDOM_ID:
		ui.sim_controller.attacker_faction_in_single_combat = id as FactionRegistry.FactionID
		
	_enforce_no_mirror_options()


func _on_defender_selected(index: int) -> void:
	if ui == null or ui.sim_controller == null: return
	
	var id = faction_select_defender_btn.get_item_id(index)
	ui.sim_controller.defender_is_random_in_single = (id == RANDOM_ID)
	if id != RANDOM_ID:
		ui.sim_controller.defender_faction_in_single_combat = id as FactionRegistry.FactionID
		
	_enforce_no_mirror_options()


func _enforce_no_mirror_options() -> void:
	var atk_selected_id: int = faction_select_attacker_btn.get_selected_id()
	var def_selected_id: int = faction_select_defender_btn.get_selected_id()
	
	for i in range(faction_select_attacker_btn.item_count):
		faction_select_attacker_btn.set_item_disabled(i, false)
		faction_select_defender_btn.set_item_disabled(i, false)
		
	if atk_selected_id != RANDOM_ID:
		for i in range(faction_select_defender_btn.item_count):
			if faction_select_defender_btn.get_item_id(i) == atk_selected_id:
				faction_select_defender_btn.set_item_disabled(i, true)
				
	if def_selected_id != RANDOM_ID:
		for i in range(faction_select_attacker_btn.item_count):
			if faction_select_attacker_btn.get_item_id(i) == def_selected_id:
				faction_select_attacker_btn.set_item_disabled(i, true)


func _on_stage_selected(index: int) -> void:
	if ui == null or ui.sim_controller == null: return
	
	var id = stage_select_btn.get_item_id(index)
	ui.sim_controller.is_random_stage = (id == RANDOM_ID)
	if id != RANDOM_ID:
		ui.sim_controller.debug_stage = id as GameStageGenerator.Stage


func _on_ground_combat_toggled(pressed: bool) -> void:
	if ui == null or ui.sim_controller == null: return
	ui.sim_controller.is_ground_combat = pressed


func _select_dropdown_by_id(dropdown: OptionButton, target_id: int) -> void:
	for i in range(dropdown.item_count):
		if dropdown.get_item_id(i) == target_id:
			dropdown.select(i)
			break
