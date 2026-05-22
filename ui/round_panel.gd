extends PanelContainer
class_name CombatRoundPanel

@onready var att_combat_round_value: Label = $Round1BoxMargin/Round1Layout/AttackerCombatView/RoundStartStats/Layout/HeaderPanel/Layout/RoundStartHeaderPanel/CombatRoundTextLayout/CombatRoundValue
@onready var att_faction_name_value: Label = $Round1BoxMargin/Round1Layout/AttackerCombatView/RoundStartStats/Layout/HeaderPanel/Layout/FactionName/Layout/FactionNameValue
@onready var att_units_unrouted_value: VBoxContainer = $Round1BoxMargin/Round1Layout/AttackerCombatView/RoundStartStats/Layout/UnitList/Layout/UnitsUnroutedValue
@onready var att_units_routed_value: VBoxContainer = $Round1BoxMargin/Round1Layout/AttackerCombatView/RoundStartStats/Layout/UnitList/Layout/UnitsRoutedValue
@onready var att_base_dice_rolls_value: Label = $Round1BoxMargin/Round1Layout/AttackerCombatView/RoundStartStats/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var att_morale_from_units_value: Label = $Round1BoxMargin/Round1Layout/AttackerCombatView/RoundStartStats/Layout/MoraleFromUnitsPanel/Layout/MoraleFromUnitsValue
@onready var att_cards_played_images: HBoxContainer = $Round1BoxMargin/Round1Layout/AttackerCombatView/RoundStartStats/Layout/CardsPlayed/CardsPlayedImages
@onready var att_assess_damage_step_units_unrouted_value: VBoxContainer = $Round1BoxMargin/Round1Layout/AttackerCombatView/AssessDamageStepStart/Layout/UnitList/Layout/UnitsUnroutedValue
@onready var att_assess_damage_step_units_routed_value: VBoxContainer = $Round1BoxMargin/Round1Layout/AttackerCombatView/AssessDamageStepStart/Layout/UnitList/Layout/UnitsRoutedValue
@onready var att_assess_damage_step_base_dice_rolls_value: Label = $Round1BoxMargin/Round1Layout/AttackerCombatView/AssessDamageStepStart/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var att_console_log_value: Label = $Round1BoxMargin/Round1Layout/AttackerCombatView/AssessDamageStepStart/Layout/ConsoleLog/Layout/ConsoleLogValue

@onready var def_combat_round_value: Label = $Round1BoxMargin/Round1Layout/DefenderCombatView/RoundStartStats/Layout/HeaderPanel/Layout/RoundStartHeaderPanel/CombatRoundTextLayout/CombatRoundValue
@onready var def_faction_name_value: Label = $Round1BoxMargin/Round1Layout/DefenderCombatView/RoundStartStats/Layout/HeaderPanel/Layout/FactionName/Layout/FactionNameValue
@onready var def_units_unrouted_value: VBoxContainer = $Round1BoxMargin/Round1Layout/DefenderCombatView/RoundStartStats/Layout/UnitList/Layout/UnitsUnroutedValue
@onready var def_units_routed_value: VBoxContainer = $Round1BoxMargin/Round1Layout/DefenderCombatView/RoundStartStats/Layout/UnitList/Layout/UnitsRoutedValue
@onready var def_base_dice_rolls_value: Label = $Round1BoxMargin/Round1Layout/DefenderCombatView/RoundStartStats/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var def_morale_from_units_value: Label = $Round1BoxMargin/Round1Layout/DefenderCombatView/RoundStartStats/Layout/MoraleFromUnitsPanel/Layout/MoraleFromUnitsValue
@onready var def_cards_played_images: HBoxContainer = $Round1BoxMargin/Round1Layout/DefenderCombatView/RoundStartStats/Layout/CardsPlayed/CardsPlayedImages
@onready var def_assess_damage_step_units_unrouted_value: VBoxContainer = $Round1BoxMargin/Round1Layout/DefenderCombatView/AssessDamageStepStart/Layout/UnitList/Layout/UnitsUnroutedValue
@onready var def_assess_damage_step_units_routed_value: VBoxContainer = $Round1BoxMargin/Round1Layout/DefenderCombatView/AssessDamageStepStart/Layout/UnitList/Layout/UnitsRoutedValue
@onready var def_assess_damage_step_base_dice_rolls_value: Label = $Round1BoxMargin/Round1Layout/DefenderCombatView/AssessDamageStepStart/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var def_console_log_value: Label = $Round1BoxMargin/Round1Layout/DefenderCombatView/AssessDamageStepStart/Layout/ConsoleLog/Layout/ConsoleLogValue

func set_round_header_labels(round_num: int) -> void:
	att_combat_round_value.text = "ROUND %d" % round_num
	def_combat_round_value.text = "ROUND %d" % round_num

func set_dice_pools(role: String, offence: int, defence: int, total_morale: int) -> void:
	if role == "Attacker":
		att_base_dice_rolls_value.text = "%d ⚔️ | %d 🛡️" % [offence, defence]
		att_morale_from_units_value.text = str(total_morale)
	else:
		def_base_dice_rolls_value.text = "%d ⚔️ | %d 🛡️" % [offence, defence]
		def_morale_from_units_value.text = str(total_morale)

func set_unit_statuses(role: String, unrouted_str: String, routed_str: String) -> void:
	var is_attacker := (role == "Attacker")
	var unrouted_vbox: VBoxContainer = att_units_unrouted_value if is_attacker else def_units_unrouted_value
	var routed_vbox: VBoxContainer = att_units_routed_value if is_attacker else def_units_routed_value
	
	_rebuild_vbox_labels(unrouted_vbox, unrouted_str)
	_rebuild_vbox_labels(routed_vbox, routed_str)

func set_damage_assessment_pools(damage_to_def: int, damage_to_atk: int) -> void:
	att_assess_damage_step_base_dice_rolls_value.text = "Dealing: %d 💥" % damage_to_def
	def_assess_damage_step_base_dice_rolls_value.text = "Dealing: %d 💥" % damage_to_atk

func append_console_log(message: String) -> void:
	att_console_log_value.text += message + "\n"
	def_console_log_value.text += message + "\n"

func _rebuild_vbox_labels(container: VBoxContainer, names_csv: String) -> void:
	for child in container.get_children():
		child.queue_free()
	
	var names_list = names_csv.split(", ")
	for entity_name in names_list:
		if entity_name == "None" or entity_name.is_empty():
			continue
		var label := Label.new()
		label.text = entity_name
		container.add_child(label)
