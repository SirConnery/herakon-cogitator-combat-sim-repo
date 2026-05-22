extends PanelContainer
class_name CombatRoundPanel

#region vars
@onready var att_combat_round_value: Label = $CombatRoundMargin/RoundLayout/AttackerCombatView/RoundStartStats/Layout/HeaderPanel/Layout/RoundStartHeaderPanel/CombatRoundTextLayout/CombatRoundValue
@onready var att_faction_name_value: Label = $CombatRoundMargin/RoundLayout/AttackerCombatView/RoundStartStats/Layout/HeaderPanel/Layout/FactionName/Layout/FactionNameValue
@onready var att_units_unrouted_value: VBoxContainer = $CombatRoundMargin/RoundLayout/AttackerCombatView/RoundStartStats/Layout/UnitsUnrouted/Layout/UnitsUnroutedValue
@onready var att_units_routed_value: VBoxContainer = $CombatRoundMargin/RoundLayout/AttackerCombatView/RoundStartStats/Layout/UnitsRouted/Layout/UnitsRoutedValue
@onready var att_base_dice_rolls_value: Label = $CombatRoundMargin/RoundLayout/AttackerCombatView/RoundStartStats/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var att_tokens_value: Label = $CombatRoundMargin/RoundLayout/AttackerCombatView/RoundStartStats/Layout/Tokens/Layout/TokensValue
@onready var att_morale_from_units_value: Label = $CombatRoundMargin/RoundLayout/AttackerCombatView/RoundStartStats/Layout/MoraleFromUnitsPanel/Layout/MoraleFromUnitsValue
@onready var att_cards_played_images: HBoxContainer = $CombatRoundMargin/RoundLayout/AttackerCombatView/RoundStartStats/Layout/CardsPlayed/CardsPlayedImages
@onready var att_assess_damage_step_units_unrouted_value: VBoxContainer = $CombatRoundMargin/RoundLayout/AttackerCombatView/AssessDamageStep/Layout/UnitsUnrouted/Layout/UnitsUnroutedValue
@onready var att_assess_damage_step_units_routed_value: VBoxContainer = $CombatRoundMargin/RoundLayout/AttackerCombatView/AssessDamageStep/Layout/UnitsRouted/Layout/UnitsRoutedValue
@onready var att_assess_damage_step_base_dice_rolls_value: Label = $CombatRoundMargin/RoundLayout/AttackerCombatView/AssessDamageStep/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var att_assess_damage_step_tokens_value: Label = $CombatRoundMargin/RoundLayout/AttackerCombatView/AssessDamageStep/Layout/Tokens/Layout/TokensValue
@onready var att_assess_damage_step_morale_from_units_value: Label = $CombatRoundMargin/RoundLayout/AttackerCombatView/AssessDamageStep/Layout/MoraleFromUnitsPanel/Layout/MoraleFromUnitsValue
@onready var att_assess_damage_step_cards_played_images: HBoxContainer = $CombatRoundMargin/RoundLayout/AttackerCombatView/AssessDamageStep/Layout/CardsPlayed/CardsPlayedImages
@onready var att_damage_suffered_value: Label = $CombatRoundMargin/RoundLayout/AttackerCombatView/AssessDamageStep/Layout/DamageDealt/Layout/DamageSufferedValue
@onready var att_console_log_value: Label = $CombatRoundMargin/RoundLayout/AttackerCombatView/AssessDamageStep/Layout/ConsoleLog/Layout/ScrollContainer/ConsoleLogValue


