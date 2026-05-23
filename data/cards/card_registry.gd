class_name CardRegistry
extends RefCounted

enum CardID {
	# --- SPACE MARINES (SM) ---
	SM_AMBUSH                            = 1001,
	SM_RECONNAISSANCE                    = 1002,
	SM_FURY_OF_THE_ULTRAMAR                = 1003,
	SM_BLESSED_POWER_ARMOUR					= 1004,
	SM_COMBAT_FAITH_IN_EMPEROR            = 1005,

	# --- ORKS (ORKS) ---
	ORKS_GRETCHIN                        = 2001,
	ORKS_MEK_BOYZ						= 2002,
	ORKS_ARD_BOYZ						= 2003,
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
	# CHANGED: Converted from bitmask flag to standard Array layout
	card.required_unit_types = [CardData.UnitType.SCOUTS, CardData.UnitType.STRIKE_CRUISERS]
	
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
	# --- CARD 1002: Reconnaissance ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_RECONNAISSANCE
	card.card_name = "Reconnaissance"
	card.defence_icons = 1
	# CHANGED: Emptied array signifies no active constraints needed
	card.required_unit_types = []
	
	# General Ability: Choice between 2 Offence Tokens or 2 Defence Tokens
	var sm_recon_choice := CardEffect.new()
	sm_recon_choice.effect_type = CardData.EffectType.CHOICE
	sm_recon_choice.target_type = CardData.TargetType.SELF
	
	# Option A: Gain 2 Offence Tokens
	var recon_opt_a := CardEffect.new()
	recon_opt_a.effect_type = CardData.EffectType.GAIN_SPECIFIC_COMBAT_TOKEN
	recon_opt_a.target_type = CardData.TargetType.SELF
	recon_opt_a.value = 2
	recon_opt_a.pool_type = CardData.DicePoolType.OFFENSE
	
	# Option B: Gain 2 Defence Tokens
	var recon_opt_b := CardEffect.new()
	recon_opt_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_COMBAT_TOKEN
	recon_opt_b.target_type = CardData.TargetType.SELF
	recon_opt_b.value = 2
	recon_opt_b.pool_type = CardData.DicePoolType.DEFENSE
	
	sm_recon_choice.choices = [recon_opt_a, recon_opt_b]
	card.general_ability.append(sm_recon_choice)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 1003: Fury of the Ultramar ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_FURY_OF_THE_ULTRAMAR
	card.card_name = "Fury of the Ultramar"
	card.offence_icons = 1
	card.required_unit_types = [CardData.UnitType.SPACE_MARINES, CardData.UnitType.STRIKE_CRUISERS]
	
	# --- GENERAL ABILITY ---
	# Rule 1: Opponent rerolls 1 die (Mandatory execution path)
	var sm_fury_gen_opp := CardEffect.new()
	sm_fury_gen_opp.effect_type = CardData.EffectType.REROLL
	sm_fury_gen_opp.target_type = CardData.TargetType.OPPONENT
	sm_fury_gen_opp.value = 1
	card.general_ability.append(sm_fury_gen_opp)
	
	# Rule 2: Synchronized Choice Node (50/50 branch assignment path)
	var sm_fury_gen_self_choice := CardEffect.new()
	sm_fury_gen_self_choice.effect_type = CardData.EffectType.CHOICE
	sm_fury_gen_self_choice.target_type = CardData.TargetType.SELF
	
	# Option A: Execute the 1-die self-reroll sequence
	var fury_self_reroll_opt := CardEffect.new()
	fury_self_reroll_opt.effect_type = CardData.EffectType.REROLL
	fury_self_reroll_opt.target_type = CardData.TargetType.SELF
	fury_self_reroll_opt.value = 1
	
	# Option B: Decline the option and pass seamlessly
	var fury_self_pass_opt := CardEffect.new()
	fury_self_pass_opt.effect_type = CardData.EffectType.NONE
	fury_self_pass_opt.target_type = CardData.TargetType.SELF
	
	sm_fury_gen_self_choice.choices = [fury_self_reroll_opt, fury_self_pass_opt]
	card.general_ability.append(sm_fury_gen_self_choice)
	
