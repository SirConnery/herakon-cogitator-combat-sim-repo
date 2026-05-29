extends Control
class_name SingleCombatView

# --- SCENE REFERENCES ---
@onready var round_panel_scene: PackedScene = preload("res://ui/single_combat_view/combat_round_panel.tscn")

# --- UI ELEMENT NODES ---
@onready var header_panel: PanelContainer = $MainLayout/HeaderPanel
@onready var game_stage_label: Label = $MainLayout/HeaderPanel/HeaderContainer/HLayout/GameStage
@onready var combat_participants_value: Label = $MainLayout/HeaderPanel/HeaderContainer/HLayout/CombatParticipantsValue

@onready var attacker_drawn_cards_value: Label = $MainLayout/HeaderPanel/HeaderContainer/CardsDrawnToHandAtStart/AttackerDrawnCardsValue
@onready var defender_drawn_cards_value: Label = $MainLayout/HeaderPanel/HeaderContainer/CardsDrawnToHandAtStart/DefenderDrawnCardsValue

@onready var round_1_container: VBoxContainer = $MainLayout/CentralCombatView/RoundsContainer/Round1
@onready var round_2_container: VBoxContainer = $MainLayout/CentralCombatView/RoundsContainer/Round2
@onready var round_3_container: VBoxContainer = $MainLayout/CentralCombatView/RoundsContainer/Round3

# Interactive Setup Controls
@onready var faction_select_attacker_btn: OptionButton = %FactionSelectAttackerBtn
@onready var cards_select_attacker_btn: OptionButton = %CardsSelectAttackerBtn
@onready var attacker_uses_default_deck: CheckButton = %AttackerUsesDefaultDeck

@onready var faction_select_defender_btn: OptionButton = %FactionSelectDefenderBtn
@onready var cards_select_defender_btn: OptionButton = %CardsSelectDefenderBtn
@onready var defender_uses_default_deck: CheckButton = %DefenderUsesDefaultDeck

@onready var stage_select_btn: OptionButton = %StageSelectBtn
@onready var is_ground_combat_btn: CheckButton = %IsGroundCombatBtn
@onready var start_new_combat_btn: Button = %StartNewCombatBtn

@onready var ui: UI = owner

# Localized UI View States (Completely Isolated from SimController)
var attacker_is_random_faction: bool = true
var defender_is_random_faction: bool = true

# Local State Tracking Variables for Explicit non-random Choices
var attacker_selected_faction_id: int = 0 
var defender_selected_faction_id: int = 1 

const RANDOM_ID: int = 999
const CLEAR_DECK_ID: int = 998


func _ready() -> void:
	header_panel.hide()
	init_connections()
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
	
	attacker_uses_default_deck.toggled.connect(_on_attacker_deck_toggle_changed)
	defender_uses_default_deck.toggled.connect(_on_defender_deck_toggle_changed)
	cards_select_attacker_btn.item_selected.connect(_on_attacker_card_drafted)
	cards_select_defender_btn.item_selected.connect(_on_defender_card_drafted)


# ─── COMBAT ENGINE DATA EXECUTION LINE ───

func start_new_combat_btn_pressed() -> void:
	if ui == null or ui.sim_controller == null: 
		return
	
	# Unpack layout realities into a generic configuration envelope
	var combat_config := {
		"attacker_id": faction_select_attacker_btn.get_selected_id(),
		"defender_id": faction_select_defender_btn.get_selected_id(),
		"attacker_is_custom_deck": (not attacker_is_random_faction and not attacker_uses_default_deck.button_pressed),
		"defender_is_custom_deck": (not defender_is_random_faction and not defender_uses_default_deck.button_pressed)
	}
	
	# Set up the simulation controller's deck override flag
	ui.sim_controller.use_custom_combat_decks = (combat_config.attacker_is_custom_deck or combat_config.defender_is_custom_deck)
	
	G_Logger.clear_session()
	_build_and_register_combat_panels()
	
	# 🎯 Pass the decoupled configuration object
	ui.sim_controller.run_single_logged_combat(combat_config)
	
	update_headers()
	header_panel.show()


