extends Control
class_name CombatDebuggerUI

# --- Global Layout Pointers ---
@onready var participants_label: Label = $MainLayout/HeaderPanel/CombatParticipantsLabel
@onready var navigation_row: HBoxContainer = $MainLayout/RoundNavigationRow
@onready var round_label: Label = $MainLayout/RoundNavigationRow/ActiveRoundLabel
@onready var prev_button: Button = $MainLayout/RoundNavigationRow/PrevRoundButton
@onready var next_button: Button = $MainLayout/RoundNavigationRow/NextRoundButton

# --- Symmetric Column Pointers ---
@onready var atk_view: VBoxContainer = $MainLayout/CentralCombatView/AttackerCombatView
@onready var def_view: VBoxContainer = $MainLayout/CentralCombatView/DefenderCombatView

# --- State Buffer ---
var cached_match_data: Dictionary = {}
var current_viewed_round_index: int = 0


func _ready() -> void:
	# Safely wire navigation buttons if they exist in your scene layout
	if prev_button: prev_button.pressed.connect(_on_prev_pressed)
	if next_button: next_button.pressed.connect(_on_next_pressed)


## Call this from your simulation controller to bind raw data structures to the visual panels
func load_battle_snapshots(match_history_profile: Dictionary) -> void:
	cached_match_data = match_history_profile
	current_viewed_round_index = 0
	
	# Set up global participants header
	if participants_label:
		participants_label.text = "%s   VS   %s   [%s Scale]" % [
			cached_match_data["attacker_name"],
			cached_match_data["defender_name"],
			cached_match_data.get("scale_string", "Standard")
		]
		
	_refresh_active_round_ui()


func _refresh_active_round_ui() -> void:
	var rounds_array: Array = cached_match_data.get("rounds", [])
	var total_available_rounds: int = rounds_array.size()
	
	if total_available_rounds == 0:
		return
		
	# Update active navigation readouts
	if round_label:
		round_label.text = "ROUND %d / %d" % [current_viewed_round_index + 1, total_available_rounds]
	if prev_button:
		prev_button.disabled = (current_viewed_round_index == 0)
	if next_button:
		next_button.disabled = (current_viewed_round_index >= total_available_rounds - 1)
		
	var r_data: Dictionary = rounds_array[current_viewed_round_index]
	
	# ==========================================================================
	# ⚔️ UPDATE ATTACKER SIDE (LEFT)
	# ==========================================================================
	atk_view.get_node("Header/FactionName").text = cached_match_data["attacker_name"]
	atk_view.get_node("UnitList/Units").text = r_data["atk_board_string"]
	
	# Dice Pools
	atk_view.get_node("DicePanel/HBoxContainer/BaseDiceRolls").text = "Base: ⚔️ %d | 🛡️ %d | 🦅 %d" % [
		r_data.get("atk_base_offense", 0), r_data.get("atk_base_defense", 0), r_data.get("atk_base_morale", 0)
	]
	atk_view.get_node("DicePanel/HBoxContainer/MoraleFromUnits").text = "Unit 🦅: +%d" % r_data.get("atk_unit_morale", 0)
	
	# Card Data (Assuming CardsPlayedImages holds a child label or texture helper)
	# Adjust node lookup path if you have a nested Title label inside the container
	if atk_view.has_node("CardsPlayed/CardsPlayedImages/CardName"):
		atk_view.get_node("CardsPlayed/CardsPlayedImages/CardName").text = r_data["atk_card_name"]
	
	# Event Trace Stream
	var atk_log: RichTextLabel = atk_view.get_node("ConsoleWindow/ConsoleLog")
	atk_log.clear()
	atk_log.append_text(r_data.get("atk_ability_logs_stream", ""))
	
	# Total Resolution Outputs
	atk_view.get_node("FinalPools/FinalPoolsLabel").text = "TOTALS: ⚔️ %d | 🛡️ %d | 🦅 %d\nSUFFERED IMPACT: -%d HP" % [
		r_data["atk_offense"], r_data["atk_defense"], r_data["atk_morale"], r_data["damage_to_atk"]
	]
	
	# ==========================================================================
	# 🛡️ UPDATE DEFENDER SIDE (RIGHT)
	# ==========================================================================
	def_view.get_node("Header/FactionName").text = cached_match_data["defender_name"]
	def_view.get_node("UnitList/Units").text = r_data["def_board_string"]
	
	# Dice Pools
	def_view.get_node("DicePanel/HBoxContainer/BaseDiceRolls").text = "Base: ⚔️ %d | 🛡️ %d | 🦅 %d" % [
		r_data.get("def_base_offense", 0), r_data.get("def_base_defense", 0), r_data.get("def_base_morale", 0)
	]
	def_view.get_node("DicePanel/HBoxContainer/MoraleFromUnits").text = "Unit 🦅: +%d" % r_data.get("def_unit_morale", 0)
	
	# Card Data
	if def_view.has_node("CardsPlayed/CardsPlayedImages/CardName"):
		def_view.get_node("CardsPlayed/CardsPlayedImages/CardName").text = r_data["def_card_name"]
		
	# Event Trace Stream
	var def_log: RichTextLabel = def_view.get_node("ConsoleWindow/ConsoleLog")
	def_log.clear()
	def_log.append_text(r_data.get("def_ability_logs_stream", ""))
	
	# Total Resolution Outputs
	def_view.get_node("FinalPools/FinalPoolsLabel").text = "TOTALS: ⚔️ %d | 🛡️ %d | 🦅 %d\nSUFFERED IMPACT: -%d HP" % [
		r_data["def_offense"], r_data["def_defense"], r_data["def_morale"], r_data["damage_to_def"]
	]


func _on_prev_pressed() -> void:
	if current_viewed_round_index > 0:
		current_viewed_round_index -= 1
		_refresh_active_round_ui()


func _on_next_pressed() -> void:
	if current_viewed_round_index < cached_match_data["rounds"].size() - 1:
		current_viewed_round_index += 1
		_refresh_active_round_ui()
