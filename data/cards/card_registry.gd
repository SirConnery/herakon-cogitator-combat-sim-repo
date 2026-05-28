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
	fx_1.pool_type = CardData.DicePoolType.OFFENSE
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
	opt_a.pool_type = CardData.DicePoolType.OFFENSE
	
	# Option B: Gain 2 Defence Tokens
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 2
	opt_b.pool_type = CardData.DicePoolType.DEFENSE
	
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
	fx_1.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(fx_1)

	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CHOICE
	fx_2.target_type = CardData.TargetType.SELF

	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.REROLL
	opt_a.target_type = CardData.TargetType.SELF
	fx_1.pool_type = CardData.DicePoolType.DEFENSE
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
	opt_u_a.pool_type = CardData.DicePoolType.DEFENSE

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
	opt_u_b.pool_type = CardData.DicePoolType.DEFENSE

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
	fx_1.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONVERT_DICE_TO_SPECIFIC_DICE
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 2
	fx_u_1.pool_type = CardData.DicePoolType.DEFENSE
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
	opt_b.pool_type = CardData.DicePoolType.MORALE
	
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
	fx_1.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(fx_1)
	
	# Part 2: Rally if defending
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.DEFENDING
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.RALLY
	node.target_type = CardData.TargetType.SELF
	node.value = 1
	
	fx_1.choices = [node]
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# Gain 1 Defence dice OR 1 Morale dice
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CHOICE
	fx_u_1.target_type = CardData.TargetType.SELF
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 1
	opt_a.pool_type = CardData.DicePoolType.DEFENSE
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 1
	opt_b.pool_type = CardData.DicePoolType.MORALE
	
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
	fx_1.pool_type = CardData.DicePoolType.OFFENSE
	card.general_ability.append(fx_1)
	
	# Part 2: Rally if attacking
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.ATTACKING
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.RALLY
	node.target_type = CardData.TargetType.SELF
	node.value = 1
	
	fx_1.choices = [node]
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# Tactical choice block
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CHOICE
	fx_u_1.target_type = CardData.TargetType.OPPONENT
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_a.target_type = CardData.TargetType.OPPONENT
	opt_a.value = 1
	opt_a.pool_type = CardData.DicePoolType.DEFENSE
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_b.target_type = CardData.TargetType.OPPONENT
	opt_b.value = 1
	opt_b.pool_type = CardData.DicePoolType.MORALE
	
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
	opt_a.pool_type = CardData.DicePoolType.MORALE
	
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
	fx_1.pool_type = CardData.DicePoolType.MORALE   # The source dice pool to count (fx_1[3])
	fx_1.max_spend = CardData.DicePoolType.RANDOM   # The target token category to reward (fx_1[6])
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
	opt_a.pool_type = CardData.DicePoolType.MORALE
	
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
	fx_1.pool_type = CardData.DicePoolType.MORALE
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
	fx_u_1.value = 2 # Multiplier: Tokens gained per single die consumed
	fx_u_1.pool_type = CardData.DicePoolType.OFFENSE
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
	node.pool_type = CardData.DicePoolType.DEFENSE
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
	fx_u_1.pool_type = CardData.DicePoolType.OFFENSE
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
	fx_1.pool_type = CardData.DicePoolType.MORALE
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
	opt_a.pool_type = CardData.DicePoolType.OFFENSE
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 2
	opt_b.pool_type = CardData.DicePoolType.DEFENSE
	
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
	# Setup Branch 1: Player has NO Morale dice -> Converts 1 Offence Die
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.HAS_NO_MORALE_DICE
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.pool_type = CardData.DicePoolType.OFFENSE
	opt_a.value = 3
	opt_a.max_spend = 1
	fx_1.choices.append(opt_a)
	
	# Setup Branch 2: Player HAS Morale dice -> Converts 1 Morale Die
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.pool_type = CardData.DicePoolType.MORALE
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
	opt_u_b.pool_type = CardData.DicePoolType.DEFENSE
	opt_u_b.value = 1
	fx_u_2.choices.append(opt_u_b)
	
	card.unit_ability.append(fx_u_1)
	card.unit_ability.append(fx_u_2)
	
	db[card.card_id] = card
	
	
	
	# ==========================================================================
	# --- CARD 3001: Gretchin ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_GRETCHIN
	card.card_name = "Gretchin"
	card.card_tier = CardData.CardTier.STARTER
	card.required_unit_types = [CardData.UnitType.ONSLAUGHTS]
	
	# --- GENERAL ABILITY (Kept intact from core Gretchin layout) ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	fx_1.pool_type = CardData.DicePoolType.OFFENSE
	card.general_ability.append(fx_1)
	
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_2.target_type = CardData.TargetType.SELF
	fx_2.value = 1
	fx_2.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(fx_2)
	
	fx_3 = CardEffect.new()
	fx_3.effect_type = CardData.EffectType.REROLL
	fx_3.target_type = CardData.TargetType.OPPONENT
	fx_3.value = 1
	card.general_ability.append(fx_3)
	
	# --- UNIT ABILITY (The Chained Primitive Replacement Layout) ---
	
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
	# Appending negatives first ensures clean, single-execution isolation per team side.
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
	fx_1.pool_type = CardData.DicePoolType.OFFENSE
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.REROLL_SPECIFIC_DICE_FOR_EACH_UNIT
	fx_u_1.target_type = CardData.TargetType.OPPONENT
	fx_u_1.value = CardData.UnitType.ORK_BOYZ
	fx_u_1.pool_type = CardData.DicePoolType.OFFENSE
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
	fx_1.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.REROLL_SPECIFIC_DICE_FOR_EACH_UNIT
	fx_u_1.target_type = CardData.TargetType.OPPONENT
	fx_u_1.value = CardData.UnitType.ORK_BOYZ
	fx_u_1.pool_type = CardData.DicePoolType.DEFENSE
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
	fx_1.pool_type = CardData.DicePoolType.MORALE
	card.general_ability.append(fx_1)
	
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	fx_1.target_type = CardData.TargetType.OPPONENT
	fx_1.pool_type = CardData.DicePoolType.MORALE
	card.general_ability.append(fx_1)
	
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
	# Explicitly scales offense tokens from only the unit types required by this card
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.GAIN_TOKEN_PER_UNROUTED_UNIT
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 1
	fx_u_1.pool_type = CardData.DicePoolType.OFFENSE
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
	# Spawn tier 0 unit
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.SPAWN_REINFORCEMENT_TOKEN
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- GENERAL ABILITY 2 ---
	# If outnumbering opponent, opponent routs or spends morale
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.OUTNUMBERING
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.ROUT_LOWEST_TIER_OR_SPEND_DICE
	node.target_type = CardData.TargetType.OPPONENT
	node.value = 1
	node.pool_type = CardData.DicePoolType.MORALE
	
	fx_1.choices = [node]
	card.general_ability.append(fx_1)
	
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
	fx_1.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 1
	fx_u_1.pool_type = CardData.DicePoolType.DEFENSE
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
	fx_1.pool_type = CardData.DicePoolType.OFFENSE
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 1
	fx_u_1.pool_type = CardData.DicePoolType.OFFENSE
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
	
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.REROLL
	fx_1.target_type = CardData.TargetType.OPPONENT
	fx_1.value = 8
	card.general_ability.append(fx_1)
	
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
	# Triggers the dynamic tier-0 ground/space unit spawner we just fixed
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.SPAWN_REINFORCEMENT_TOKEN
	fx_1.target_type = CardData.TargetType.SELF
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	# Refactored compound token logic into an atomic, conditional sequence block
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OUTNUMBERING
	
	# Step 1 inside outnumber sequence: Gain 2 Offence Tokens
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 2
	opt_a.pool_type = CardData.DicePoolType.OFFENSE
	
	# Step 2 inside outnumber sequence: Gain 2 Defence Tokens
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 2
	opt_b.pool_type = CardData.DicePoolType.DEFENSE
	
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
	fx_u_1.pool_type = CardData.DicePoolType.OFFENSE
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
	
	
	
	
	return db