func _build_and_register_combat_panels() -> void:
	var round_containers := [round_1_container, round_2_container, round_3_container]
	
	for i in range(3):
		var target_container = round_containers[i]
		UI_Utils.clear_children(target_container)
		
		var panel_instance = round_panel_scene.instantiate() as CombatRoundPanel
		target_container.add_child(panel_instance)
		panel_instance.set_round_header_labels(i + 1)
		
		G_Logger.active_round_panels.append(panel_instance)


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
	if ui == null or ui.sim_controller == null: 
		return
		
	var sim = ui.sim_controller
	
	is_ground_combat_btn.button_pressed = sim.is_ground_combat
	
	# 🎯 Fixed references to read cleanly directly out of local script tracker properties
	_select_dropdown_by_id(faction_select_attacker_btn, RANDOM_ID if attacker_is_random_faction else attacker_selected_faction_id)
	_select_dropdown_by_id(faction_select_defender_btn, RANDOM_ID if defender_is_random_faction else defender_selected_faction_id)
	_select_dropdown_by_id(stage_select_btn, RANDOM_ID if sim.is_random_stage else sim.debug_stage)
	
	_update_deck_drafting_interfaces()


func _on_attacker_selected(index: int) -> void:
	if ui == null or ui.sim_controller == null: 
		return
		
	var id = faction_select_attacker_btn.get_item_id(index)
	attacker_is_random_faction = (id == RANDOM_ID)
	
	# Flush previous custom deck choices to prevent cross-faction allocation bugs
	ui.sim_controller.custom_attacker_combat_deck.clear()
	
	# 🎯 Fixed: Assigns ID safely directly onto your newly declared UI variable tracker
	if id != RANDOM_ID:
		attacker_selected_faction_id = id
		
	_update_deck_drafting_interfaces()


func _on_defender_selected(index: int) -> void:
	if ui == null or ui.sim_controller == null: 
		return
		
	var id = faction_select_defender_btn.get_item_id(index)
	defender_is_random_faction = (id == RANDOM_ID)
	
	# Flush previous custom deck choices to prevent cross-faction allocation bugs
	ui.sim_controller.custom_defender_combat_deck.clear()
	
	# 🎯 Fixed: Assigns ID safely directly onto your newly declared UI variable tracker
	if id != RANDOM_ID:
		defender_selected_faction_id = id
		
	_update_deck_drafting_interfaces()


func _on_attacker_deck_toggle_changed(pressed: bool) -> void:
	if pressed and ui and ui.sim_controller:
		ui.sim_controller.custom_attacker_combat_deck.clear()
	_update_deck_drafting_interfaces()


func _on_defender_deck_toggle_changed(pressed: bool) -> void:
	if pressed and ui and ui.sim_controller:
		ui.sim_controller.custom_defender_combat_deck.clear()
	_update_deck_drafting_interfaces()


# ─── CARD LIST RE-BONDING & GENERATION INTERACTION ENGINE ───

func _populate_card_dropdown(dropdown: OptionButton, faction_id: int, active_deck: Array) -> void:
	dropdown.clear()
	dropdown.add_item("[ Clear Deck Selections ]", CLEAR_DECK_ID)
	
	var raw_factions = FactionRegistry.get_database()
	if not raw_factions.has(faction_id): 
		return
		
	var upgrade_pool: Array = raw_factions[faction_id].get("upgrade_deck", [])
	for card_id in upgrade_pool:
		var card_name: String = ui.sim_controller.get_card_metadata(card_id, "card_name")
		var count_in_deck = active_deck.count(card_id)
		dropdown.add_item("%s (Selected: %d)" % [card_name, count_in_deck], card_id)
		
	dropdown.text = "Draft Cards (%d/10)" % active_deck.size()


