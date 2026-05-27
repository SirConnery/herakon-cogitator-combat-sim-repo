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
	
	
}

static func get_database() -> Dictionary:
	var db := {}
	var card: CardData
	
	var fx: CardEffect
	var fx_2: CardEffect
	var node: CardEffect
	var opt_a: CardEffect
	var opt_b: CardEffect
	var opt_c: CardEffect
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_COMBAT_TOKEN
	fx.target_type = CardData.TargetType.SELF
	fx.value = 2
	fx.pool_type = CardData.DicePoolType.OFFENSE
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.DESTROY_ON_ROUT_OR_SPEND
	fx.target_type = CardData.TargetType.OPPONENT
	fx.value = 1 
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CHOICE
	fx.target_type = CardData.TargetType.SELF
	
	# Option A: Gain 2 Offence Tokens
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_COMBAT_TOKEN
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 2
	opt_a.pool_type = CardData.DicePoolType.OFFENSE
	
	# Option B: Gain 2 Defence Tokens
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_COMBAT_TOKEN
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 2
	opt_b.pool_type = CardData.DicePoolType.DEFENSE
	
	fx.choices = [opt_a, opt_b]
	card.general_ability.append(fx)
	
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
	# Rule 1: Opponent rerolls 1 specific Defence (Shield) die
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.REROLL
	fx.target_type = CardData.TargetType.OPPONENT
	fx.value = 1
	fx.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(fx)
	
	# Rule 2: Synchronized Choice Node
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CHOICE
	fx.target_type = CardData.TargetType.SELF
	
	# Option A: Execute the 1-die self-reroll sequence
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.REROLL
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 1
	
	# Option B: Decline the option and pass seamlessly
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.NONE
	opt_b.target_type = CardData.TargetType.SELF
	
	fx.choices = [opt_a, opt_b]
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	# Shield pressure: Strip 2 shield tokens; if opponent has 0 tokens, destroy 1 shield dice instead
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.LOSE_TOKENS_OR_DICE
	fx.target_type = CardData.TargetType.OPPONENT
	fx.value = 2        # Token tax amount
	fx.max_spend = 1    # Fallback die tax amount if token pool is empty
	fx.pool_type = CardData.DicePoolType.DEFENSE
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_COMBAT_TOKEN
	fx.target_type = CardData.TargetType.SELF
	fx.value = 2
	fx.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CONVERT_DICE_TO_SPECIFIC_DICE
	fx.target_type = CardData.TargetType.SELF
	fx.value = 2
	fx.pool_type = CardData.DicePoolType.DEFENSE
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_DICE
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1
	card.general_ability.append(fx)
	
	# Unit Choice Effect
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CHOICE
	fx.target_type = CardData.TargetType.SELF
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.RALLY
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 1
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 1
	opt_b.pool_type = CardData.DicePoolType.MORALE
	
	fx.choices = [opt_a, opt_b]
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_COMBAT_TOKEN
	fx.target_type = CardData.TargetType.SELF
	fx.value = 2
	fx.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(fx)
	
	# Part 2: Rally if defending
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CONDITIONAL
	fx.condition_type = CardData.ConditionType.DEFENDING
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.RALLY
	node.target_type = CardData.TargetType.SELF
	node.value = 1
	
	fx.choices = [node]
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	# Gain 1 Defence dice OR 1 Morale dice
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CHOICE
	fx.target_type = CardData.TargetType.SELF
	
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
	
	fx.choices = [opt_a, opt_b]
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_COMBAT_TOKEN
	fx.target_type = CardData.TargetType.SELF
	fx.value = 2
	fx.pool_type = CardData.DicePoolType.OFFENSE
	card.general_ability.append(fx)
	
	# Part 2: Rally if attacking
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CONDITIONAL
	fx.condition_type = CardData.ConditionType.ATTACKING
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.RALLY
	node.target_type = CardData.TargetType.SELF
	node.value = 1
	
	fx.choices = [node]
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	# Tactical choice block
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CHOICE
	fx.target_type = CardData.TargetType.OPPONENT
	
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
	
	fx.choices = [opt_a, opt_b]
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_DICE
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	# Spend 1 morale dice to place Space Marine
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CONDITIONAL
	fx.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
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
	
	fx.choices = [opt_a, opt_b]
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_TOKEN_PER_SPECIFIC_DICE
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1                                 # Multiplier: 1 token per die
	fx.pool_type = CardData.DicePoolType.MORALE   # The source dice pool to count (fx[3])
	fx.max_spend = CardData.DicePoolType.RANDOM   # The target token category to reward (fx[6])
	card.general_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.PREVENT_ROUTING_THIS_ROUND
	fx.target_type = CardData.TargetType.SELF
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	# Spend 1 morale to rally all units
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CONDITIONAL
	fx.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
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
	
	fx.choices = [opt_a, opt_b]
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.SPEND_MORALE_TO_GAIN_SPECIFIC_DICE
	fx.target_type = CardData.TargetType.SELF
	fx.value = 3
	fx.pool_type = CardData.DicePoolType.RANDOM
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	# The opponent discards 1 of his faceup combat cards
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.OPPONENT_DISCARDS_WORST_FACEUP_CARD
	fx.target_type = CardData.TargetType.OPPONENT
	fx.value = 1
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_DICE
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1
	card.general_ability.append(fx)
	
	# Unit ability: Resolve an additional assess damage step this round
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.ADDITIONAL_ASSESS_DAMAGE_STEP_THIS_ROUND
	fx.target_type = CardData.TargetType.SELF
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_DICE
	fx.target_type = CardData.TargetType.SELF
	fx.value = 2
	card.general_ability.append(fx)
	
	# Unit ability: Spend any number of Offence dice. For each spent, gain 2 offence tokens.
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKEN
	fx.target_type = CardData.TargetType.SELF
	fx.value = 2 # Multiplier: Tokens gained per single die consumed
	fx.pool_type = CardData.DicePoolType.OFFENSE
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_DICE
	fx.target_type = CardData.TargetType.SELF
	fx.value = 2
	card.general_ability.append(fx)
	
	# Unit ability 1: Rally all units
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.RALLY_ALL_FRIENDLY_UNITS
	fx.target_type = CardData.TargetType.SELF
	card.unit_ability.append(fx)
	
	# Unit ability 2: Strategic Morale Conversion
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CONVERT_SAFE_DICE_TO_MORALE
	fx.target_type = CardData.TargetType.SELF
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKEN
	fx.target_type = CardData.TargetType.SELF
	fx.value = 3
	fx.max_spend = 1
	fx.pool_type = CardData.DicePoolType.OFFENSE
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	# Rout unit or spend 1 Defence dice
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.ROUT_LOWEST_TIER_OR_SPEND_DICE
	fx.target_type = CardData.TargetType.OPPONENT
	fx.value = 1
	fx.pool_type = CardData.DicePoolType.DEFENSE
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_DICE
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CONDITIONAL
	fx.condition_type = CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.GAIN_TOKEN_PER_UNROUTED_UNIT
	node.target_type = CardData.TargetType.SELF
	node.value = 1
	node.pool_type = CardData.DicePoolType.DEFENSE
	node.max_spend = CardData.UnitFilterMode.REQUIRED_TYPES
	
	fx.choices = [node]
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CONDITIONAL
	fx.condition_type = CardData.ConditionType.HAS_MORE_MORALE_THAN_OPPONENT
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.RALLY
	node.target_type = CardData.TargetType.SELF
	node.value = 1
	
	fx.choices = [node]
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	# Gain 1 offence token per unrouted tier 0 unit
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_TOKEN_PER_UNROUTED_UNIT
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1
	fx.pool_type = CardData.DicePoolType.OFFENSE
	fx.max_spend = CardData.UnitFilterMode.REQUIRED_TYPES
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1
	fx.pool_type = CardData.DicePoolType.MORALE
	card.general_ability.append(fx)
	
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
	
	# Setup Branch 1: Opponent has unrouted units
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CONDITIONAL
	fx.condition_type = CardData.ConditionType.OPPONENT_HAS_UNROUTED_UNITS
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.ROUT_LOWEST_TIER
	opt_a.target_type = CardData.TargetType.OPPONENT
	opt_a.value = 1
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_DICE
	opt_b.target_type = CardData.TargetType.OPPONENT
	opt_b.value = 1
	
	fx.choices.append(opt_a)
	fx.choices.append(opt_b)
	
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
	card.general_ability.append(fx)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 3001: Gretchin ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ORKS_GRETCHIN
	card.card_name = "Gretchin"
	card.card_tier = CardData.CardTier.STARTER
	card.required_unit_types = [CardData.UnitType.ONSLAUGHTS]
	
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_COMBAT_TOKEN
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1
	fx.pool_type = CardData.DicePoolType.OFFENSE
	card.general_ability.append(fx)
	
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_COMBAT_TOKEN
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1
	fx.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(fx)
	
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.REROLL
	fx.target_type = CardData.TargetType.OPPONENT
	fx.value = 1
	card.general_ability.append(fx)
	
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.DESTROY_FOR_DESTROY
	fx.target_type = CardData.TargetType.OPPONENT
	fx.value = 1
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_DICE
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.DISCARD_STEAL_ICONS
	fx.target_type = CardData.TargetType.OPPONENT
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	fx.target_type = CardData.TargetType.SELF
	fx.pool_type = CardData.DicePoolType.OFFENSE
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.REROLL_SPECIFIC_DICE_FOR_EACH_UNIT
	fx.target_type = CardData.TargetType.OPPONENT
	fx.value = CardData.UnitType.ORK_BOYZ
	fx.pool_type = CardData.DicePoolType.OFFENSE
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	fx.target_type = CardData.TargetType.SELF
	fx.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.REROLL_SPECIFIC_DICE_FOR_EACH_UNIT
	fx.target_type = CardData.TargetType.OPPONENT
	fx.value = CardData.UnitType.ORK_BOYZ
	fx.pool_type = CardData.DicePoolType.DEFENSE
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	fx.target_type = CardData.TargetType.SELF
	fx.pool_type = CardData.DicePoolType.MORALE
	card.general_ability.append(fx)
	
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	fx.target_type = CardData.TargetType.OPPONENT
	fx.pool_type = CardData.DicePoolType.MORALE
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.RALLY
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.RALLY
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	# Explicitly scales offense tokens from only the unit types required by this card
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_TOKEN_PER_UNROUTED_UNIT
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1
	fx.pool_type = CardData.DicePoolType.OFFENSE
	fx.max_spend = CardData.UnitFilterMode.REQUIRED_TYPES
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.SPAWN_REINFORCEMENT_TOKEN
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1
	card.general_ability.append(fx)
	
	# --- GENERAL ABILITY 2 ---
	# If outnumbering opponent, opponent routs or spends morale
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CONDITIONAL
	fx.condition_type = CardData.ConditionType.OUTNUMBERING
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.ROUT_LOWEST_TIER_OR_SPEND_DICE
	node.target_type = CardData.TargetType.OPPONENT
	node.value = 1
	node.pool_type = CardData.DicePoolType.MORALE
	
	fx.choices = [node]
	card.general_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	fx.target_type = CardData.TargetType.OPPONENT
	fx.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_COMBAT_TOKEN
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1
	fx.pool_type = CardData.DicePoolType.DEFENSE
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	fx.target_type = CardData.TargetType.OPPONENT
	fx.pool_type = CardData.DicePoolType.OFFENSE
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_COMBAT_TOKEN
	fx.target_type = CardData.TargetType.SELF
	fx.value = 1
	fx.pool_type = CardData.DicePoolType.OFFENSE
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.REROLL
	fx.target_type = CardData.TargetType.SELF
	fx.value = 8
	card.general_ability.append(fx)
	
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.REROLL
	fx.target_type = CardData.TargetType.OPPONENT
	fx.value = 8
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.MIRROR_OPPONENT_TOKEN_GAINS
	fx.target_type = CardData.TargetType.SELF
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.SPAWN_REINFORCEMENT_TOKEN
	fx.target_type = CardData.TargetType.SELF
	card.general_ability.append(fx)
	
	# --- UNIT ABILITY ---
	# Refactored compound token logic into an atomic, conditional sequence block
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.CONDITIONAL
	fx.condition_type = CardData.ConditionType.OUTNUMBERING
	
	# Step 1 inside outnumber sequence: Gain 2 Offence Tokens
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_COMBAT_TOKEN
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 2
	opt_a.pool_type = CardData.DicePoolType.OFFENSE
	
	# Step 2 inside outnumber sequence: Gain 2 Defence Tokens
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_COMBAT_TOKEN
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 2
	opt_b.pool_type = CardData.DicePoolType.DEFENSE
	
	fx.choices = [opt_a, opt_b]
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.GAIN_COMBAT_TOKEN
	fx.target_type = CardData.TargetType.SELF
	fx.value = 3
	fx.pool_type = CardData.DicePoolType.OFFENSE
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.OPPONENT_DISCARDS_BEST_FACEUP_CARD
	fx.target_type = CardData.TargetType.OPPONENT
	fx.value = 1
	card.unit_ability.append(fx)
	
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
	fx = CardEffect.new()
	fx.effect_type = CardData.EffectType.DESTROY_OR_SPEND_DICE_BASED_ON_TIER
	fx.target_type = CardData.TargetType.OPPONENT
	card.unit_ability.append(fx)
	
	db[card.card_id] = card
	
	return db
