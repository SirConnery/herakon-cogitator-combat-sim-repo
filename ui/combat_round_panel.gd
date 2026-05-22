extends PanelContainer
class_name CombatRoundPanel

#region vars

@onready var console_log_value: Label = $CombatRoundMargin/RoundContentContainer/ConsoleLog/Layout/ScrollContainer/ConsoleLogValue

@onready var att_combat_round_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/HeaderPanel/Layout/RoundStartHeaderPanel/CombatRoundTextLayout/CombatRoundValue
@onready var att_faction_name_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/HeaderPanel/Layout/FactionName/Layout/FactionNameValue
@onready var att_units_unrouted_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/UnitsUnrouted/Layout/UnitsUnroutedValue
@onready var att_units_routed_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/UnitsRouted/Layout/UnitsRoutedValue
@onready var att_base_dice_rolls_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var att_tokens_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/Tokens/Layout/TokensValue
@onready var att_morale_from_units_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/MoraleFromUnitsPanel/Layout/MoraleFromUnitsValue
@onready var att_cards_played_images: HBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/CardsPlayed/CardsPlayedImages
@onready var att_assess_damage_step_units_unrouted_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/AssessDamageStep/Layout/UnitsUnrouted/Layout/UnitsUnroutedValue
@onready var att_assess_damage_step_units_routed_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/AssessDamageStep/Layout/UnitsRouted/Layout/UnitsRoutedValue
@onready var att_assess_damage_step_base_dice_rolls_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/AssessDamageStep/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var att_assess_damage_step_tokens_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/AssessDamageStep/Layout/Tokens/Layout/TokensValue
@onready var att_assess_damage_step_morale_from_units_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/AssessDamageStep/Layout/MoraleFromUnitsPanel/Layout/MoraleFromUnitsValue
@onready var att_assess_damage_step_cards_played_images: HBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/AssessDamageStep/Layout/CardsPlayed/CardsPlayedImages
@onready var att_damage_suffered_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/AssessDamageStep/Layout/DamageDealt/Layout/DamageSufferedValue

@onready var def_combat_round_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/HeaderPanel/Layout/RoundStartHeaderPanel/CombatRoundTextLayout/CombatRoundValue
@onready var def_faction_name_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/HeaderPanel/Layout/FactionName/Layout/FactionNameValue
@onready var def_units_unrouted_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/UnitsUnrouted/Layout/UnitsUnroutedValue
@onready var def_units_routed_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/UnitsRouted/Layout/UnitsRoutedValue
@onready var def_base_dice_rolls_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var def_tokens_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/Tokens/Layout/TokensValue
@onready var def_morale_from_units_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/MoraleFromUnitsPanel/Layout/MoraleFromUnitsValue
@onready var def_cards_played_images: HBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/CardsPlayed/CardsPlayedImages
@onready var def_assess_damage_step_units_unrouted_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/AssessDamageStep/Layout/UnitsUnrouted/Layout/UnitsUnroutedValue
@onready var def_assess_damage_step_units_routed_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/AssessDamageStep/Layout/UnitsRouted/Layout/UnitsRoutedValue
@onready var def_assess_damage_step_base_dice_rolls_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/AssessDamageStep/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var def_assess_damage_step_tokens_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/AssessDamageStep/Layout/Tokens/Layout/TokensValue
@onready var def_assess_damage_step_morale_from_units_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/AssessDamageStep/Layout/MoraleFromUnitsPanel/Layout/MoraleFromUnitsValue
@onready var def_assess_damage_step_cards_played_images: HBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/AssessDamageStep/Layout/CardsPlayed/CardsPlayedImages
@onready var def_damage_suffered_value: Label = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/AssessDamageStep/Layout/DamageDealt/Layout/DamageSufferedValue

#endregion

#region Basic Setters

func set_round_header_labels(round_num: int) -> void:
	att_combat_round_value.text = " %d" % round_num
	def_combat_round_value.text = " %d" % round_num

func set_faction_titles(attacker_name: String, defender_name: String) -> void:
	att_faction_name_value.text = "ATTACKER: \n %s" % attacker_name
	def_faction_name_value.text = "DEFENDER: \n %s" % defender_name

func update_dice_displays(is_attacker: bool, offence: int, defence: int, morale_dice: int, target_phase: String = "all") -> void:
	var dice_string := "%d ⚔️ \n %d 🛡️ \n %d 🎖️" % [offence, defence, morale_dice]
	
	# 1. Update Starting Layout
	if target_phase == "all" or target_phase == "round_start":
		var target_label: Label = att_base_dice_rolls_value if is_attacker else def_base_dice_rolls_value
		target_label.text = dice_string

	# 2. Update Damage Assessment Snapshot Layout
	if target_phase == "all" or target_phase == "damage_step":
		var target_assess_label: Label = att_assess_damage_step_base_dice_rolls_value if is_attacker else def_assess_damage_step_base_dice_rolls_value
		if target_assess_label != null:
			target_assess_label.text = dice_string

func set_unit_morale(role: String, morale_value: int) -> void:
	if role == "Attacker":
		att_morale_from_units_value.text = str(morale_value) + " 🎖️"
	else:
		def_morale_from_units_value.text = str(morale_value) + " 🎖️"

func set_damage_assessment_pools(role: String,damage: int) -> void:
	if role == "Attacker":
		att_damage_suffered_value.text = "%d 💥" % damage
	else:
		def_damage_suffered_value.text = "%d 💥" % damage

func set_tokens(role: String, offence_tokens: int, defence_tokens: int) -> void:
	var token_string := "+%d ⚔️ | +%d 🛡️" % [offence_tokens, defence_tokens]
	
	if role == "Attacker":
		att_tokens_value.text = token_string
		if "att_assess_damage_step_tokens_value" in self and att_assess_damage_step_tokens_value != null:
			att_assess_damage_step_tokens_value.text = token_string
	else:
		def_tokens_value.text = token_string
		if "def_assess_damage_step_tokens_value" in self and def_assess_damage_step_tokens_value != null:
			def_assess_damage_step_tokens_value.text = token_string

func append_console_log(message: String) -> void:
	console_log_value.text += message + "\n"

#endregion


#region Round Start Unit Snapshot

func update_unit_displays(is_attacker: bool, unrouted_csv: String, routed_csv: String, target_phase: String = "all") -> void:
	# 1. Update Starting Layout (Fires on general ticks or explicit round entry calls)
	if target_phase == "all" or target_phase == "round_start":
		var unrouted_vbox: VBoxContainer = att_units_unrouted_value if is_attacker else def_units_unrouted_value
		var routed_vbox: VBoxContainer = att_units_routed_value if is_attacker else def_units_routed_value
		_rebuild_vbox_labels(unrouted_vbox, unrouted_csv)
		_rebuild_vbox_labels(routed_vbox, routed_csv)

	# 2. Update Damage Assessment Snapshot Layout (Fires on general ticks or explicit phase entry calls)
	if target_phase == "all" or target_phase == "damage_step":
		var unrouted_assess_vbox: VBoxContainer = att_assess_damage_step_units_unrouted_value if is_attacker else def_assess_damage_step_units_unrouted_value
		var routed_assess_vbox: VBoxContainer = att_assess_damage_step_units_routed_value if is_attacker else def_assess_damage_step_units_routed_value
		_rebuild_vbox_labels(unrouted_assess_vbox, unrouted_csv)
		_rebuild_vbox_labels(routed_assess_vbox, routed_csv)

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
