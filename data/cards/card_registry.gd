class_name CardRegistry
extends RefCounted

enum CardID {
	
	# --- SPACE MARINES (SM) ---
	SM_AMBUSH                    = 1001,
	SM_RECONNAISSANCE            = 1002,
	SM_FURY_OF_THE_ULTRAMAR      = 1003,
	SM_BLESSED_POWER_ARMOUR      = 1004,
	SM_COMBAT_FAITH_IN_EMPEROR   = 1005,
	SM_HOLD_THE_LINE             = 1006,
	SM_GLORY_AND_DEATH           = 1007,
	SM_DROP_POD_ASSAULT          = 1008,
	SM_VETERAN_SCOUTS            = 1009,
	SM_SHOW_NO_FEAR              = 1010,
	SM_BREAK_THE_LINE            = 1011,
	SM_ARMOURED_ADVANCE          = 1012,
	SM_EMPERORS_MIGHT            = 1013,
	SM_EMPERORS_GLORY            = 1014,

	# --- CHAOS SPACE MARINES (CSM) ---
	CSM_KHORNES_RAGE             = 2001,
	CSM_FOUL_WORSHIP             = 2002,
	CSM_IMPURE_ZEAL              = 2003,
	CSM_DARK_FAITH               = 2004,
	CSM_LURE_OF_CHAOS            = 2005,
	CSM_MARK_OF_KHORNE           = 2006,
	CSM_MARK_OF_NURGLE           = 2007,
	CSM_MARK_OF_SLAANESH         = 2008,
	CSM_MARK_OF_TZEENTCH         = 2009,
	CSM_INHUMAN_STRENGTH         = 2010,
	CSM_DAEMONIC_RESILIENCE      = 2011,
	CSM_CHAOS_UNITED             = 2012,
	CSM_DEATH_AND_DESPAIR        = 2013,
	CSM_CHAOS_VICTORIOUS         = 2014,
	
	# --- ORKS (ORKS) ---
	ORKS_GRETCHIN                = 3001,
	ORKS_MEK_BOYZ                = 3002,
	ORKS_ARD_BOYZ                = 3003,
	ORKS_SHOOTA_BOYZ             = 3004,
	ORKS_SLUGGA_BOYZ             = 3005,
	ORKS_WAAAGH                  = 3006,
	ORKS_SEA_OF_GREEN            = 3007,
	ORKS_MEGA_NOBZ               = 3008,
	ORKS_BIKER_NOBZ              = 3009,
	ORKS_WEIRDBOYZ               = 3010,
	ORKS_PARTY_WAGON             = 3011,
	ORKS_ROKKIT_WAGON            = 3012,
	ORKS_SNAPPER_GARGANT         = 3013,
	ORKS_SMASHER_GARGANT         = 3014,
	
	ELDAR_HIT_AND_RUN            = 4001,
	ELDAR_HOWLING_BANSHEES       = 4002,
	ELDAR_STRIKING_SCORPIONS     = 4003,
	ELDAR_RANGER_SUPPORT         = 4004,
	ELDAR_COMMAND_OF_THE_AUTARCH = 4005,
	ELDAR_FIRE_DRAGONS_VENGEANCE = 4006,
	ELDAR_SWOOPING_HAWKS         = 4007,
	ELDAR_WRAITHGUARD_ADVANCE    = 4008,
	
	
	# --- TESTING ---
}

