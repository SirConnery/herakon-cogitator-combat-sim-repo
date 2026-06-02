extends PanelContainer
class_name CombatRoundPanel

const ARROWS_COUNTERCLOCKWISE = preload("uid://865pnryo3ujp")
const BOOM = preload("uid://bb86pf3ujv2ll")
const BRAIN = preload("uid://cib2wu76oigcs")
const CARD_INDEX = preload("uid://cgj0u2io8yxbh")
const CHECKERED_FLAG = preload("uid://cgqk18tlfu8ki")
const COIN = preload("uid://cruigmoxlb8r0")
const CROSSED_SWORDS = preload("uid://bdhga5ctungo4")
const FLOWER_PLAYING_CARDS = preload("uid://fsarkovhf8ll")
const GAME_DIE = preload("uid://b51b7ogv3v08x")
const GUARD = preload("uid://c7y0855sdtlee")
const LARGE_BLUE_SQUARE = preload("uid://c3mh1p2tbkpbn")
const LARGE_RED_SQUARE = preload("uid://cqy2rgwfkk0k0")
const MEDAL = preload("uid://cq63x40y4n0ki")
const SHIELD = preload("uid://bnr4nvio4fy5f")
const SKULL = preload("uid://bbthodxg0r8d2")
const WARNING = preload("uid://eoi5qeurd3od")
const WAVING_WHITE_FLAG = preload("uid://cdxydf02sdra5")


# INLINE BBCODE TEXTURE PATH STRINGS
@onready var IMG_SWORD: String = "[img=22]" + CROSSED_SWORDS.get_path() + "[/img]"
@onready var IMG_SHIELD: String = "[img=22]" + SHIELD.get_path() + "[/img]"
@onready var IMG_MEDAL: String = "[img=22]" + MEDAL.get_path() + "[/img]"
@onready var IMG_BOOM: String = "[img=22]" + BOOM.get_path() + "[/img]"


const UNIT_LABEL := preload("res://ui/single_combat_view/UnitLabel.tscn")


#region vars

@onready var console_log_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/ConsoleLog/Layout/ScrollContainer/ConsoleLogValue

@onready var att_combat_round_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/HeaderPanel/Layout/RoundStartHeaderPanel/CombatRoundTextLayout/CombatRoundValue
@onready var att_faction_name_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/HeaderPanel/Layout/FactionName/Layout/FactionNameValue
@onready var att_units_unrouted_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/UnitsUnrouted/Layout/UnitsUnroutedValue
@onready var att_units_routed_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/UnitsRouted/Layout/UnitsRoutedValue
@onready var att_icons_from_cards_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/CardsPanel/Layout/IconsFromCardsValue
@onready var att_base_dice_rolls_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var att_tokens_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/Tokens/Layout/TokensValue
@onready var att_morale_from_units_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/MoraleFromUnitsPanel/Layout/MoraleFromUnitsValue
@onready var att_cards_played_images: HBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/RoundStartStats/Layout/CardsPlayed/CardsPlayedImages
@onready var att_assess_damage_step_units_unrouted_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/AssessDamageStep/Layout/UnitsUnrouted/Layout/UnitsUnroutedValue
@onready var att_assess_damage_step_units_routed_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/AssessDamageStep/Layout/UnitsRouted/Layout/UnitsRoutedValue
@onready var att_assess_damage_step_icons_from_cards_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/AssessDamageStep/Layout/CardsPanel/Layout/IconsFromCardsValue
@onready var att_assess_damage_step_base_dice_rolls_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/AssessDamageStep/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var att_assess_damage_step_tokens_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/AssessDamageStep/Layout/Tokens/Layout/TokensValue
@onready var att_assess_damage_step_extra_icons_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/AssessDamageStep/Layout/ExtraIcons/Layout/ExtraIconsValue
@onready var att_assess_damage_step_morale_from_units_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/AssessDamageStep/Layout/MoraleFromUnitsPanel/Layout/MoraleFromUnitsValue
@onready var att_damage_suffered_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/AttackerCombatView/AssessDamageStep/Layout/DamageDealt/Layout/DamageSufferedValue