@onready var def_combat_round_value: Label = $CombatRoundMargin/RoundLayout/DefenderCombatView/RoundStartStats/Layout/HeaderPanel/Layout/RoundStartHeaderPanel/CombatRoundTextLayout/CombatRoundValue
@onready var def_faction_name_value: Label = $CombatRoundMargin/RoundLayout/DefenderCombatView/RoundStartStats/Layout/HeaderPanel/Layout/FactionName/Layout/FactionNameValue
@onready var def_units_unrouted_value: VBoxContainer = $CombatRoundMargin/RoundLayout/DefenderCombatView/RoundStartStats/Layout/UnitsUnrouted/Layout/UnitsUnroutedValue
@onready var def_units_routed_value: VBoxContainer = $CombatRoundMargin/RoundLayout/DefenderCombatView/RoundStartStats/Layout/UnitsRouted/Layout/UnitsRoutedValue
@onready var def_base_dice_rolls_value: Label = $CombatRoundMargin/RoundLayout/DefenderCombatView/RoundStartStats/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var def_tokens_value: Label = $CombatRoundMargin/RoundLayout/DefenderCombatView/RoundStartStats/Layout/Tokens/Layout/TokensValue
@onready var def_morale_from_units_value: Label = $CombatRoundMargin/RoundLayout/DefenderCombatView/RoundStartStats/Layout/MoraleFromUnitsPanel/Layout/MoraleFromUnitsValue
@onready var def_cards_played_images: HBoxContainer = $CombatRoundMargin/RoundLayout/DefenderCombatView/RoundStartStats/Layout/CardsPlayed/CardsPlayedImages
@onready var def_assess_damage_step_units_unrouted_value: VBoxContainer = $CombatRoundMargin/RoundLayout/DefenderCombatView/AssessDamageStep/Layout/UnitsUnrouted/Layout/UnitsUnroutedValue
@onready var def_assess_damage_step_units_routed_value: VBoxContainer = $CombatRoundMargin/RoundLayout/DefenderCombatView/AssessDamageStep/Layout/UnitsRouted/Layout/UnitsRoutedValue
@onready var def_assess_damage_step_base_dice_rolls_value: Label = $CombatRoundMargin/RoundLayout/DefenderCombatView/AssessDamageStep/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var def_assess_damage_step_tokens_value: Label = $CombatRoundMargin/RoundLayout/DefenderCombatView/AssessDamageStep/Layout/Tokens/Layout/TokensValue
@onready var def_assess_damage_step_morale_from_units_value: Label = $CombatRoundMargin/RoundLayout/DefenderCombatView/AssessDamageStep/Layout/MoraleFromUnitsPanel/Layout/MoraleFromUnitsValue
@onready var def_assess_damage_step_cards_played_images: HBoxContainer = $CombatRoundMargin/RoundLayout/DefenderCombatView/AssessDamageStep/Layout/CardsPlayed/CardsPlayedImages
@onready var def_damage_suffered_value: Label = $CombatRoundMargin/RoundLayout/DefenderCombatView/AssessDamageStep/Layout/DamageDealt/Layout/DamageSufferedValue
@onready var def_console_log_value: Label = $CombatRoundMargin/RoundLayout/DefenderCombatView/AssessDamageStep/Layout/ConsoleLog/Layout/ScrollContainer/ConsoleLogValue

#endregion

#region Basic Setters

func set_round_header_labels(round_num: int) -> void:
	att_combat_round_value.text = " %d" % round_num
	def_combat_round_value.text = " %d" % round_num


func set_faction_titles(attacker_name: String, defender_name: String) -> void:
	att_faction_name_value.text = "ATTACKER: \n %s" % attacker_name
	def_faction_name_value.text = "DEFENDER: \n %s" % defender_name

func set_dice_pools(role: String, offence: int, defence: int, morale_dice: int) -> void:
	if role == "Attacker":
		att_base_dice_rolls_value.text = "%d ⚔️ \n %d 🛡️ \n %d 🦅" % [offence, defence, morale_dice]
	else:
		def_base_dice_rolls_value.text = "%d ⚔️ \n %d 🛡️ \n %d 🦅" % [offence, defence, morale_dice]


func set_damage_assessment_pools(role: String,damage: int) -> void:
	if role == "Attacker":
		att_damage_suffered_value.text = "%d 💥" % damage
	else:
		def_damage_suffered_value.text = "%d 💥" % damage


func append_console_log(message: String) -> void:
	att_console_log_value.text += message + "\n"
	def_console_log_value.text += message + "\n"

#endregion


#region Round Start Unit Snapshot

func set_round_start_unit_statuses(
	role: String,
	unrouted_str: String,
	routed_str: String
) -> void:

	var is_attacker := (role == "Attacker")

	var unrouted_vbox: VBoxContainer = (
		att_units_unrouted_value
		if is_attacker
		else def_units_unrouted_value
	)

	var routed_vbox: VBoxContainer = (
		att_units_routed_value
		if is_attacker
		else def_units_routed_value
	)

	_rebuild_vbox_labels(unrouted_vbox, unrouted_str)
	_rebuild_vbox_labels(routed_vbox, routed_str)

#endregion


#region Assess Damage Snapshot

func set_assess_damage_unit_statuses(
	role: String,
	unrouted_str: String,
	routed_str: String
) -> void:

	var is_attacker := (role == "Attacker")

	var unrouted_vbox: VBoxContainer = (
		att_assess_damage_step_units_unrouted_value
		if is_attacker
		else def_assess_damage_step_units_unrouted_value
	)

	var routed_vbox: VBoxContainer = (
		att_assess_damage_step_units_routed_value
		if is_attacker
		else def_assess_damage_step_units_routed_value
	)

	_rebuild_vbox_labels(unrouted_vbox, unrouted_str)
	_rebuild_vbox_labels(routed_vbox, routed_str)

#endregion


#region Internal Helpers

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

#endregion