static func get_database() -> Dictionary:
	var db := {}
	var card: CardData
	
	var fx_1: CardEffect
	var fx_2: CardEffect
	var fx_3: CardEffect
	var fx_u_1: CardEffect
	var fx_u_2: CardEffect
	var node: CardEffect
	var opt_a: CardEffect
	var opt_b: CardEffect
	var opt_c: CardEffect
	var opt_u_a: CardEffect
	var opt_u_b: CardEffect
	
	# ==========================================================================
	# --- CARD 0000: Dummy Card ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = 0
	card.card_name = "Discarded Slot"
	card.card_tier = CardData.CardTier.STARTER
	card.offence_icons = 0
	card.defence_icons = 0
	card.morale_icons = 0
	db[0] = card
	
	# ==========================================================================
	# --- CARD 1001: Ambush ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_AMBUSH
	card.card_name = "Ambush"
	card.card_tier = CardData.CardTier.STARTER
	card.offence_icons = 1
	card.required_unit_types = [CardData.UnitType.SCOUTS, CardData.UnitType.STRIKE_CRUISERS]
	
	# --- GENERAL ABILITY ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 2
	fx_1.pool_type = CardData.CombatTokenType.OFFENSE
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.DESTROY_ON_ROUT_OR_SPEND
	fx_u_1.target_type = CardData.TargetType.OPPONENT
	fx_u_1.value = 1 
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 1002: Reconnaissance ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_RECONNAISSANCE
	card.card_name = "Reconnaissance"
	card.card_tier = CardData.CardTier.STARTER
	card.defence_icons = 1
	card.required_unit_types = []
	
	# General Ability: Choice between 2 Offence Tokens or 2 Defence Tokens
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CHOICE
	fx_1.target_type = CardData.TargetType.SELF
	
	# Option A: Gain 2 Offence Tokens
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 2
	opt_a.pool_type = CardData.CombatTokenType.OFFENSE # 🎯 Updated to type-safe token enum
	
	# Option B: Gain 2 Defence Tokens
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 2
	opt_b.pool_type = CardData.CombatTokenType.DEFENSE # 🎯 Updated to type-safe token enum
	
	fx_1.choices = [opt_a, opt_b]
	card.general_ability.append(fx_1)
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.REROLL
	fx_1.target_type = CardData.TargetType.OPPONENT
	fx_1.value = 1
	fx_1.pool_type = CardData.DicePoolType.DEFENSE # Dice pool manipulation
	card.general_ability.append(fx_1)

	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CHOICE
	fx_2.target_type = CardData.TargetType.SELF

	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.REROLL
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.pool_type = CardData.DicePoolType.DEFENSE # Fixed copy-paste assignment typo (was fx_1)
	opt_a.value = 1

	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.NONE
	opt_b.target_type = CardData.TargetType.SELF

	fx_2.choices = [opt_a, opt_b]
	card.general_ability.append(fx_2)

	# --- UNIT ABILITY ---
	# PART A: Fallback Penalty -> If opponent has 0 or 1 token, destroy 1 Shield die
	opt_u_a = CardEffect.new()
	opt_u_a.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_u_a.target_type = CardData.TargetType.OPPONENT
	opt_u_a.value = 1
	opt_u_a.pool_type = CardData.DicePoolType.DEFENSE # Targets dice

	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_FEWER_THAN_TWO_DEFENSE_TOKENS
	fx_u_1.choices.append(opt_u_a)
	card.unit_ability.append(fx_u_1)

	# PART B: Standard Tax -> If opponent has 2 or more tokens, strip 2 Shield tokens
	opt_u_b = CardEffect.new()
	opt_u_b.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_u_b.target_type = CardData.TargetType.OPPONENT
	opt_u_b.value = -2
	opt_u_b.pool_type = CardData.CombatTokenType.DEFENSE # 🎯 Target Token Type

	fx_u_2 = CardEffect.new()
	fx_u_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_2.condition_type = CardData.ConditionType.OPPONENT_HAS_TWO_OR_MORE_DEFENSE_TOKENS
	fx_u_2.choices.append(opt_u_b)
	card.unit_ability.append(fx_u_2)

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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 2
	fx_1.pool_type = CardData.CombatTokenType.DEFENSE # 🎯 Target Token Type
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONVERT_DICE_TO_SPECIFIC_DICE
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 2
	fx_u_1.pool_type = CardData.DicePoolType.DEFENSE # Targets dice
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 1005: Faith In the Emperor ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_COMBAT_FAITH_IN_EMPEROR
	card.card_name = "Faith In the Emperor"
	card.card_tier = CardData.CardTier.STARTER
	card.morale_icons = 1
	card.required_unit_types = [CardData.UnitType.SCOUTS]
	
	# General effect
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# Unit Choice Effect
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CHOICE
	fx_u_1.target_type = CardData.TargetType.SELF
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.RALLY
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 1
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 1
	opt_b.pool_type = CardData.DicePoolType.MORALE # Targets dice
	
	fx_u_1.choices = [opt_a, opt_b]
	card.unit_ability.append(fx_u_1)
	
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
	# Part 1: Gain 2 defence tokens
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 2
	fx_1.pool_type = CardData.CombatTokenType.DEFENSE # 🎯 Target Token Type
	card.general_ability.append(fx_1)
	
	# Part 2: Rally if defending
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.IS_DEFENDING
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.RALLY
	node.target_type = CardData.TargetType.SELF
	node.value = 1
	
	fx_2.choices = [node]
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	# Gain 1 Defence dice OR 1 Morale dice
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CHOICE
	fx_u_1.target_type = CardData.TargetType.SELF
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 1
	opt_a.pool_type = CardData.DicePoolType.DEFENSE # Targets dice
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 1
	opt_b.pool_type = CardData.DicePoolType.MORALE # Targets dice
	
	fx_u_1.choices = [opt_a, opt_b]
	card.unit_ability.append(fx_u_1)
	
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
	# Part 1: Gain 2 offence tokens
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 2
	fx_1.pool_type = CardData.CombatTokenType.OFFENSE # 🎯 Target Token Type
	card.general_ability.append(fx_1)
	
	# Part 2: Rally if attacking
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.IS_ATTACKING
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.RALLY
	node.target_type = CardData.TargetType.SELF
	node.value = 1
	
	fx_2.choices = [node]
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	# Tactical choice block
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CHOICE
	fx_u_1.target_type = CardData.TargetType.OPPONENT
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_a.target_type = CardData.TargetType.OPPONENT
	opt_a.value = 1
	opt_a.pool_type = CardData.DicePoolType.DEFENSE # Targets dice
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_b.target_type = CardData.TargetType.OPPONENT
	opt_b.value = 1
	opt_b.pool_type = CardData.DicePoolType.MORALE # Targets dice
	
	fx_u_1.choices = [opt_a, opt_b]
	card.unit_ability.append(fx_u_1)
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# Spend 1 morale dice to place Space Marine
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
	# Step 1: Pay the cost automatically
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 1
	opt_a.pool_type = CardData.DicePoolType.MORALE # Targets dice
	
	# Step 2: Spawn the unit automatically
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.SPAWN_UNIT
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 1
	opt_b.pool_type = CardData.UnitType.SPACE_MARINES as CardData.DicePoolType
	
	fx_u_1.choices = [opt_a, opt_b]
	card.unit_ability.append(fx_u_1)
	
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
	# Gain tokens for each morale you have
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_TOKEN_PER_SPECIFIC_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1                                 # Multiplier: 1 token per die
	fx_1.pool_type = CardData.DicePoolType.MORALE  # The source dice pool to scan (fx_1[3])
	fx_1.max_spend = 0                             # 🎯 0 triggers the RANDOM token type evaluation gate (fx_1[6])
	card.general_ability.append(fx_1)
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.PREVENT_ROUTING_THIS_ROUND
	fx_1.target_type = CardData.TargetType.SELF
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# Spend 1 morale to rally all units
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
	# Step 1: Pay 1 Morale die cost
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 1
	opt_a.pool_type = CardData.DicePoolType.MORALE # Targets dice
	
	# Step 2: Execute the global squad rally
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.RALLY_ALL_FRIENDLY_UNITS
	opt_b.target_type = CardData.TargetType.SELF
	
	fx_u_1.choices = [opt_a, opt_b]
	card.unit_ability.append(fx_u_1)
	
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
	# 🔄 Convert 3 morale into different random dice
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONVERT_DICE_TO_RANDOM_DIFFERENT_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 3
	fx_1.pool_type = CardData.DicePoolType.MORALE # Targets dice
	card.general_ability.append(fx_1)

	# --- UNIT ABILITY ---
	# The opponent discards 1 of his faceup combat cards
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.OPPONENT_DISCARDS_WORST_FACEUP_CARD
	fx_u_1.target_type = CardData.TargetType.OPPONENT
	fx_u_1.value = 1
	card.unit_ability.append(fx_u_1)

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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# Unit ability: Resolve an additional assess damage step this round
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.ADDITIONAL_ASSESS_DAMAGE_STEP_THIS_ROUND
	fx_u_1.target_type = CardData.TargetType.SELF
	card.unit_ability.append(fx_u_1)
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 2
	card.general_ability.append(fx_1)
	
	# Unit ability: Spend any number of Offence dice. For each spent, gain 2 offence tokens.
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 2                                      # Multiplier: Tokens gained per single die consumed
	fx_u_1.pool_type = CardData.DicePoolType.OFFENSE       # Source asset consumed
	fx_u_1.gain_token_type = CardData.CombatTokenType.OFFENSE # 🎯 Target Token Type
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 1014: Emperor's Glory ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.SM_EMPERORS_GLORY
	card.card_name = "Emperor's Glory"
	card.card_tier = CardData.CardTier.TIER_3
	card.offence_icons = 2
	card.defence_icons = 2
	card.required_unit_types = [CardData.UnitType.WARLORD_TITANS, CardData.UnitType.BATTLE_BARGES]
	
	# General ability: Gain 2 dice
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 2
	card.general_ability.append(fx_1)
	
	# Unit ability 1: Rally all units
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.RALLY_ALL_FRIENDLY_UNITS
	fx_u_1.target_type = CardData.TargetType.SELF
	card.unit_ability.append(fx_u_1)
	
	# Unit ability 2: Strategic Morale Conversion
	fx_u_2 = CardEffect.new()
	fx_u_2.effect_type = CardData.EffectType.CONVERT_SAFE_DICE_TO_MORALE
	fx_u_2.target_type = CardData.TargetType.SELF
	card.unit_ability.append(fx_u_2)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 2001: Khorne's Rage ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.CSM_KHORNES_RAGE
	card.card_name = "Khorne's Rage"
	card.card_tier = CardData.CardTier.STARTER
	card.offence_icons = 1
	card.required_unit_types = [CardData.UnitType.CHAOS_SPACE_MARINES, CardData.UnitType.ICONOCLAST_DESTROYERS]
	
	# --- GENERAL ABILITY ---
	# Spend 1 offence dice to gain 3 offence tokens
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 3
	fx_1.max_spend = 1
	fx_1.pool_type = CardData.DicePoolType.OFFENSE
	fx_1.gain_token_type = CardData.CombatTokenType.OFFENSE 
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# Rout unit or spend 1 Defence dice
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.ROUT_LOWEST_TIER_OR_SPEND_DICE
	fx_u_1.target_type = CardData.TargetType.OPPONENT
	fx_u_1.value = 1
	fx_u_1.pool_type = CardData.DicePoolType.DEFENSE
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 2002: Foul Worship ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.CSM_FOUL_WORSHIP
	card.card_name = "Foul Worship"
	card.card_tier = CardData.CardTier.STARTER
	card.defence_icons = 1
	card.required_unit_types = [CardData.UnitType.CULTISTS, CardData.UnitType.ICONOCLAST_DESTROYERS]
	
	# --- GENERAL ABILITY ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.GAIN_TOKEN_PER_UNROUTED_UNIT
	node.target_type = CardData.TargetType.SELF
	node.value = 1
	node.pool_type = CardData.CombatTokenType.DEFENSE # 🎯 Target Token Type
	node.max_spend = CardData.UnitFilterMode.REQUIRED_TYPES
	
	fx_u_1.choices = [node]
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 2003: Impure Zeal ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.CSM_IMPURE_ZEAL
	card.card_name = "Impure Zeal"
	card.card_tier = CardData.CardTier.STARTER
	card.offence_icons = 1
	card.defence_icons = 1
	card.required_unit_types = [CardData.UnitType.CULTISTS, CardData.UnitType.ICONOCLAST_DESTROYERS]
	
	# --- GENERAL ABILITY ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.HAS_MORE_MORALE_THAN_OPPONENT
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.RALLY
	node.target_type = CardData.TargetType.SELF
	node.value = 1
	
	fx_1.choices = [node]
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# Gain 1 offence token per unrouted tier 0 unit
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.GAIN_TOKEN_PER_UNROUTED_UNIT
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 1
	fx_u_1.pool_type = CardData.CombatTokenType.OFFENSE # 🎯 Target Token Type
	fx_u_1.max_spend = CardData.UnitFilterMode.REQUIRED_TYPES
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 2004: Dark Faith ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.CSM_DARK_FAITH
	card.card_name = "Dark Faith"
	card.card_tier = CardData.CardTier.STARTER
	card.morale_icons = 1
	card.required_unit_types = [CardData.UnitType.CULTISTS, CardData.UnitType.ICONOCLAST_DESTROYERS]
	
	# --- GENERAL ABILITY ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	fx_1.pool_type = CardData.DicePoolType.MORALE # Targets dice
	card.general_ability.append(fx_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 2005: Lure of Chaos ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.CSM_LURE_OF_CHAOS
	card.card_name = "Lure of Chaos"
	card.card_tier = CardData.CardTier.STARTER
	card.morale_icons = 1
	card.required_unit_types = [CardData.UnitType.CULTISTS, CardData.UnitType.ICONOCLAST_DESTROYERS]
	
	# --- GENERAL ABILITY ---
	# Setup Branch 1: Opponent has unrouted units
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.OPPONENT_HAS_UNROUTED_UNITS
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.ROUT_LOWEST_TIER
	opt_a.target_type = CardData.TargetType.OPPONENT
	opt_a.value = 1
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_DICE
	opt_b.target_type = CardData.TargetType.OPPONENT
	opt_b.value = 1
	
	fx_1.choices.append(opt_a)
	fx_1.choices.append(opt_b)
	
	# Setup Branch 2: Opponent has NO unrouted units
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.OPPONENT_HAS_NO_UNROUTED_UNITS
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.SPAWN_REINFORCEMENT_TOKEN
	node.target_type = CardData.TargetType.SELF
	node.value = 1
	
	fx_2.choices.append(node)
	
	# --- GENERAL ABILITY EXECUTION ORDER ---
	card.general_ability.append(fx_2) 
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# Choice: Gain 2 Offence tokens OR 2 Defence tokens
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CHOICE
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 2
	opt_a.pool_type = CardData.CombatTokenType.OFFENSE # 🎯 Target Token Type
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 2
	opt_b.pool_type = CardData.CombatTokenType.DEFENSE # 🎯 Target Token Type
	
	fx_u_1.choices.append(opt_a)
	fx_u_1.choices.append(opt_b)
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 2006: Mark of Khorne ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.CSM_MARK_OF_KHORNE
	card.card_name = "Mark of Khorne"
	card.card_tier = CardData.CardTier.STARTER
	card.offence_icons = 2
	card.required_unit_types = [CardData.UnitType.CHAOS_SPACE_MARINES, CardData.UnitType.ICONOCLAST_DESTROYERS]
	
	# --- GENERAL ABILITY ---
	# Setup Branch 1: Player has NO Morale dice -> Converts 1 Offence Die to 3 Offence Tokens
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.HAS_NO_MORALE_DICE
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.pool_type = CardData.DicePoolType.OFFENSE
	opt_a.gain_token_type = CardData.CombatTokenType.OFFENSE # 🎯 Target Token Type
	opt_a.value = 3
	opt_a.max_spend = 1
	fx_1.choices.append(opt_a)
	
	# Setup Branch 2: Player HAS Morale dice -> Converts 1 Morale Die to 3 Offence Tokens
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.pool_type = CardData.DicePoolType.MORALE
	opt_b.gain_token_type = CardData.CombatTokenType.OFFENSE # 🎯 Target Token Type
	opt_b.value = 3
	opt_b.max_spend = 1
	fx_2.choices.append(opt_b)
	
	card.general_ability.append(fx_1)
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	# Branch 1: Opponent HAS routed units BUT has NO Defence dice -> Force destruction
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS_AND_NO_DEFENSE_DICE
	
	opt_u_a = CardEffect.new()
	opt_u_a.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	opt_u_a.target_type = CardData.TargetType.OPPONENT
	opt_u_a.value = 1
	opt_u_a.destruction_mode = CardData.DestructionMode.ROUTED 
	fx_u_1.choices.append(opt_u_a)
	
	# Branch 2: Opponent HAS routed units AND HAS Defence dice -> Tax 1 Defence die
	fx_u_2 = CardEffect.new()
	fx_u_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_2.condition_type = CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS_AND_DEFENSE_DICE
	
	opt_u_b = CardEffect.new()
	opt_u_b.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_u_b.target_type = CardData.TargetType.OPPONENT
	opt_u_b.pool_type = CardData.DicePoolType.DEFENSE # Targets dice
	opt_u_b.value = 1
	fx_u_2.choices.append(opt_u_b)
	
	card.unit_ability.append(fx_u_1)
	card.unit_ability.append(fx_u_2)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 2007: Mark of Nurgle ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.CSM_MARK_OF_NURGLE
	card.card_name = "Mark of Nurgle"
	card.card_tier = CardData.CardTier.TIER_0
	card.defence_icons = 2
	card.required_unit_types = [CardData.UnitType.CHAOS_SPACE_MARINES, CardData.UnitType.ICONOCLAST_DESTROYERS]
	
	# --- GENERAL ABILITY ---
	# Master Guard: Only allow conversion if Defence token generation isn't locked down
	var fx_suppression_guard = CardEffect.new()
	fx_suppression_guard.effect_type = CardData.EffectType.CONDITIONAL
	fx_suppression_guard.condition_type = CardData.ConditionType.CANNOT_GAIN_DEFENSE_TOKENS_THIS_ROUND_IS_NOT_ACTIVE
	
	# Setup Branch 1: Player has NO Morale dice -> Converts 1 Defence Die to 3 Defence Tokens
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.HAS_NO_MORALE_DICE
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.pool_type = CardData.DicePoolType.DEFENSE
	opt_a.gain_token_type = CardData.CombatTokenType.DEFENSE # 🎯 Target Token Type
	opt_a.value = 3
	opt_a.max_spend = 1
	fx_1.choices.append(opt_a)
	
	# Setup Branch 2: Player HAS Morale dice -> Converts 1 Morale Die to 3 Defence Tokens
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.pool_type = CardData.DicePoolType.MORALE
	opt_b.gain_token_type = CardData.CombatTokenType.DEFENSE # 🎯 Target Token Type
	opt_b.value = 3
	opt_b.max_spend = 1
	fx_2.choices.append(opt_b)
	
	# Nest the dice dependency evaluation paths safely beneath the suppression check
	fx_suppression_guard.choices.append(fx_1)
	fx_suppression_guard.choices.append(fx_2)
	
	card.general_ability.append(fx_suppression_guard)
	
	# --- UNIT ABILITY ---
	# Condition Check: If opponent has routed units gain 2 defence tokens
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS
	
	# Payout Node: Gain 2 Defence Tokens
	opt_u_a = CardEffect.new()
	opt_u_a.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_u_a.target_type = CardData.TargetType.SELF
	opt_u_a.value = 2
	opt_u_a.pool_type = CardData.CombatTokenType.DEFENSE # 🎯 Target Token Type
	
	fx_u_1.choices.append(opt_u_a)
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 2008: Mark of Slaanesh ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.CSM_MARK_OF_SLAANESH
	card.card_name = "Mark of Slaanesh"
	card.card_tier = CardData.CardTier.TIER_0
	card.offence_icons = 1
	card.defence_icons = 1
	card.required_unit_types = [CardData.UnitType.CHAOS_SPACE_MARINES]
	
	# --- GENERAL ABILITY ---
	# Part 1: Unconditional +1 Dice allocation
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# Part 2: High Morale condition checking
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.HAS_MORE_MORALE_THAN_OPPONENT
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.ROUT_LOWEST_TIER
	node.target_type = CardData.TargetType.OPPONENT
	node.value = 1
	
	fx_2.choices.append(node)
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	# Condition Check: If opponent has routed units, execute reinforcement spawn
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS
	
	# Spawn Node: Place 1 reinforcement token on self side
	opt_u_a = CardEffect.new()
	opt_u_a.effect_type = CardData.EffectType.SPAWN_REINFORCEMENT_TOKEN
	opt_u_a.target_type = CardData.TargetType.SELF
	opt_u_a.value = 1
	
	fx_u_1.choices.append(opt_u_a)
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 2009: Mark of Tzeentch ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.CSM_MARK_OF_TZEENTCH
	card.card_name = "Mark of Tzeentch"
	card.card_tier = CardData.CardTier.TIER_0
	card.morale_icons = 2
	card.required_unit_types = [CardData.UnitType.CHAOS_SPACE_MARINES, CardData.UnitType.ICONOCLAST_DESTROYERS]
	
	# --- GENERAL ABILITY ---
	# Part 1: Gain 1 morale dice
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	fx_1.pool_type = CardData.DicePoolType.MORALE # Targets dice
	card.general_ability.append(fx_1)
	
	# Part 2: Nested Conditional Evaluation (HAS_MORE_MORALE AND HAS_CULTIST)
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.HAS_MORE_MORALE_THAN_OPPONENT
	
	# Inner Check: Evaluated only if the player has higher morale
	var inner_cond = CardEffect.new()
	inner_cond.effect_type = CardData.EffectType.CONDITIONAL
	inner_cond.condition_type = CardData.ConditionType.HAS_CULTISTS
	
	# Payout Node A: Spawn 1 Chaos Space Marine
	var spawn_fx = CardEffect.new()
	spawn_fx.effect_type = CardData.EffectType.SPAWN_UNIT
	spawn_fx.target_type = CardData.TargetType.SELF
	spawn_fx.value = 1
	@warning_ignore("int_as_enum_without_match")
	spawn_fx.pool_type = CardData.UnitType.CHAOS_SPACE_MARINES as CardData.DicePoolType
	
	# Payout Node B: Sacrifices your own lowest-tier unit (the Cultist)
	var sacrifice_fx = CardEffect.new()
	sacrifice_fx.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	sacrifice_fx.target_type = CardData.TargetType.SELF
	sacrifice_fx.value = 1
	
	# Build the hierarchical evaluation tree
	inner_cond.choices.append(spawn_fx)
	inner_cond.choices.append(sacrifice_fx)
	fx_2.choices.append(inner_cond)
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	# Spend up to 2 Morale Dice. For each spent, convert to a random different type.
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONVERT_DICE_TO_RANDOM_DIFFERENT_DICE
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 2
	fx_u_1.pool_type = CardData.DicePoolType.MORALE # Targets dice
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 2010: Inhuman Strength ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.CSM_INHUMAN_STRENGTH
	card.card_name = "Inhuman Strength"
	card.card_tier = CardData.CardTier.TIER_2
	card.offence_icons = 2
	card.morale_icons = 1
	card.required_unit_types = [CardData.UnitType.HELBRUTES, CardData.UnitType.REPULSIVE_GRAND_CRUISERS]
	
	# --- GENERAL ABILITY ---
	# Modal Choice Selection: Player selects 1 Offence OR 1 Morale Die allocation
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CHOICE
	
	# Option A: +1 Offence Dice
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 1
	opt_a.pool_type = CardData.DicePoolType.OFFENSE # Targets dice
	
	# Option B: +1 Morale Dice
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 1
	opt_b.pool_type = CardData.DicePoolType.MORALE # Targets dice
	
	fx_1.choices.append(opt_a)
	fx_1.choices.append(opt_b)
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# Condition Check: Evaluate if the player controls any living units remaining
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.HAS_UNITS
	
	# Payout Node A: Sacrifice your own lowest-tier unit on the board
	var sac_fx = CardEffect.new()
	sac_fx.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	sac_fx.target_type = CardData.TargetType.SELF
	sac_fx.value = 1
	
	# Payout Node B: Gain +4 Offence Combat Tokens
	var token_fx = CardEffect.new()
	token_fx.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	token_fx.target_type = CardData.TargetType.SELF
	token_fx.value = 4
	token_fx.pool_type = CardData.CombatTokenType.OFFENSE # 🎯 Target Token Type
	
	# Append sequential steps to the conditional waterfall
	fx_u_1.choices.append(sac_fx)
	fx_u_1.choices.append(token_fx)
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 2011: Daemonic Resilience ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.CSM_DAEMONIC_RESILIENCE
	card.card_name = "Daemonic Resilience"
	card.card_tier = CardData.CardTier.TIER_2
	card.defence_icons = 2
	card.morale_icons = 1
	card.required_unit_types = [CardData.UnitType.HELBRUTES, CardData.UnitType.REPULSIVE_GRAND_CRUISERS]
	
	# --- GENERAL ABILITY ---
	# Modal Choice Selection: Player selects 1 Defence (Shield) OR 1 Morale Die allocation
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CHOICE
	
	# Option A: +1 Defence Dice
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 1
	opt_a.pool_type = CardData.DicePoolType.DEFENSE # Targets dice
	
	# Option B: +1 Morale Dice
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 1
	opt_b.pool_type = CardData.DicePoolType.MORALE # Targets dice
	
	fx_1.choices.append(opt_a)
	fx_1.choices.append(opt_b)
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# Gain 4 Defence Combat Tokens
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 4
	fx_u_1.pool_type = CardData.CombatTokenType.DEFENSE # 🎯 Target Token Type
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 2012: Chaos United ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.CSM_CHAOS_UNITED
	card.card_name = "Chaos United"
	card.card_tier = CardData.CardTier.TIER_2
	card.offence_icons = 1
	card.defence_icons = 1
	card.morale_icons = 1
	card.required_unit_types = [CardData.UnitType.CULTISTS, CardData.UnitType.CHAOS_SPACE_MARINES, CardData.UnitType.HELBRUTES]
	
	# --- GENERAL ABILITY ---
	# Gain 1 dice
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# Custom ability
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CHAOS_UNITED_UNIT_ABILITY
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 2013: Death And Despair ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.CSM_DEATH_AND_DESPAIR
	card.card_name = "Death And Despair"
	card.card_tier = CardData.CardTier.TIER_3
	card.offence_icons = 2
	card.morale_icons = 1
	card.required_unit_types = [CardData.UnitType.CHAOS_REAVER_TITANS, CardData.UnitType.REPULSIVE_GRAND_CRUISERS]
	
	# --- GENERAL ABILITY ---
	# Ability 1: Modal Choice Selection (Player selects +2 Offence OR +2 Morale Dice)
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CHOICE
	
	# Option A: +2 Offence Dice
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 2
	opt_a.pool_type = CardData.DicePoolType.OFFENSE # Targets dice
	
	# Option B: +2 Morale Dice
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 2
	opt_b.pool_type = CardData.DicePoolType.MORALE # Targets dice
	
	fx_1.choices.append(opt_a)
	fx_1.choices.append(opt_b)
	card.general_ability.append(fx_1)
	
	# Ability 2: Custom execution node for the optimized Morale-spend destruction loop
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.DEATH_AND_DESPAIR_GENERAL_ABILITY_2
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	# Condition Check: Validate both relative morale value superiority and opponent rout states
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.HAS_MORE_MORALE_THAN_OPPONENT_AND_OPPONENT_HAS_ROUTED_UNITS
	
	# Payout Node: Destroy 1 Opponent Highest-Tier Routed Unit if condition is met
	var destroy_routed_fx = CardEffect.new()
	destroy_routed_fx.effect_type = CardData.EffectType.DESTROY_HIGHEST_TIER_ROUTED_UNIT
	destroy_routed_fx.target_type = CardData.TargetType.OPPONENT
	destroy_routed_fx.value = 1
	
	# Append the target payout payload to the conditional sequence waterfall
	fx_u_1.choices.append(destroy_routed_fx)
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 2014: Chaos Victorious ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.CSM_CHAOS_VICTORIOUS
	card.card_name = "Chaos Victorious"
	card.card_tier = CardData.CardTier.TIER_3
	card.offence_icons = 1
	card.defence_icons = 1
	card.morale_icons = 1
	card.required_unit_types = [CardData.UnitType.CHAOS_REAVER_TITANS, CardData.UnitType.REPULSIVE_GRAND_CRUISERS]
	
	# --- GENERAL ABILITY ---
	# Ability 1: Gain 2 random combat dice rolled directly into pools
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 2
	card.general_ability.append(fx_1)
	
	# Ability 2: Conditional Morale check to force-rout all enemy Tier 0 units
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.HAS_MORE_MORALE_THAN_OPPONENT
	
	# Payout Node: Route all Command Level 0 units for the opponent
	var rout_all_fx = CardEffect.new()
	rout_all_fx.effect_type = CardData.EffectType.ROUT_ALL_COMMAND_LEVEL_0_UNITS
	rout_all_fx.target_type = CardData.TargetType.OPPONENT
	
	fx_2.choices.append(rout_all_fx)
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	# Condition Check: Verify if the opponent currently has any unrouted units left on the board
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_UNROUTED_UNITS
	
	# Payout Node: Unconditionally rout the enemy's highest-tier unrouted unit
	var rout_highest_fx = CardEffect.new()
	rout_highest_fx.effect_type = CardData.EffectType.ROUT_HIGHEST_TIER
	rout_highest_fx.target_type = CardData.TargetType.OPPONENT
	
	# Append the target routing payload to the unit ability cascade
	fx_u_1.choices.append(rout_highest_fx)
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 3001: Gretchin ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_GRETCHIN
	card.card_name = "Gretchin"
	card.card_tier = CardData.CardTier.STARTER
	card.required_unit_types = [CardData.UnitType.ONSLAUGHTS]
	
	# --- GENERAL ABILITY ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	fx_1.pool_type = CardData.CombatTokenType.OFFENSE # 🎯 Target Token Type
	card.general_ability.append(fx_1)
	
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_2.target_type = CardData.TargetType.SELF
	fx_2.value = 1
	fx_2.pool_type = CardData.CombatTokenType.DEFENSE # 🎯 Target Token Type
	card.general_ability.append(fx_2)
	
	fx_3 = CardEffect.new()
	fx_3.effect_type = CardData.EffectType.REROLL
	fx_3.target_type = CardData.TargetType.OPPONENT
	fx_3.value = 1
	card.general_ability.append(fx_3)
	
	# --- UNIT ABILITY ---
	# --- PART 1: SELF-SACRIFICE LINE ---
	# Self Branch A: Player has NO routed units -> Destroys 1 lowest tier standing unit
	var self_none = CardEffect.new()
	self_none.effect_type = CardData.EffectType.CONDITIONAL
	self_none.condition_type = CardData.ConditionType.HAS_NO_ROUTED_UNITS
	
	var act_self_none = CardEffect.new()
	act_self_none.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	act_self_none.target_type = CardData.TargetType.SELF
	act_self_none.value = 1
	act_self_none.destruction_mode = CardData.DestructionMode.ANY
	self_none.choices.append(act_self_none)
	
	# Self Branch B: Player HAS routed units -> Destroys 1 lowest tier routed unit
	var self_has = CardEffect.new()
	self_has.effect_type = CardData.EffectType.CONDITIONAL
	self_has.condition_type = CardData.ConditionType.HAS_ROUTED_UNITS
	
	var act_self_has = CardEffect.new()
	act_self_has.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	act_self_has.target_type = CardData.TargetType.SELF
	act_self_has.value = 1
	act_self_has.destruction_mode = CardData.DestructionMode.ROUTED
	self_has.choices.append(act_self_has)
	
	# --- PART 2: HOSTILE STRIKE LINE ---
	# Opponent Branch A: Opponent has NO routed units -> Destroys 1 enemy lowest tier standing unit
	var opp_none = CardEffect.new()
	opp_none.effect_type = CardData.EffectType.CONDITIONAL
	opp_none.condition_type = CardData.ConditionType.OPPONENT_HAS_NO_ROUTED_UNITS
	
	var act_opp_none = CardEffect.new()
	act_opp_none.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	act_opp_none.target_type = CardData.TargetType.OPPONENT
	act_opp_none.value = 1
	act_opp_none.destruction_mode = CardData.DestructionMode.ANY
	opp_none.choices.append(act_opp_none)
	
	# Opponent Branch B: Opponent HAS routed units -> Destroys 1 enemy lowest tier routed unit
	var opp_has = CardEffect.new()
	opp_has.effect_type = CardData.EffectType.CONDITIONAL
	opp_has.condition_type = CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS
	
	var act_opp_has = CardEffect.new()
	act_opp_has.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	act_opp_has.target_type = CardData.TargetType.OPPONENT
	act_opp_has.value = 1
	act_opp_has.destruction_mode = CardData.DestructionMode.ROUTED
	opp_has.choices.append(act_opp_has)
	
	# --- SEQUENCE ALIGNMENT ---
	card.unit_ability.append(self_none)
	card.unit_ability.append(self_has)
	card.unit_ability.append(opp_none)
	card.unit_ability.append(opp_has)
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.DISCARD_STEAL_ICONS
	fx_u_1.target_type = CardData.TargetType.OPPONENT
	card.unit_ability.append(fx_u_1)
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.pool_type = CardData.DicePoolType.OFFENSE # Targets dice
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.REROLL_SPECIFIC_DICE_FOR_EACH_UNIT
	fx_u_1.target_type = CardData.TargetType.OPPONENT
	fx_u_1.value = CardData.UnitType.ORK_BOYZ
	fx_u_1.pool_type = CardData.DicePoolType.OFFENSE # Targets dice
	card.unit_ability.append(fx_u_1)
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.pool_type = CardData.DicePoolType.DEFENSE # Targets dice
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.REROLL_SPECIFIC_DICE_FOR_EACH_UNIT
	fx_u_1.target_type = CardData.TargetType.OPPONENT
	fx_u_1.value = CardData.UnitType.ORK_BOYZ
	fx_u_1.pool_type = CardData.DicePoolType.DEFENSE # Targets dice
	card.unit_ability.append(fx_u_1)
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.pool_type = CardData.DicePoolType.MORALE # Targets dice
	card.general_ability.append(fx_1)
	
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	fx_2.target_type = CardData.TargetType.OPPONENT
	fx_2.pool_type = CardData.DicePoolType.MORALE # Targets dice
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.RALLY
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 1
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 3006: Waaagh ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_WAAAGH
	card.card_name = "Waaagh"
	card.card_tier = CardData.CardTier.TIER_0
	card.morale_icons = 3
	card.required_unit_types = [CardData.UnitType.ORK_BOYZ, CardData.UnitType.ONSLAUGHTS]
	
	# --- GENERAL ABILITY ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.RALLY
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.GAIN_TOKEN_PER_UNROUTED_UNIT
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 1
	fx_u_1.pool_type = CardData.CombatTokenType.OFFENSE # 🎯 Target Token Type
	fx_u_1.max_spend = CardData.UnitFilterMode.REQUIRED_TYPES
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 3007: Sea of Green ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_SEA_OF_GREEN
	card.card_name = "Sea of Green"
	card.card_tier = CardData.CardTier.TIER_0
	card.offence_icons = 1
	card.defence_icons = 1
	card.required_unit_types = []
	
	# --- GENERAL ABILITY 1 ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.SPAWN_REINFORCEMENT_TOKEN
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- GENERAL ABILITY 2 ---
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.OUTNUMBERING
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.ROUT_LOWEST_TIER_OR_SPEND_DICE
	node.target_type = CardData.TargetType.OPPONENT
	node.value = 1
	node.pool_type = CardData.DicePoolType.MORALE # Targets dice
	
	fx_2.choices = [node]
	card.general_ability.append(fx_2)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 3008: Mega Nobz ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_MEGA_NOBZ
	card.card_name = "Mega Nobz"
	card.card_tier = CardData.CardTier.TIER_0
	card.offence_icons = 1
	card.defence_icons = 2
	card.required_unit_types = [CardData.UnitType.NOBZ, CardData.UnitType.ONSLAUGHTS]
	
	# --- GENERAL ABILITY ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	fx_1.target_type = CardData.TargetType.OPPONENT
	fx_1.pool_type = CardData.DicePoolType.DEFENSE # Targets dice
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 1
	fx_u_1.pool_type = CardData.CombatTokenType.DEFENSE # 🎯 Target Token Type
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 3009: Biker Nobz ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_BIKER_NOBZ
	card.card_name = "Biker Nobz"
	card.card_tier = CardData.CardTier.TIER_0
	card.offence_icons = 2
	card.defence_icons = 1
	card.required_unit_types = [CardData.UnitType.NOBZ, CardData.UnitType.ONSLAUGHTS]
	
	# --- GENERAL ABILITY ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	fx_1.target_type = CardData.TargetType.OPPONENT
	fx_1.pool_type = CardData.DicePoolType.OFFENSE # Targets dice
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 1
	fx_u_1.pool_type = CardData.CombatTokenType.OFFENSE # 🎯 Target Token Type
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 3010: Weirdboyz ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_WEIRDBOYZ
	card.card_name = "Weirdboyz"
	card.card_tier = CardData.CardTier.TIER_2
	card.offence_icons = 1
	card.defence_icons = 1
	card.morale_icons = 1
	card.required_unit_types = [CardData.UnitType.ORK_BOYZ, CardData.UnitType.ONSLAUGHTS]
	
	# --- GENERAL ABILITY ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.REROLL
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 8
	card.general_ability.append(fx_1)
	
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.REROLL
	fx_2.target_type = CardData.TargetType.OPPONENT
	fx_2.value = 8
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.MIRROR_OPPONENT_TOKEN_GAINS
	fx_u_1.target_type = CardData.TargetType.SELF
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 3011: Party Wagon ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_PARTY_WAGON
	card.card_name = "Party Wagon"
	card.card_tier = CardData.CardTier.TIER_2
	card.offence_icons = 1
	card.defence_icons = 2
	card.required_unit_types = [CardData.UnitType.BATTLE_WAGONS, CardData.UnitType.KILL_KROOZERS]
	
	# --- GENERAL ABILITY ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.SPAWN_REINFORCEMENT_TOKEN
	fx_1.target_type = CardData.TargetType.SELF
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OUTNUMBERING
	
	# Step 1 inside outnumber sequence: Gain 2 Offence Tokens
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 2
	opt_a.pool_type = CardData.CombatTokenType.OFFENSE # 🎯 Target Token Type
	
	# Step 2 inside outnumber sequence: Gain 2 Defence Tokens
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 2
	opt_b.pool_type = CardData.CombatTokenType.DEFENSE # 🎯 Target Token Type
	
	fx_u_1.choices = [opt_a, opt_b]
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 3012: Rokkit Wagon ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_ROKKIT_WAGON
	card.card_name = "Rokkit Wagon"
	card.card_tier = CardData.CardTier.TIER_2
	card.offence_icons = 3
	card.required_unit_types = [CardData.UnitType.BATTLE_WAGONS, CardData.UnitType.KILL_KROOZERS]
	
	# --- GENERAL ABILITY ---
	# None
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 3
	fx_u_1.pool_type = CardData.CombatTokenType.OFFENSE # 🎯 Target Token Type
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 3013: Snapper Gargant ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_SNAPPER_GARGANT
	card.card_name = "Snapper Gargant"
	card.card_tier = CardData.CardTier.TIER_3
	card.offence_icons = 4
	card.defence_icons = 1
	card.required_unit_types = [CardData.UnitType.GARGANTS, CardData.UnitType.KILL_KROOZERS]
	
	# --- GENERAL ABILITY ---
	# None
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.OPPONENT_DISCARDS_BEST_FACEUP_CARD
	fx_u_1.target_type = CardData.TargetType.OPPONENT
	fx_u_1.value = 1
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 3014: Smasher Gargant ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_SMASHER_GARGANT
	card.card_name = "Smasher Gargant"
	card.card_tier = CardData.CardTier.TIER_3
	card.offence_icons = 2
	card.defence_icons = 3
	card.required_unit_types = [CardData.UnitType.GARGANTS, CardData.UnitType.KILL_KROOZERS]
	
	# --- GENERAL ABILITY ---
	# None
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.DESTROY_OR_SPEND_DICE_BASED_ON_TIER
	fx_u_1.target_type = CardData.TargetType.OPPONENT
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 4001: Hit and Run ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ELDAR_HIT_AND_RUN
	card.card_name = "Hit and Run"
	card.card_tier = CardData.CardTier.STARTER
	card.offence_icons = 1
	card.required_unit_types = [CardData.UnitType.ASPECT_WARRIORS, CardData.UnitType.HELLEBORE_FRIGATES]
	
	# --- GENERAL ABILITY ---
	# Ability 1: Gain 2 Offence Combat Tokens
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 2
	fx_1.pool_type = CardData.CombatTokenType.OFFENSE # 🎯 Target Token Type
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# Pending custom logic implementation
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 4002: Howling Banshees ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ELDAR_HOWLING_BANSHEES
	card.card_name = "Howling Banshees"
	card.card_tier = CardData.CardTier.STARTER
	card.offence_icons = 1
	card.required_unit_types = [CardData.UnitType.ASPECT_WARRIORS, CardData.UnitType.HELLEBORE_FRIGATES]
	
	# --- GENERAL ABILITY ---
	# Ability 1: Gain 1 dice
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# If you have morale dice and opponent has unrouted units, opponent routs his unit
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.HAS_MORALE_DICE_AND_OPPONENT_HAS_UNROUTED_UNITS
	
	# Payout Node: Rout the lowest-tier living unrouted unit on the enemy side
	var rout_lowest_fx = CardEffect.new()
	rout_lowest_fx.effect_type = CardData.EffectType.ROUT_LOWEST_TIER
	rout_lowest_fx.target_type = CardData.TargetType.OPPONENT
	
	# Append payout token into the conditional branching cascade
	fx_u_1.choices.append(rout_lowest_fx)
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 4003: Striking Scorpions ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ELDAR_STRIKING_SCORPIONS
	card.card_name = "Striking Scorpions"
	card.card_tier = CardData.CardTier.STARTER
	card.defence_icons = 1
	card.required_unit_types = [CardData.UnitType.ASPECT_WARRIORS, CardData.UnitType.HELLEBORE_FRIGATES]
	
	# --- GENERAL ABILITY ---
	# Ability 1: Gain 1 random combat die rolled directly into pools
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# Ability 1: Opponent loses 1 random combat die (pool_type = 0 specifies random loss)
	var fx_u = CardEffect.new()
	fx_u.effect_type = CardData.EffectType.LOSE_DICE
	fx_u.target_type = CardData.TargetType.OPPONENT
	fx_u.value = 1
	card.unit_ability.append(fx_u)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 4004: Ranger Support ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ELDAR_RANGER_SUPPORT
	card.card_name = "Ranger Support"
	card.card_tier = CardData.CardTier.STARTER
	card.defence_icons = 1
	card.morale_icons = 1
	card.required_unit_types = []
	
	# --- GENERAL ABILITY ---
	# Condition Check: Evaluate if the active side is the attacker in this matchup
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.IS_ATTACKING
	
	# Payout Node A: Gain 1 Offence Combat Token
	var token_off = CardEffect.new()
	token_off.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	token_off.target_type = CardData.TargetType.SELF
	token_off.value = 1
	token_off.pool_type = CardData.CombatTokenType.OFFENSE # 🎯 Target Token Type
	
	# Payout Node B: Gain 1 Defence Combat Token
	var token_def = CardEffect.new()
	token_def.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	token_def.target_type = CardData.TargetType.SELF
	token_def.value = 1
	token_def.pool_type = CardData.CombatTokenType.DEFENSE # 🎯 Target Token Type
	
	# Append sequential combat token payout items to the conditional gate
	fx_1.choices.append(token_off)
	fx_1.choices.append(token_def)
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# None
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 4005: Command of the Autarch ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = 4005
	card.card_name = "Command of the Autarch"
	card.card_tier = CardData.CardTier.STARTER
	card.required_unit_types = []
	
	# --- GENERAL ABILITY ---
	# Ability 1 - Branch 1: Player has NO routed units -> Gain 1 Morale Die
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.HAS_NO_ROUTED_UNITS
	
	var morale_node = CardEffect.new()
	morale_node.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	morale_node.target_type = CardData.TargetType.SELF
	morale_node.value = 1
	morale_node.pool_type = CardData.DicePoolType.MORALE # Targets dice
	
	fx_1.choices = [morale_node]
	
	# Ability 1 - Branch 2: Player HAS routed units -> Execute Rally sequence
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.HAS_ROUTED_UNITS
	
	var rally_node = CardEffect.new()
	rally_node.effect_type = CardData.EffectType.RALLY
	rally_node.target_type = CardData.TargetType.SELF
	rally_node.value = 1
	
	fx_2.choices = [rally_node]
	
	# Appending the negative check first prevents the state mutation side-effect cascade
	card.general_ability.append(fx_1)
	card.general_ability.append(fx_2)
	
	# Ability 2: Deploy a random card to the play area without executing its logic steps
	fx_3 = CardEffect.new()
	fx_3.effect_type = CardData.EffectType.PLAY_RANDOM_CARD_DO_NOT_RESOLVE_ABILITIES
	fx_3.target_type = CardData.TargetType.SELF
	card.general_ability.append(fx_3)
	
	# --- UNIT ABILITY ---
	# Pending implementation details
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 4006: Fire Dragon's Vengeance ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ELDAR_FIRE_DRAGONS_VENGEANCE
	card.card_name = "Fire Dragon's Vengeance"
	card.card_tier = CardData.CardTier.TIER_0
	card.offence_icons = 2
	card.required_unit_types = [CardData.UnitType.ASPECT_WARRIORS, CardData.UnitType.HELLEBORE_FRIGATES]
	
	# --- GENERAL ABILITY ---
	# Condition Check: If the player is the Attacker this combat round
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.IS_ATTACKING
	
	# Payout: Opponent cannot gain defense tokens this round
	var prevent_node = CardEffect.new()
	prevent_node.effect_type = CardData.EffectType.PREVENT_OPPONENT_GAINING_DEFENSE_TOKENS_THIS_ROUND
	prevent_node.target_type = CardData.TargetType.OPPONENT
	
	fx_1.choices.append(prevent_node)
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# Gain 2 Defence Tokens
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 2
	fx_u_1.pool_type = CardData.CombatTokenType.DEFENSE
	
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 4007: Swooping Hawks ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ELDAR_SWOOPING_HAWKS
	card.card_name = "Swooping Hawks"
	card.card_tier = CardData.CardTier.TIER_0
	card.defence_icons = 2
	card.required_unit_types = [CardData.UnitType.ASPECT_WARRIORS, CardData.UnitType.HELLEBORE_FRIGATES]
	
	# --- GENERAL ABILITY ---
	# Condition Check: If the player is the Defender this combat round
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.IS_DEFENDING
	
	# Payout Node: Opponent loses 3 Offence tokens
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_a.target_type = CardData.TargetType.OPPONENT
	opt_a.pool_type = CardData.CombatTokenType.OFFENSE
	opt_a.value = -3
	
	fx_1.choices.append(opt_a)
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# Conversion Node: Spend Morale dice to gain 2 Offence tokens per die consumed
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.pool_type = CardData.DicePoolType.MORALE          # Source asset consumed
	fx_u_1.gain_token_type = CardData.CombatTokenType.OFFENSE
	fx_u_1.value = 2
	
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 4008: Wraithguard Advance ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ELDAR_WRAITHGUARD_ADVANCE
	card.card_name = "Wraithguard Advance"
	card.card_tier = CardData.CardTier.TIER_0
	card.offence_icons = 1
	card.morale_icons = 1
	card.required_unit_types = [
		CardData.UnitType.WRAITHGUARDS, 
		CardData.UnitType.HELLEBORE_FRIGATES, 
		CardData.UnitType.VOID_STALKERS
	]
	
	# --- GENERAL ABILITY 1 ---
	# Choice Selection: Gain 1 random combat die OR 1 explicit Morale die
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CHOICE
	fx_1.target_type = CardData.TargetType.SELF
	
	# Option A: Roll 1 completely random combat die into pools
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_DICE
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 1
	
	# Option B: Allocate 1 specific Morale die directly
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 1
	opt_b.pool_type = CardData.DicePoolType.MORALE
	
	fx_1.choices = [opt_a, opt_b]
	card.general_ability.append(fx_1)
	
	# --- GENERAL ABILITY 2 ---
	# Conversion Node: Convert up to 2 Defence dice into Offence dice
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONVERT_DICE_TO_SPECIFIC_DICE
	fx_2.target_type = CardData.TargetType.SELF
	fx_2.value = 2
	fx_2.pool_type = CardData.DicePoolType.OFFENSE # Target/Destination type (fx[3])
	fx_2.max_spend = CardData.DicePoolType.DEFENSE # Strict Source Constraint type (fx[6])
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	# Branch A: Opponent has Morale dice AND unrouted units -> Strip 1 Morale die
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_MORALE_DICE_AND_OPPONENT_HAS_UNROUTED_UNITS
	
	opt_u_a = CardEffect.new()
	opt_u_a.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_u_a.target_type = CardData.TargetType.OPPONENT
	opt_u_a.value = 1
	opt_u_a.pool_type = CardData.DicePoolType.MORALE # Targets dice
	
	fx_u_1.choices.append(opt_u_a)
	card.unit_ability.append(fx_u_1)
	
	# Branch B (Otherwise): Opponent has NO Morale dice BUT has unrouted units -> Rout lowest tier
	fx_u_2 = CardEffect.new()
	fx_u_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_2.condition_type = CardData.ConditionType.OPPONENT_HAS_NO_MORALE_DICE_AND_OPPONENT_HAS_UNROUTED_UNITS
	
	opt_u_b = CardEffect.new()
	opt_u_b.effect_type = CardData.EffectType.ROUT_LOWEST_TIER
	opt_u_b.target_type = CardData.TargetType.OPPONENT
	opt_u_b.value = 1
	
	fx_u_2.choices.append(opt_u_b)
	card.unit_ability.append(fx_u_2)
	
	db[card.card_id] = card
	
	return db
