class_name CardRegistry
extends RefCounted

enum CardID {
	# --- SPACE MARINES (SM) ---
	SM_AMBUSH									= 1001,
	SM_RECONNAISSANCE							= 1002,
	SM_FURY_OF_THE_ULTRAMAR						= 1003,
	SM_BLESSED_POWER_ARMOUR						= 1004,
	SM_COMBAT_FAITH_IN_EMPEROR					= 1005,
	SM_HOLD_THE_LINE							= 1006,
	SM_GLORY_AND_DEATH							= 1007,
	SM_DROP_POD_ASSAULT							= 1008,
	SM_VETERAN_SCOUTS							= 1009,
	SM_SHOW_NO_FEAR								= 1010,
	SM_BREAK_THE_LINE							= 1011,
	SM_ARMOURED_ADVANCE							= 1012,
	SM_EMPERORS_MIGHT							= 1013,
	SM_EMPERORS_GLORY							= 1014,

	# --- ORKS (ORKS) ---
	ORKS_GRETCHIN						= 3001,
	ORKS_MEK_BOYZ						= 3002,
	ORKS_ARD_BOYZ						= 3003,
	ORKS_SHOOTA_BOYZ					= 3004,
	ORKS_SLUGGA_BOYZ					= 3005,
}

static func get_database() -> Dictionary:
	var db := {}
	var card: CardData
	
	
	# ==========================================================================
	# --- CARD 0000: Dummy Card ---
	# ==========================================================================
	# Instantiate a dummy object context to safely catch discarded (0) slots
	var empty_card := CardData.new()
	empty_card.card_id = 0
	empty_card.card_name = "Discarded Slot"
	empty_card.card_tier = CardData.CardTier.STARTER
	empty_card.offence_icons = 0
	empty_card.defence_icons = 0
	empty_card.morale_icons = 0
	db[0] = empty_card
	
	# ==========================================================================
	# --- CARD 1001: Ambush ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_AMBUSH
	card.card_name = "Ambush"
	card.card_tier = CardData.CardTier.STARTER
	card.offence_icons = 1
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
	card.card_tier = CardData.CardTier.STARTER
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
	card.card_tier = CardData.CardTier.STARTER
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
	card.card_tier = CardData.CardTier.STARTER
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
	card.card_tier = CardData.CardTier.STARTER
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
	# --- CARD 1006: Hold the Line ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_HOLD_THE_LINE
	card.card_name = "Hold the Line"
	card.card_tier = CardData.CardTier.TIER_0
	card.defence_icons = 1
	card.morale_icons = 1
	card.required_unit_types = [CardData.UnitType.SPACE_MARINES, CardData.UnitType.STRIKE_CRUISERS]
	
	# --- GENERAL ABILITY ---
	# Part 1: Gain 2 shield tokens
	var sm_hold_gen_tokens := CardEffect.new()
	sm_hold_gen_tokens.effect_type = CardData.EffectType.GAIN_SPECIFIC_COMBAT_TOKEN
	sm_hold_gen_tokens.target_type = CardData.TargetType.SELF
	sm_hold_gen_tokens.value = 2
	sm_hold_gen_tokens.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(sm_hold_gen_tokens)
	
	# Part 2: Conditional reactive recovery if caught on the defensive
	var sm_hold_gen_rally := CardEffect.new()
	sm_hold_gen_rally.effect_type = CardData.EffectType.RALLY_IF_DEFENDING
	sm_hold_gen_rally.target_type = CardData.TargetType.SELF
	sm_hold_gen_rally.value = 1
	card.general_ability.append(sm_hold_gen_rally)
	
	# --- UNIT ABILITY ---
	# Gain 1 S or 1 M
	var sm_hold_unit_choice := CardEffect.new()
	sm_hold_unit_choice.effect_type = CardData.EffectType.CHOICE
	sm_hold_unit_choice.target_type = CardData.TargetType.SELF
	
	var hold_opt_a := CardEffect.new()
	hold_opt_a.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	hold_opt_a.target_type = CardData.TargetType.SELF
	hold_opt_a.value = 1
	hold_opt_a.pool_type = CardData.DicePoolType.DEFENSE
	
	var hold_opt_b := CardEffect.new()
	hold_opt_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	hold_opt_b.target_type = CardData.TargetType.SELF
	hold_opt_b.value = 1
	hold_opt_b.pool_type = CardData.DicePoolType.MORALE
	
	sm_hold_unit_choice.choices = [hold_opt_a, hold_opt_b]
	card.unit_ability.append(sm_hold_unit_choice)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 1007: Glory and Death ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_GLORY_AND_DEATH
	card.card_name = "Glory and Death"
	card.card_tier = CardData.CardTier.TIER_0
	card.offence_icons = 1
	card.morale_icons = 1
	card.required_unit_types = [CardData.UnitType.SPACE_MARINES, CardData.UnitType.STRIKE_CRUISERS]
	
	# --- GENERAL ABILITY ---
	# Part 1: Push frontline momentum by granting 2 immediate offense tokens
	var sm_glory_gen_tokens := CardEffect.new()
	sm_glory_gen_tokens.effect_type = CardData.EffectType.GAIN_SPECIFIC_COMBAT_TOKEN
	sm_glory_gen_tokens.target_type = CardData.TargetType.SELF
	sm_glory_gen_tokens.value = 2
	sm_glory_gen_tokens.pool_type = CardData.DicePoolType.OFFENSE
	card.general_ability.append(sm_glory_gen_tokens)
	
	# Part 2: Capitalize on tactical pressure to rally an unrouted unit when attacking
	var sm_glory_gen_rally := CardEffect.new()
	sm_glory_gen_rally.effect_type = CardData.EffectType.RALLY_IF_ATTACKING
	sm_glory_gen_rally.target_type = CardData.TargetType.SELF
	sm_glory_gen_rally.value = 1
	card.general_ability.append(sm_glory_gen_rally)
	
	# --- UNIT ABILITY ---
	# Enemy loses 1 Shield or Morale dice
	var sm_glory_unit_choice := CardEffect.new()
	sm_glory_unit_choice.effect_type = CardData.EffectType.CHOICE
	sm_glory_unit_choice.target_type = CardData.TargetType.OPPONENT
	
	var glory_opt_a := CardEffect.new()
	glory_opt_a.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	glory_opt_a.target_type = CardData.TargetType.OPPONENT
	glory_opt_a.value = 1
	glory_opt_a.pool_type = CardData.DicePoolType.DEFENSE
	
	var glory_opt_b := CardEffect.new()
	glory_opt_b.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	glory_opt_b.target_type = CardData.TargetType.OPPONENT
	glory_opt_b.value = 1
	glory_opt_b.pool_type = CardData.DicePoolType.MORALE
	
	sm_glory_unit_choice.choices = [glory_opt_a, glory_opt_b]
	card.unit_ability.append(sm_glory_unit_choice)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 1008: Drop Pod Assault ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_DROP_POD_ASSAULT
	card.card_name = "Drop Pod Assault"
	card.card_tier = CardData.CardTier.TIER_0
	card.offence_icons = 1
	card.defence_icons = 1
	card.required_unit_types = [CardData.UnitType.SPACE_MARINES]
	
	# --- GENERAL ABILITY ---
	var sm_drop_gen := CardEffect.new()
	sm_drop_gen.effect_type = CardData.EffectType.GAIN_DICE
	sm_drop_gen.target_type = CardData.TargetType.SELF
	sm_drop_gen.value = 1
	card.general_ability.append(sm_drop_gen)
	
	# --- UNIT ABILITY ---
	var sm_drop_unit := CardEffect.new()
	sm_drop_unit.effect_type = CardData.EffectType.SPEND_MORALE_TO_SPAWN_UNIT
	sm_drop_unit.target_type = CardData.TargetType.SELF
	card.unit_ability.append(sm_drop_unit)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 1009: Veteran Scouts ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_VETERAN_SCOUTS
	card.card_name = "Veteran Scouts"
	card.card_tier = CardData.CardTier.TIER_0
	card.offence_icons = 1
	card.defence_icons = 1
	card.morale_icons = 1
	card.required_unit_types = [CardData.UnitType.SCOUTS, CardData.UnitType.STRIKE_CRUISERS]
	
	# --- GENERAL ABILITY ---
	var sm_vet_gen := CardEffect.new()
	sm_vet_gen.effect_type = CardData.EffectType.GAIN_TOKEN_PER_MORALE_DICE
	sm_vet_gen.target_type = CardData.TargetType.SELF
	sm_vet_gen.value = 1								# Multiplier: 1 token per die
	sm_vet_gen.pool_type = CardData.DicePoolType.RANDOM	# Funnels all allocations into one random token category
	card.general_ability.append(sm_vet_gen)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 1010: Show No Fear ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_SHOW_NO_FEAR
	card.card_name = "Show No Fear"
	card.card_tier = CardData.CardTier.TIER_2
	card.defence_icons = 2
	card.morale_icons = 1
	card.required_unit_types = [CardData.UnitType.SPACE_MARINES, CardData.UnitType.STRIKE_CRUISERS]
	
	# --- GENERAL ABILITY ---
	var sm_fear_gen := CardEffect.new()
	sm_fear_gen.effect_type = CardData.EffectType.PREVENT_ROUTING_THIS_ROUND
	sm_fear_gen.target_type = CardData.TargetType.SELF
	card.general_ability.append(sm_fear_gen)
	
	# --- UNIT ABILITY ---
	var sm_fear_unit := CardEffect.new()
	sm_fear_unit.effect_type = CardData.EffectType.RALLY_ALL_FRIENDLY_UNITS
	sm_fear_unit.target_type = CardData.TargetType.SELF
	card.unit_ability.append(sm_fear_unit)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 1011: Break the Line ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_BREAK_THE_LINE
	card.card_name = "Break the Line"
	card.card_tier = CardData.CardTier.TIER_2
	card.offence_icons = 1
	card.defence_icons = 2
	card.required_unit_types = [CardData.UnitType.LAND_RAIDERS, CardData.UnitType.BATTLE_BARGES]
	
	# --- GENERAL ABILITY ---
	# Spend 3 Morale to gain that many B or S
	var sm_break_gen := CardEffect.new()
	sm_break_gen.effect_type = CardData.EffectType.SPEND_MORALE_TO_GAIN_SPECIFIC_DICE
	sm_break_gen.target_type = CardData.TargetType.SELF
	sm_break_gen.value = 3
	sm_break_gen.pool_type = CardData.DicePoolType.RANDOM
	card.general_ability.append(sm_break_gen)
	
	# --- UNIT ABILITY ---
	# The opponent discards 1 of his faceup combat cards
	var sm_break_unit := CardEffect.new()
	sm_break_unit.effect_type = CardData.EffectType.OPPONENT_DISCARDS_FACEUP_CARD
	sm_break_unit.target_type = CardData.TargetType.OPPONENT
	sm_break_unit.value = 1
	card.unit_ability.append(sm_break_unit)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 1012: Armoured Advance ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_ARMOURED_ADVANCE
	card.card_name = "Armoured Advance"
	card.card_tier = CardData.CardTier.TIER_2
	card.offence_icons = 2
	card.defence_icons = 1
	card.required_unit_types = [CardData.UnitType.LAND_RAIDERS, CardData.UnitType.BATTLE_BARGES]
	
	# General ability: Gain 1 dice (Executed unconditionally)
	var sm_armoured_gen := CardEffect.new()
	sm_armoured_gen.effect_type = CardData.EffectType.GAIN_DICE
	sm_armoured_gen.target_type = CardData.TargetType.SELF
	sm_armoured_gen.value = 1
	card.general_ability.append(sm_armoured_gen)
	
	# Unit ability: Resolve an additional assess damage step this round
	var sm_armoured_unit := CardEffect.new()
	sm_armoured_unit.effect_type = CardData.EffectType.ADDITIONAL_ASSESS_DAMAGE_STEP_THIS_ROUND
	sm_armoured_unit.target_type = CardData.TargetType.SELF
	card.unit_ability.append(sm_armoured_unit)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 1013: Emperor's Might ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_EMPERORS_MIGHT
	card.card_name = "Emperor's Might"
	card.card_tier = CardData.CardTier.TIER_3
	card.offence_icons = 3
	card.required_unit_types = [CardData.UnitType.WARLORD_TITANS, CardData.UnitType.BATTLE_BARGES]
	
	# General ability: Gain 2 dice
	var sm_emperor_gen := CardEffect.new()
	sm_emperor_gen.effect_type = CardData.EffectType.GAIN_DICE
	sm_emperor_gen.target_type = CardData.TargetType.SELF
	sm_emperor_gen.value = 2
	card.general_ability.append(sm_emperor_gen)
	
	# Unit ability: Spend any number of Offence dice. For each spent, gain 2 offence tokens.
	var sm_emperor_unit := CardEffect.new()
	sm_emperor_unit.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_SPECIFIC_TOKEN
	sm_emperor_unit.target_type = CardData.TargetType.SELF
	sm_emperor_unit.value = 2 # Multiplier: Tokens gained per single die consumed
	sm_emperor_unit.pool_type = CardData.DicePoolType.OFFENSE
	card.unit_ability.append(sm_emperor_unit)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 1014: Emperor's Glory ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = 1014 # CardID.SM_EMPERORS_GLORY
	card.card_name = "Emperor's Glory"
	card.card_tier = CardData.CardTier.TIER_3
	card.offence_icons = 2
	card.defence_icons = 2
	card.required_unit_types = [CardData.UnitType.WARLORD_TITANS, CardData.UnitType.BATTLE_BARGES]
	
	# General ability: Gain 2 dice
	var sm_glory_gen := CardEffect.new()
	sm_glory_gen.effect_type = CardData.EffectType.GAIN_DICE
	sm_glory_gen.target_type = CardData.TargetType.SELF
	sm_glory_gen.value = 2
	card.general_ability.append(sm_glory_gen)
	
	# Unit ability 1: Rally all units
	var sm_glory_unit_1 := CardEffect.new()
	sm_glory_unit_1.effect_type = CardData.EffectType.RALLY_ALL_OF_YOUR_UNITS
	sm_glory_unit_1.target_type = CardData.TargetType.SELF
	card.unit_ability.append(sm_glory_unit_1)
	
	# Unit ability 2: Strategic Morale Conversion
	var sm_glory_unit_2 := CardEffect.new()
	sm_glory_unit_2.effect_type = CardData.EffectType.CONVERT_SAFE_DICE_TO_MORALE
	sm_glory_unit_2.target_type = CardData.TargetType.SELF
	card.unit_ability.append(sm_glory_unit_2)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 3001: Gretchin ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_GRETCHIN
	card.card_name = "Gretchin"
	card.card_tier = CardData.CardTier.STARTER
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
	# --- CARD 3002: Mek Boyz ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_MEK_BOYZ
	card.card_name = "Mek Boyz"
	card.card_tier = CardData.CardTier.STARTER
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
	# --- CARD 3003: Ard Boyz ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_ARD_BOYZ
	card.card_name = "Ard Boyz"
	card.card_tier = CardData.CardTier.STARTER
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
	
	# ==========================================================================
	# --- CARD 3004: Shoota Boyz ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_SHOOTA_BOYZ
	card.card_name = "Shoota Boyz"
	card.card_tier = CardData.CardTier.STARTER
	card.offence_icons = 2
	card.required_unit_types = [CardData.UnitType.ORK_BOYZ]
	
	# --- GENERAL ABILITY ---
	# Forced detriment/trade-off: Must reroll all own defense (Shield) dice
	var ork_shoota_gen := CardEffect.new()
	ork_shoota_gen.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	ork_shoota_gen.target_type = CardData.TargetType.SELF
	ork_shoota_gen.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(ork_shoota_gen)
	
	# --- UNIT ABILITY ---
	# Disruptive pressure: Forces opponent to reroll shields based on living Boyz count
	var ork_shoota_unit := CardEffect.new()
	ork_shoota_unit.effect_type = CardData.EffectType.REROLL_SPECIFIC_DICE_FOR_EACH_UNIT
	ork_shoota_unit.target_type = CardData.TargetType.OPPONENT
	ork_shoota_unit.value = CardData.UnitType.ORK_BOYZ
	ork_shoota_unit.pool_type = CardData.DicePoolType.DEFENSE
	card.unit_ability.append(ork_shoota_unit)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 3005: Slugga Boyz ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_SLUGGA_BOYZ
	card.card_name = "Slugga Boyz"
	card.card_tier = CardData.CardTier.STARTER
	card.offence_icons = 1
	card.defence_icons = 1
	card.required_unit_types = [CardData.UnitType.ORK_BOYZ, CardData.UnitType.ONSLAUGHTS]
	
	# --- GENERAL ABILITY ---
	# Complete psychological reset: Forces BOTH players to flush and reroll their Morale pools
	var ork_slugga_gen_self := CardEffect.new()
	ork_slugga_gen_self.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	ork_slugga_gen_self.target_type = CardData.TargetType.SELF
	ork_slugga_gen_self.pool_type = CardData.DicePoolType.MORALE
	card.general_ability.append(ork_slugga_gen_self)
	
	var ork_slugga_gen_opp := CardEffect.new()
	ork_slugga_gen_opp.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	ork_slugga_gen_opp.target_type = CardData.TargetType.OPPONENT
	ork_slugga_gen_opp.pool_type = CardData.DicePoolType.MORALE
	card.general_ability.append(ork_slugga_gen_opp)
	
	# --- UNIT ABILITY ---
	# Rallies 1 of your units
	var ork_slugga_unit := CardEffect.new()
	ork_slugga_unit.effect_type = CardData.EffectType.RALLY
	ork_slugga_unit.target_type = CardData.TargetType.SELF
	ork_slugga_unit.value = 1
	card.unit_ability.append(ork_slugga_unit)
	
	db[card.card_id] = card
	
	
	return db
