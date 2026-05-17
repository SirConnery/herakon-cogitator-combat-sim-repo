class_name CardRegistry
extends RefCounted

static func get_database() -> Dictionary:
	var db: Dictionary = {}
	var card: CardData
	var general_fx: CardEffect
	var unit_fx: CardEffect
	
	# --- CARD 1: Faith In the Emperor ---
	card = CardData.new()
	card.card_id = 1
	card.card_name = "Faith In the Emperor"
	card.offence_icons = 1
	card.defence_icons = 0
	card.morale_icons = 0
	card.required_unit_types = CardData.UnitType.SCOUTS
	
	general_fx = CardEffect.new()
	general_fx.effect_type = CardData.EffectType.GAIN_DICE
	general_fx.target_type = CardData.TargetType.SELF
	general_fx.value = 1
	
	unit_fx = CardEffect.new()
	unit_fx.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	unit_fx.target_type = CardData.TargetType.SELF
	unit_fx.value = 1
	unit_fx.pool_type = CardData.DicePoolType.RANDOM
	
	card.general_ability = general_fx
	card.unit_ability = unit_fx
	
	db[card.card_id] = card
	
	return db