@onready var def_combat_round_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/HeaderPanel/Layout/RoundStartHeaderPanel/CombatRoundTextLayout/CombatRoundValue
@onready var def_faction_name_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/HeaderPanel/Layout/FactionName/Layout/FactionNameValue
@onready var def_units_unrouted_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/UnitsUnrouted/Layout/UnitsUnroutedValue
@onready var def_units_routed_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/UnitsRouted/Layout/UnitsRoutedValue
@onready var def_icons_from_cards_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/CardsPanel/Layout/IconsFromCardsValue
@onready var def_base_dice_rolls_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var def_tokens_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/Tokens/Layout/TokensValue
@onready var def_morale_from_units_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/MoraleFromUnitsPanel/Layout/MoraleFromUnitsValue
@onready var def_cards_played_images: HBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/RoundStartStats/Layout/CardsPlayed/CardsPlayedImages
@onready var def_assess_damage_step_units_unrouted_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/AssessDamageStep/Layout/UnitsUnrouted/Layout/UnitsUnroutedValue
@onready var def_assess_damage_step_units_routed_value: VBoxContainer = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/AssessDamageStep/Layout/UnitsRouted/Layout/UnitsRoutedValue
@onready var def_assess_damage_step_icons_from_cards_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/AssessDamageStep/Layout/CardsPanel/Layout/IconsFromCardsValue
@onready var def_assess_damage_step_base_dice_rolls_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/AssessDamageStep/Layout/DicePanel/Layout/BaseDiceRollsValue
@onready var def_assess_damage_step_tokens_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/AssessDamageStep/Layout/Tokens/Layout/TokensValue
@onready var def_assess_damage_step_extra_icons_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/AssessDamageStep/Layout/ExtraIcons/Layout/ExtraIconsValue
@onready var def_assess_damage_step_morale_from_units_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/AssessDamageStep/Layout/MoraleFromUnitsPanel/Layout/MoraleFromUnitsValue
@onready var def_damage_suffered_value: RichTextLabel = $CombatRoundMargin/RoundContentContainer/RivalStatsColumn/DefenderCombatView/AssessDamageStep/Layout/DamageDealt/Layout/DamageSufferedValue

#endregion

#region Basic Setters

func set_round_header_labels(round_num: int) -> void:
	att_combat_round_value.text = " %d" % round_num
	def_combat_round_value.text = " %d" % round_num

func set_faction_titles(attacker_name: String, defender_name: String) -> void:
	att_faction_name_value.text = "ATTACKER: \n %s" % attacker_name
	def_faction_name_value.text = "DEFENDER: \n %s" % defender_name

func update_dice_displays(is_attacker: bool, offence: int, defence: int, morale_dice: int, target_phase: String = "all") -> void:
	var dice_string := "%d %s \n %d %s \n %d %s" % [offence, IMG_SWORD, defence, IMG_SHIELD, morale_dice, IMG_MEDAL]
	
	# 1. Update Starting Layout
	if target_phase == "all" or target_phase == "round_start":
		var target_label: RichTextLabel = att_base_dice_rolls_value if is_attacker else def_base_dice_rolls_value
		target_label.text = dice_string

	# 2. Update Damage Assessment Snapshot Layout
	if target_phase == "all" or target_phase == "damage_step":
		var target_assess_label: RichTextLabel = att_assess_damage_step_base_dice_rolls_value if is_attacker else def_assess_damage_step_base_dice_rolls_value
		if target_assess_label != null:
			target_assess_label.text = dice_string

