extends Control

@onready var header_panel: PanelContainer = $MainLayout/HeaderPanel
@onready var ui: UI = owner

# User Controls
@onready var faction_select_attacker_btn: OptionButton = %FactionSelectAttackerBtn
@onready var faction_select_defender_btn: OptionButton = %FactionSelectDefenderBtn
@onready var stage_select_btn: OptionButton = %StageSelectBtn
@onready var is_ground_combat_btn: CheckButton = %IsGroundCombatBtn
@onready var start_new_combat_btn: Button = %StartNewCombatBtn


const RANDOM_ID = -1


func _ready() -> void:
	header_panel.hide()
	
	# Connect your signals immediately on launch
	init_connections()
	
	# Listen for when this specific screen is clicked open/made active
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	# At the moment of interaction, the parent UI is 100% loaded.
	# We can safely populate and synchronize everything without guards!
	if visible:
		_setup_dropdown_options()
		_sync_ui_to_controller_states()


func init_connections() -> void:
	start_new_combat_btn.pressed.connect(start_new_combat_btn_pressed)
	
	faction_select_attacker_btn.item_selected.connect(_on_attacker_selected)
	faction_select_defender_btn.item_selected.connect(_on_defender_selected)
	stage_select_btn.item_selected.connect(_on_stage_selected)
	is_ground_combat_btn.toggled.connect(_on_ground_combat_toggled)


## Populates items and binds registry Enum IDs to the dropdown rows
func _setup_dropdown_options() -> void:
	faction_select_attacker_btn.clear()
	faction_select_defender_btn.clear()
	stage_select_btn.clear()
	
	# 1. Inject Random selectors at the top of the lists
	faction_select_attacker_btn.add_item("Random Faction", RANDOM_ID)
	faction_select_defender_btn.add_item("Random Faction", RANDOM_ID)
	stage_select_btn.add_item("Random Stage", RANDOM_ID)
	
	# 2. Populate Factions from active Database Registry entries
	var raw_factions: Dictionary = FactionRegistry.get_database()
	for f_enum in FactionRegistry.FactionID.values():
		var profile = raw_factions.get(f_enum)
		var f_name: String = profile.get("name", FactionRegistry.FactionID.keys()[f_enum].capitalize())
		faction_select_attacker_btn.add_item(f_name, f_enum)
		faction_select_defender_btn.add_item(f_name, f_enum)
		
	# 3. Populate Combat Stages from Enum Keys
	for stage_key in GameStageGenerator.Stage.keys():
		var stage_enum_val: int = GameStageGenerator.Stage[stage_key]
		stage_select_btn.add_item(stage_key.capitalize(), stage_enum_val)


## Reads current variable data frames straight out of SimController
func _sync_ui_to_controller_states() -> void:
	is_ground_combat_btn.button_pressed = ui.sim_controller.is_ground_combat
	
	# Synchronize Factions
	if ui.sim_controller.random_factions_in_single_combat:
		_select_dropdown_by_id(faction_select_attacker_btn, RANDOM_ID)
		_select_dropdown_by_id(faction_select_defender_btn, RANDOM_ID)
	else:
		_select_dropdown_by_id(faction_select_attacker_btn, ui.sim_controller.attacker_faction_in_single_combat)
		_select_dropdown_by_id(faction_select_defender_btn, ui.sim_controller.defender_faction_in_single_combat)
		
	# Synchronize Stage
	if ui.sim_controller.is_random_stage:
		_select_dropdown_by_id(stage_select_btn, RANDOM_ID)
	else:
		_select_dropdown_by_id(stage_select_btn, ui.sim_controller.debug_stage)


# ─── DISPATCH SIGNALS TO CONTROLLER PROPERTY WORKSPACE ───

func _on_attacker_selected(index: int) -> void:
	var id = faction_select_attacker_btn.get_item_id(index)
	if id == RANDOM_ID:
		ui.sim_controller.random_factions_in_single_combat = true
		_select_dropdown_by_id(faction_select_defender_btn, RANDOM_ID)
	else:
		ui.sim_controller.random_factions_in_single_combat = false
		ui.sim_controller.attacker_faction_in_single_combat = id as FactionRegistry.FactionID
		
		# Guard: If defender was random, force a valid companion faction to prevent mirror/null breaks
		if faction_select_defender_btn.get_selected_id() == RANDOM_ID:
			var backup_idx = 1 if id != faction_select_defender_btn.get_item_id(1) else 2
			faction_select_defender_btn.select(backup_idx)
			ui.sim_controller.defender_faction_in_single_combat = faction_select_defender_btn.get_selected_id() as FactionRegistry.FactionID


func _on_defender_selected(index: int) -> void:
	var id = faction_select_defender_btn.get_item_id(index)
	if id == RANDOM_ID:
		ui.sim_controller.random_factions_in_single_combat = true
		_select_dropdown_by_id(faction_select_attacker_btn, RANDOM_ID)
	else:
		ui.sim_controller.random_factions_in_single_combat = false
		ui.sim_controller.defender_faction_in_single_combat = id as FactionRegistry.FactionID
		
		# Guard: If attacker was random, force a valid companion faction
		if faction_select_attacker_btn.get_selected_id() == RANDOM_ID:
			var backup_idx = 1 if id != faction_select_attacker_btn.get_item_id(1) else 2
			faction_select_attacker_btn.select(backup_idx)
			ui.sim_controller.attacker_faction_in_single_combat = faction_select_attacker_btn.get_selected_id() as FactionRegistry.FactionID


func _on_stage_selected(index: int) -> void:
	var id = stage_select_btn.get_item_id(index)
	if id == RANDOM_ID:
		ui.sim_controller.is_random_stage = true
	else:
		ui.sim_controller.is_random_stage = false
		ui.sim_controller.debug_stage = id as GameStageGenerator.Stage


func _on_ground_combat_toggled(pressed: bool) -> void:
	ui.sim_controller.is_ground_combat = pressed


func start_new_combat_btn_pressed() -> void:
	ui.start_single_logged_combat()
	header_panel.show()


# ─── UTILITY FUNCTIONS ───

## Loops through items to find and display the row associated with an ID integer
func _select_dropdown_by_id(dropdown: OptionButton, target_id: int) -> void:
	for i in range(dropdown.item_count):
		if dropdown.get_item_id(i) == target_id:
			dropdown.select(i)
			break