func _on_attacker_card_drafted(index: int) -> void:
	var id = cards_select_attacker_btn.get_item_id(index)
	var deck = ui.sim_controller.custom_attacker_combat_deck
	
	if id == CLEAR_DECK_ID: 
		deck.clear()
	elif deck.size() < 10: 
		deck.append(id)
		
	_update_deck_drafting_interfaces()


func _on_defender_card_drafted(index: int) -> void:
	var id = cards_select_defender_btn.get_item_id(index)
	var deck = ui.sim_controller.custom_defender_combat_deck
	
	if id == CLEAR_DECK_ID: 
		deck.clear()
	elif deck.size() < 10: 
		deck.append(id)
		
	_update_deck_drafting_interfaces()


# ─── MASTER LAYOUT GATEKEEPER & VALIDATION STATE RUNNER ───

func _update_deck_drafting_interfaces() -> void:
	if ui == null or ui.sim_controller == null: 
		return
		
	var sim = ui.sim_controller
	
	# ----------------------------------------------------
	# STEP 1: EVALUATE ATTACKER PANEL CONTROLS
	# ----------------------------------------------------
	if attacker_is_random_faction:
		attacker_uses_default_deck.button_pressed = true
		attacker_uses_default_deck.disabled = true
		cards_select_attacker_btn.disabled = true
		cards_select_attacker_btn.clear()
		cards_select_attacker_btn.text = "Random Deck"
		sim.custom_attacker_combat_deck.clear()
	else:
		attacker_uses_default_deck.disabled = false
		
		if attacker_uses_default_deck.button_pressed:
			cards_select_attacker_btn.disabled = true
			cards_select_attacker_btn.clear()
			cards_select_attacker_btn.text = "Standard Deck"
			sim.custom_attacker_combat_deck.clear()
		else:
			cards_select_attacker_btn.disabled = false
			# 🎯 Fixed reference to populate based on local tracker values instead of missing sim properties
			_populate_card_dropdown(
				cards_select_attacker_btn, 
				attacker_selected_faction_id, 
				sim.custom_attacker_combat_deck
			)

	# ----------------------------------------------------
	# STEP 2: EVALUATE DEFENDER PANEL CONTROLS
	# ----------------------------------------------------
	if defender_is_random_faction:
		defender_uses_default_deck.button_pressed = true
		defender_uses_default_deck.disabled = true
		cards_select_defender_btn.disabled = true
		cards_select_defender_btn.clear()
		cards_select_defender_btn.text = "Random Deck"
		sim.custom_defender_combat_deck.clear()
	else:
		defender_uses_default_deck.disabled = false
		
		if defender_uses_default_deck.button_pressed:
			cards_select_defender_btn.disabled = true
			cards_select_defender_btn.clear()
			cards_select_defender_btn.text = "Standard Deck"
			sim.custom_defender_combat_deck.clear()
		else:
			cards_select_defender_btn.disabled = false
			# 🎯 Fixed reference to populate based on local tracker values instead of missing sim properties
			_populate_card_dropdown(
				cards_select_defender_btn, 
				defender_selected_faction_id, 
				sim.custom_defender_combat_deck
			)

	# ----------------------------------------------------
	# STEP 3: RUN SECURITY TASKS
	# ----------------------------------------------------
	_enforce_no_mirror_options()
	_validate_execution_readiness()