func set_unit_morale(role: String, morale_value: int, target_phase: String = "all") -> void:
	var is_attacker := (role == "Attacker")
	var morale_string := "0" if morale_value == 0 else str(morale_value) + " " + IMG_MEDAL
	
	# 1. Update Starting Layout Snapshot
	if target_phase == "all" or target_phase == "round_start":
		var target_label: RichTextLabel = att_morale_from_units_value if is_attacker else def_morale_from_units_value
		if target_label != null:
			target_label.text = morale_string

	# 2. Update Damage Assess Step Layout
	if target_phase == "all" or target_phase == "damage_step":
		var target_assess_label: RichTextLabel = att_assess_damage_step_morale_from_units_value if is_attacker else def_assess_damage_step_morale_from_units_value
		if target_assess_label != null:
			target_assess_label.text = morale_string

func set_damage_assessment_pools(role: String, damage: int) -> void:
	if role == "Attacker":
		att_damage_suffered_value.text = "%d %s" % [damage, IMG_BOOM]
	else:
		def_damage_suffered_value.text = "%d %s" % [damage, IMG_BOOM]

func update_card_icons_displays(is_attacker: bool, offence: int, defence: int, morale: int, target_phase: String = "all") -> void:
	var icon_string := "0" if (offence == 0 and defence == 0 and morale == 0) else "%d %s \n %d %s \n %d %s" % [offence, IMG_SWORD, defence, IMG_SHIELD, morale, IMG_MEDAL]
	
	# 1. Update Starting Layout
	if target_phase == "all" or target_phase == "round_start":
		var target_label: RichTextLabel = att_icons_from_cards_value if is_attacker else def_icons_from_cards_value
		if target_label != null:
			target_label.text = icon_string

	# 2. Update Damage Assessment Snapshot Layout
	if target_phase == "all" or target_phase == "damage_step":
		var target_assess_label: RichTextLabel = att_assess_damage_step_icons_from_cards_value if is_attacker else def_assess_damage_step_icons_from_cards_value
		if target_assess_label != null:
			target_assess_label.text = icon_string

## Standard use case: Card tokens that apply immediately during the active step
func set_assess_damage_step_tokens(role: String, offence_tokens: int, defence_tokens: int) -> void:
	var token_string := "0" if (offence_tokens == 0 and defence_tokens == 0) else "+%d %s\n+%d %s" % [offence_tokens, IMG_SWORD, defence_tokens, IMG_SHIELD]
	
	if role == "Attacker":
		if att_assess_damage_step_tokens_value != null:
			att_assess_damage_step_tokens_value.text = token_string
	else:
		if def_assess_damage_step_tokens_value != null:
			def_assess_damage_step_tokens_value.text = token_string


## Special use case: Delayed/Persistent effects that carry forward into Round Start
func set_round_start_tokens(role: String, offence_tokens: int, defence_tokens: int) -> void:
	var token_string := "0" if (offence_tokens == 0 and defence_tokens == 0) else "+%d %s | +%d %s" % [offence_tokens, IMG_SWORD, defence_tokens, IMG_SHIELD]
	
	if role == "Attacker":
		if att_tokens_value != null:
			att_tokens_value.text = token_string
	else:
		if def_tokens_value != null:
			def_tokens_value.text = token_string

func update_extra_icons(is_attacker: bool, offence: int, defence: int, morale_dice: int, target_phase: String = "all") -> void:
	var extra_icons := "%d %s \n %d %s \n %d %s" % [offence, IMG_SWORD, defence, IMG_SHIELD, morale_dice, IMG_MEDAL]
	
	# 1. Update Starting Layout
	if target_phase == "all" or target_phase == "round_start":
		var target_label: RichTextLabel = att_assess_damage_step_extra_icons_value if is_attacker else def_assess_damage_step_extra_icons_value
		target_label.text = extra_icons

	# 2. Update Damage Assessment Snapshot Layout
	if target_phase == "all" or target_phase == "damage_step":
		var target_assess_label: RichTextLabel = att_assess_damage_step_extra_icons_value if is_attacker else def_assess_damage_step_extra_icons_value
		if target_assess_label != null:
			target_assess_label.text = extra_icons


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

		var label := UNIT_LABEL.instantiate()
		label.text = entity_name
		container.add_child(label)

#endregion