	# --- UNIT ABILITY (AUTOMATED CONDITIONAL) ---
	var sm_fury_unit := CardEffect.new()
	sm_fury_unit.effect_type = CardData.EffectType.SHIELD_DEBUFF_CONDITIONAL
	sm_fury_unit.target_type = CardData.TargetType.OPPONENT
	sm_fury_unit.value = 2  
	sm_fury_unit.pool_type = CardData.DicePoolType.DEFENSE
	card.unit_ability.append(sm_fury_unit)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 1004: Blessed Power Armour ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_BLESSED_POWER_ARMOUR
	card.card_name = "Blessed Power Armour"
	card.defence_icons = 1
	card.required_unit_types = [CardData.UnitType.SPACE_MARINES, CardData.UnitType.STRIKE_CRUISERS]
	
	# --- GENERAL ABILITY ---
	var sm_blessed_gen := CardEffect.new()
	sm_blessed_gen.effect_type = CardData.EffectType.GAIN_SPECIFIC_COMBAT_TOKEN
	sm_blessed_gen.target_type = CardData.TargetType.SELF
	sm_blessed_gen.value = 2
	sm_blessed_gen.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(sm_blessed_gen)
	
	# --- UNIT ABILITY ---
	var sm_blessed_unit := CardEffect.new()
	sm_blessed_unit.effect_type = CardData.EffectType.CONVERT_DICE_TO_SPECIFIC_DICE
	sm_blessed_unit.target_type = CardData.TargetType.SELF
	sm_blessed_unit.value = 2
	sm_blessed_unit.pool_type = CardData.DicePoolType.DEFENSE
	card.unit_ability.append(sm_blessed_unit)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 1005: Faith In the Emperor ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_COMBAT_FAITH_IN_EMPEROR
	card.card_name = "Faith In the Emperor"
	card.morale_icons = 1
	# CHANGED: Single requirements are wrapped neatly in single-item arrays
	card.required_unit_types = [CardData.UnitType.SCOUTS]
	
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
	card.required_unit_types = [CardData.UnitType.ONSLAUGHTS]
	
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
	
	# ==========================================================================
	# --- CARD 2002: Mek Boyz ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_MEK_BOYZ
	card.card_name = "Mek Boyz"
	card.morale_icons = 1
	card.required_unit_types = [CardData.UnitType.ORK_BOYZ, CardData.UnitType.ONSLAUGHTS]
	
	# --- GENERAL ABILITY ---
	var ork_mek_gen := CardEffect.new()
	ork_mek_gen.effect_type = CardData.EffectType.GAIN_DICE
	ork_mek_gen.target_type = CardData.TargetType.SELF
	ork_mek_gen.value = 1
	card.general_ability.append(ork_mek_gen)
	
	# --- UNIT ABILITY ---
	var ork_mek_unit := CardEffect.new()
	ork_mek_unit.effect_type = CardData.EffectType.DISCARD_STEAL_ICONS
	ork_mek_unit.target_type = CardData.TargetType.OPPONENT
	card.unit_ability.append(ork_mek_unit)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 2003: Ard Boyz ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_ARD_BOYZ
	card.card_name = "Ard Boyz"
	card.defence_icons = 2
	card.required_unit_types = [CardData.UnitType.ORK_BOYZ]
	
	# --- GENERAL ABILITY ---
	var ork_ard_gen := CardEffect.new()
	ork_ard_gen.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	ork_ard_gen.target_type = CardData.TargetType.SELF
	ork_ard_gen.pool_type = CardData.DicePoolType.OFFENSE
	card.general_ability.append(ork_ard_gen)
	
	# --- UNIT ABILITY ---
	var ork_ard_unit := CardEffect.new()
	ork_ard_unit.effect_type = CardData.EffectType.REROLL_SPECIFIC_DICE_FOR_EACH_UNIT
	ork_ard_unit.target_type = CardData.TargetType.OPPONENT
	ork_ard_unit.value = CardData.UnitType.ORK_BOYZ # Unit type enum to look up and count
	ork_ard_unit.pool_type = CardData.DicePoolType.OFFENSE # Target pool to disrupt
	card.unit_ability.append(ork_ard_unit)
	
	db[card.card_id] = card
	
	
	
	return db