func _enforce_no_mirror_options() -> void:
	var atk_selected_id: int = faction_select_attacker_btn.get_selected_id()
	var def_selected_id: int = faction_select_defender_btn.get_selected_id()
	
	# Reset all options to enabled first
	for i in range(faction_select_attacker_btn.item_count):
		faction_select_attacker_btn.set_item_disabled(i, false)
		faction_select_defender_btn.set_item_disabled(i, false)
		
	# Block the selected Attacker faction from being selected by the Defender
	if atk_selected_id != RANDOM_ID:
		for i in range(faction_select_defender_btn.item_count):
			if faction_select_defender_btn.get_item_id(i) == atk_selected_id:
				faction_select_defender_btn.set_item_disabled(i, true)
				
	# Block the selected Defender faction from being selected by the Attacker
	if def_selected_id != RANDOM_ID:
		for i in range(faction_select_attacker_btn.item_count):
			if faction_select_attacker_btn.get_item_id(i) == def_selected_id:
				faction_select_attacker_btn.set_item_disabled(i, true)


func _validate_execution_readiness() -> void:
	var sim = ui.sim_controller
	
	# Validate if Attacker has completely finished setting up their options
	var attacker_ready: bool = false
	if attacker_is_random_faction:
		attacker_ready = true
	elif attacker_uses_default_deck.button_pressed:
		attacker_ready = true
	elif sim.custom_attacker_combat_deck.size() == 10:
		attacker_ready = true
		
	# Validate if Defender has completely finished setting up their options
	var defender_ready: bool = false
	if defender_is_random_faction:
		defender_ready = true
	elif defender_uses_default_deck.button_pressed:
		defender_ready = true
	elif sim.custom_defender_combat_deck.size() == 10:
		defender_ready = true
	
	# Configure visual execution button warnings depending on readiness states
	if not attacker_ready:
		start_new_combat_btn.disabled = true
		start_new_combat_btn.text = "DRAFT 10 ATTACKER CARDS..."
	elif not defender_ready:
		start_new_combat_btn.disabled = true
		start_new_combat_btn.text = "DRAFT 10 DEFENDER CARDS..."
	else:
		start_new_combat_btn.disabled = false
		start_new_combat_btn.text = "START NEW COMBAT"


# ─── UTILITY FUNCTIONS ───

func _on_stage_selected(index: int) -> void:
	if ui == null or ui.sim_controller == null: 
		return
		
	var id = stage_select_btn.get_item_id(index)
	ui.sim_controller.is_random_stage = (id == RANDOM_ID)
	
	if id != RANDOM_ID:
		ui.sim_controller.debug_stage = id as GameStageGenerator.Stage


func _on_ground_combat_toggled(pressed: bool) -> void:
	if ui == null or ui.sim_controller == null: 
		return
	ui.sim_controller.is_ground_combat = pressed


func _select_dropdown_by_id(dropdown: OptionButton, target_id: int) -> void:
	var id_found: bool = false
	
	for i in range(dropdown.item_count):
		if dropdown.get_item_id(i) == target_id:
			dropdown.select(i)
			id_found = true
			break
			
	# Safety Fallback: If looking up an invalid state ID, default to item 0 safely
	if not id_found and dropdown.item_count > 0:
		dropdown.select(0)


# ─── LOCAL TEXT HEADER FORMATTERS ───

func update_headers() -> void:
	if ui == null or ui.sim_controller == null: 
		return
	update_game_stage_header(ui.sim_controller.current_stage)
	update_starting_cards_header(ui.sim_controller)
	update_combat_participants_header(ui.sim_controller)


func update_combat_participants_header(sim: SimController) -> void:
	if combat_participants_value == null: 
		return
	combat_participants_value.text = "%s vs %s" % [sim.attacker_faction_name, sim.defender_faction_name]


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


func update_game_stage_header(stage_val: GameStageGenerator.Stage) -> void:
	if game_stage_label == null: 
		return
		
	var stage_text := ""
	match stage_val:
		GameStageGenerator.Stage.EARLY: stage_text = "🪵 Early Conflict"
		GameStageGenerator.Stage.MID: stage_text = "⚙️ Mid-War Escalation"
		GameStageGenerator.Stage.LATE: stage_text = "🌋 Late-Stage Armageddon"
		_: stage_text = "❓ Unknown Stage"
		
	game_stage_label.text = stage_text
