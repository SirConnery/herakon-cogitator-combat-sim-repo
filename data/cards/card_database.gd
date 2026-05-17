class_name CardRegistry
extends RefCounted

static func get_database() -> Dictionary:
	var db: Dictionary = {}
	var card: CardData
	var general_fx: CardEffect
	
	# We leave unit_fx untyped (as a Variant) to bypass Godot's compile-time static type locks
	var unit_fx 
	
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
	unit_fx.effect_type = CardData.EffectType.CHOICE
	unit_fx.target_type = CardData.TargetType.SELF
	
	# Define Option A: Rally 1 Unit
	var option_a := CardEffect.new()
	option_a.effect_type = CardData.EffectType.RALLY
	option_a.target_type = CardData.TargetType.SELF
	option_a.value = 1
	
	# Define Option B: Gain 1 Morale Die
	var option_b := CardEffect.new()
	option_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	option_b.target_type = CardData.TargetType.SELF
	option_b.value = 1
	option_b.pool_type = CardData.DicePoolType.MORALE
	
	unit_fx.set("choices", [option_a, option_b])
	
	card.general_ability = general_fx
	card.unit_ability = unit_fx
	
	db[card.card_id] = card
	
	return db
