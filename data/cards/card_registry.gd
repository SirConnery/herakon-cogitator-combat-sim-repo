class_name CardRegistry
extends RefCounted

enum CardID {
	# --- SPACE MARINES (SM) ---
	SM_AMBUSH							= 1001,
	SM_COMBAT_FAITH_IN_EMPEROR			= 1005,

	# --- ORKS (ORKS) ---
	ORKS_GRETCHIN						= 2001,
}

static func get_database() -> Dictionary:
	var db: Dictionary = {}
	var card: CardData
	
	# ==========================================================================
	# --- CARD 1001: Ambush ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_AMBUSH
	card.card_name = "Ambush"
	card.offence_icons = 1
	card.required_unit_types = CardData.UnitType.SCOUTS # Assumes Scouts for Space Marine ambush actions
	
	# General ability: Gain 2 offence tokens
	var sm_ambush_gen := CardEffect.new()
	sm_ambush_gen.effect_type = CardData.EffectType.GAIN_SPECIFIC_COMBAT_TOKEN
	sm_ambush_gen.target_type = CardData.TargetType.SELF
	sm_ambush_gen.value = 2
	sm_ambush_gen.pool_type = CardData.DicePoolType.OFFENSE
	card.general_ability.append(sm_ambush_gen)
	
	# Unit ability: When an enemy unit is routed it is destroyed unless opponent spends 1 Morale dice
	var sm_ambush_unit := CardEffect.new()
	sm_ambush_unit.effect_type = CardData.EffectType.DESTROY_ON_ROUT_OR_SPEND
	sm_ambush_unit.target_type = CardData.TargetType.OPPONENT
	sm_ambush_unit.value = 1 # Number of Morale dice penalty cost to tax the enemy
	card.unit_ability.append(sm_ambush_unit)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 1005: Faith In the Emperor ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_COMBAT_FAITH_IN_EMPEROR
	card.card_name = "Faith In the Emperor"
	card.offence_icons = 1
	card.required_unit_types = CardData.UnitType.SCOUTS
	
	# General effect
	var sm_gen_1 := CardEffect.new()
	sm_gen_1.effect_type = CardData.EffectType.GAIN_DICE
	sm_gen_1.target_type = CardData.TargetType.SELF
	sm_gen_1.value = 1
	card.general_ability.append(sm_gen_1)
	
	# Unit Choice Effect
	var sm_unit_choice := CardEffect.new()
	sm_unit_choice.effect_type = CardData.EffectType.CHOICE
	sm_unit_choice.target_type = CardData.TargetType.SELF
	
	var option_a := CardEffect.new()
	option_a.effect_type = CardData.EffectType.RALLY
	option_a.target_type = CardData.TargetType.SELF
	option_a.value = 1
	
	var option_b := CardEffect.new()
	option_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	option_b.target_type = CardData.TargetType.SELF
	option_b.value = 1
	option_b.pool_type = CardData.DicePoolType.MORALE
	
	sm_unit_choice.choices = [option_a, option_b]
	card.unit_ability.append(sm_unit_choice)
	
	db[card.card_id] = card
	

	# ==========================================================================
	# --- CARD 2001: Gretchin ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_GRETCHIN
	card.card_name = "Gretchin"
	card.required_unit_types = CardData.UnitType.ONSLAUGHTS
	
	var ork_gen_1 := CardEffect.new()
	ork_gen_1.effect_type = CardData.EffectType.GAIN_SPECIFIC_COMBAT_TOKEN
	ork_gen_1.target_type = CardData.TargetType.SELF
	ork_gen_1.value = 1
	ork_gen_1.pool_type = CardData.DicePoolType.OFFENSE
	card.general_ability.append(ork_gen_1)
	
	var ork_gen_2 := CardEffect.new()
	ork_gen_2.effect_type = CardData.EffectType.GAIN_SPECIFIC_COMBAT_TOKEN
	ork_gen_2.target_type = CardData.TargetType.SELF
	ork_gen_2.value = 1
	ork_gen_2.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(ork_gen_2)
	
	var ork_gen_3 := CardEffect.new()
	ork_gen_3.effect_type = CardData.EffectType.REROLL
	ork_gen_3.target_type = CardData.TargetType.OPPONENT
	ork_gen_3.value = 1
	card.general_ability.append(ork_gen_3)
	
	var ork_unit_1 := CardEffect.new()
	ork_unit_1.effect_type = CardData.EffectType.DESTROY_FOR_DESTROY
	ork_unit_1.target_type = CardData.TargetType.OPPONENT
	ork_unit_1.value = 1
	card.unit_ability.append(ork_unit_1)
	
	db[card.card_id] = card
	
	return db
