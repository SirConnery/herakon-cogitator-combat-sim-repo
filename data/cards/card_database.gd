class_name CardRegistry
extends RefCounted

# Named enum acting as primitive integers for the simulation engine.
# Space Marines are based at 1000. Combat: 1001-1099, Orders: 1100+, Events: 1200+.
enum CardID {
	# --- SPACE MARINES (SM) ---
	SM_COMBAT_FAITH_IN_EMPEROR = 1001,
	# SM_ORDER_SAMPLE          = 1101,
	# SM_EVENT_SAMPLE          = 1201,

	# --- ORKS (ORKS) ---
	# ORK_COMBAT_SAMPLE        = 2001,
	# ORK_ORDER_SAMPLE         = 2101,
	# ORK_EVENT_SAMPLE         = 2201,
}

static func get_database() -> Dictionary:
	var db: Dictionary = {}
	var card: CardData
	var general_fx: CardEffect
	var unit_fx: CardEffect
	
	# --- CARD 1: Faith In the Emperor ---
	card = CardData.new()
	card.card_id = CardID.SM_COMBAT_FAITH_IN_EMPEROR
	card.card_name = "Faith In the Emperor"
	card.offence_icons = 1
	card.defence_icons = 0
	card.morale_icons = 0
	card.required_unit_types = CardData.UnitType.SCOUTS
	
	# --- General Ability ---
	general_fx = CardEffect.new()
	general_fx.effect_type = CardData.EffectType.GAIN_DICE
	general_fx.target_type = CardData.TargetType.SELF
	general_fx.value = 1
	
	# --- Unit Ability ---
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
	
	unit_fx.choices = [option_a, option_b]
	
	card.general_ability = general_fx
	card.unit_ability = unit_fx
	
	# Lock it into the database using the enum integer identity
	db[card.card_id] = card
	
	return db
