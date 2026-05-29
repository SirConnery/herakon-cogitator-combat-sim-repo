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
	ELDAR_WRAITHGUARD_SUPPORT    = 4009,
	ELDAR_FIRE_PRISM             = 4010,
	ELDAR_WAVE_SERPENT           = 4011,
	ELDAR_SPRITSEERS_GUIDANCE    = 4012,
	ELDAR_HOLOFIELD_EMITTER      = 4013,
	ELDAR_PSYCHIC_LANCE          = 4014,
	
	
	
	
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
	var inner_gate: CardEffect
	var opt_u_true: CardEffect
	var opt_u_else: CardEffect
	var opt_u_false: CardEffect
	var fork: CardEffect
	var opt_fork_true: CardEffect
	var opt_fork_else: CardEffect
	
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
	opt_a.pool_type = CardData.CombatTokenType.OFFENSE
	
	# Option B: Gain 2 Defence Tokens
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 2
	opt_b.pool_type = CardData.CombatTokenType.DEFENSE
	
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
	opt_a.pool_type = CardData.DicePoolType.DEFENSE
	opt_a.value = 1

	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.NONE
	opt_b.target_type = CardData.TargetType.SELF

	fx_2.choices = [opt_a, opt_b]
	card.general_ability.append(fx_2)

	# --- UNIT ABILITY (Refactored to single If/Else node) ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_TWO_OR_MORE_DEFENSE_TOKENS
	
	# IF TRUE: Standard Tax -> Strip 2 Shield/Defense tokens
	opt_u_true = CardEffect.new()
	opt_u_true.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_u_true.target_type = CardData.TargetType.OPPONENT
	opt_u_true.value = -2
	opt_u_true.pool_type = CardData.CombatTokenType.DEFENSE
	fx_u_1.choices.append(opt_u_true)

	# IF FALSE / ELSE: Fallback Penalty -> Destroy 1 Shield/Defense die
	opt_u_false = CardEffect.new()
	opt_u_false.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_u_false.target_type = CardData.TargetType.OPPONENT
	opt_u_false.value = 1
	opt_u_false.pool_type = CardData.DicePoolType.DEFENSE
	fx_u_1.else_choices.append(opt_u_false)

	card.unit_ability.append(fx_u_1)

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
	fx_1.pool_type = CardData.CombatTokenType.DEFENSE
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 2
	fx_1.pool_type = CardData.CombatTokenType.DEFENSE
	card.general_ability.append(fx_1)
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 2
	fx_1.pool_type = CardData.CombatTokenType.OFFENSE
	card.general_ability.append(fx_1)
	
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
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 1
	opt_a.pool_type = CardData.DicePoolType.MORALE
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_TOKEN_PER_SPECIFIC_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	fx_1.pool_type = CardData.DicePoolType.MORALE
	fx_1.max_spend = 0
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
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 1
	opt_a.pool_type = CardData.DicePoolType.MORALE
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONVERT_DICE_TO_RANDOM_DIFFERENT_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 3
	fx_1.pool_type = CardData.DicePoolType.MORALE
	card.general_ability.append(fx_1)

	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.DISCARD_WORST_FACEUP_CARD
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
	
	# General ability
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# Unit ability
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
	
	# General ability
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 2
	card.general_ability.append(fx_1)
	
	# Unit ability
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 2
	fx_u_1.pool_type = CardData.DicePoolType.OFFENSE
	fx_u_1.gain_token_type = CardData.CombatTokenType.OFFENSE
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
	
	# General ability
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 2
	card.general_ability.append(fx_1)
	
	# Unit ability 1
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.RALLY_ALL_FRIENDLY_UNITS
	fx_u_1.target_type = CardData.TargetType.SELF
	card.unit_ability.append(fx_u_1)
	
	# Unit ability 2
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 3
	fx_1.max_spend = 1
	fx_1.pool_type = CardData.DicePoolType.OFFENSE
	fx_1.gain_token_type = CardData.CombatTokenType.OFFENSE 
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
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
	node.pool_type = CardData.CombatTokenType.DEFENSE
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
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.GAIN_TOKEN_PER_UNROUTED_UNIT
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 1
	fx_u_1.pool_type = CardData.CombatTokenType.OFFENSE
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
	
	# --- GENERAL ABILITY (Refactored to clean If/Else structure) ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.OPPONENT_HAS_UNROUTED_UNITS
	
	# IF TRUE: Rout enemy lowest tier and grant them 1 die
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
	
	# IF FALSE / ELSE: Spawn reinforcement token on friendly side
	var opt_else = CardEffect.new()
	opt_else.effect_type = CardData.EffectType.SPAWN_REINFORCEMENT_TOKEN
	opt_else.target_type = CardData.TargetType.SELF
	opt_else.value = 1
	fx_1.else_choices.append(opt_else)
	
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CHOICE
	
	opt_u_a = CardEffect.new()
	opt_u_a.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_u_a.target_type = CardData.TargetType.SELF
	opt_u_a.value = 2
	opt_u_a.pool_type = CardData.CombatTokenType.OFFENSE
	
	opt_u_b = CardEffect.new()
	opt_u_b.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_u_b.target_type = CardData.TargetType.SELF
	opt_u_b.value = 2
	opt_u_b.pool_type = CardData.CombatTokenType.DEFENSE
	
	fx_u_1.choices.append(opt_u_a)
	fx_u_1.choices.append(opt_u_b)
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
	
	# --- GENERAL ABILITY (Refactored to If/Else structure) ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
	# IF TRUE: Convert 1 Morale Die to 3 Offence Tokens
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.pool_type = CardData.DicePoolType.MORALE
	opt_a.gain_token_type = CardData.CombatTokenType.OFFENSE
	opt_a.value = 3
	opt_a.max_spend = 1
	fx_1.choices.append(opt_a)
	
	# IF FALSE / ELSE: Convert 1 Offence Die to 3 Offence Tokens
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.pool_type = CardData.DicePoolType.OFFENSE
	opt_b.gain_token_type = CardData.CombatTokenType.OFFENSE
	opt_b.value = 3
	opt_b.max_spend = 1
	fx_1.else_choices.append(opt_b)
	
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY (Refactored from multi-conditionals into an atomic fork nested in a gate) ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS
	
	# Inner Check: Evaluated only if target has routed assets
	fork = CardEffect.new()
	fork.effect_type = CardData.EffectType.CONDITIONAL
	fork.condition_type = CardData.ConditionType.OPPONENT_HAS_DEFENCE_DICE
	
	# IF TRUE: Tax 1 Defence die
	opt_fork_true = CardEffect.new()
	opt_fork_true.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_fork_true.target_type = CardData.TargetType.OPPONENT
	opt_fork_true.pool_type = CardData.DicePoolType.DEFENSE
	opt_fork_true.value = 1
	fork.choices.append(opt_fork_true)
	
	# IF FALSE / ELSE: Force destruction of lowest tier routed unit
	opt_fork_else = CardEffect.new()
	opt_fork_else.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	opt_fork_else.target_type = CardData.TargetType.OPPONENT
	opt_fork_else.value = 1
	opt_fork_else.destruction_mode = CardData.DestructionMode.ROUTED 
	fork.else_choices.append(opt_fork_else)
	
	fx_u_1.choices.append(fork)
	card.unit_ability.append(fx_u_1)
	
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
	var fx_suppression_guard = CardEffect.new()
	fx_suppression_guard.effect_type = CardData.EffectType.CONDITIONAL
	fx_suppression_guard.condition_type = CardData.ConditionType.CANNOT_GAIN_DEFENSE_TOKENS_THIS_ROUND_IS_NOT_ACTIVE
	
	# Inner Branch (Refactored to If/Else layout)
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
	# IF TRUE: Convert 1 Morale Die to 3 Defence Tokens
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.pool_type = CardData.DicePoolType.MORALE
	opt_a.gain_token_type = CardData.CombatTokenType.DEFENSE
	opt_a.value = 3
	opt_a.max_spend = 1
	fx_1.choices.append(opt_a)
	
	# IF FALSE / ELSE: Convert 1 Defence Die to 3 Defence Tokens
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.pool_type = CardData.DicePoolType.DEFENSE
	opt_b.gain_token_type = CardData.CombatTokenType.DEFENSE
	opt_b.value = 3
	opt_b.max_spend = 1
	fx_1.else_choices.append(opt_b)
	
	fx_suppression_guard.choices.append(fx_1)
	card.general_ability.append(fx_suppression_guard)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS
	
	opt_u_a = CardEffect.new()
	opt_u_a.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_u_a.target_type = CardData.TargetType.SELF
	opt_u_a.value = 2
	opt_u_a.pool_type = CardData.CombatTokenType.DEFENSE
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
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
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	fx_1.pool_type = CardData.DicePoolType.MORALE
	card.general_ability.append(fx_1)
	
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.HAS_MORE_MORALE_THAN_OPPONENT
	
	var inner_cond = CardEffect.new()
	inner_cond.effect_type = CardData.EffectType.CONDITIONAL
	inner_cond.condition_type = CardData.ConditionType.HAS_CULTISTS
	
	var spawn_fx = CardEffect.new()
	spawn_fx.effect_type = CardData.EffectType.SPAWN_UNIT
	spawn_fx.target_type = CardData.TargetType.SELF
	spawn_fx.value = 1
	@warning_ignore("int_as_enum_without_match")
	spawn_fx.pool_type = CardData.UnitType.CHAOS_SPACE_MARINES as CardData.DicePoolType
	
	var sacrifice_fx = CardEffect.new()
	sacrifice_fx.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	sacrifice_fx.target_type = CardData.TargetType.SELF
	sacrifice_fx.value = 1
	
	inner_cond.choices.append(spawn_fx)
	inner_cond.choices.append(sacrifice_fx)
	fx_2.choices.append(inner_cond)
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONVERT_DICE_TO_RANDOM_DIFFERENT_DICE
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 2
	fx_u_1.pool_type = CardData.DicePoolType.MORALE
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CHOICE
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 1
	opt_a.pool_type = CardData.DicePoolType.OFFENSE
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 1
	opt_b.pool_type = CardData.DicePoolType.MORALE
	
	fx_1.choices.append(opt_a)
	fx_1.choices.append(opt_b)
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.HAS_UNITS
	
	var sac_fx = CardEffect.new()
	sac_fx.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	sac_fx.target_type = CardData.TargetType.SELF
	sac_fx.value = 1
	
	var token_fx = CardEffect.new()
	token_fx.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	token_fx.target_type = CardData.TargetType.SELF
	token_fx.value = 4
	token_fx.pool_type = CardData.CombatTokenType.OFFENSE
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CHOICE
	
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
	
	fx_1.choices.append(opt_a)
	fx_1.choices.append(opt_b)
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 4
	fx_u_1.pool_type = CardData.CombatTokenType.DEFENSE
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CHOICE
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 2
	opt_a.pool_type = CardData.DicePoolType.OFFENSE
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 2
	opt_b.pool_type = CardData.DicePoolType.MORALE
	
	fx_1.choices.append(opt_a)
	fx_1.choices.append(opt_b)
	card.general_ability.append(fx_1)
	
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.DEATH_AND_DESPAIR_GENERAL_ABILITY_2
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY (Refactored from multi-conditional check into layered atomic execution gates) ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.HAS_MORE_MORALE_THAN_OPPONENT
	
	inner_gate = CardEffect.new()
	inner_gate.effect_type = CardData.EffectType.CONDITIONAL
	inner_gate.condition_type = CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS
	
	var destroy_routed_fx = CardEffect.new()
	destroy_routed_fx.effect_type = CardData.EffectType.DESTROY_HIGHEST_TIER_ROUTED_UNIT
	destroy_routed_fx.target_type = CardData.TargetType.OPPONENT
	destroy_routed_fx.value = 1
	
	inner_gate.choices.append(destroy_routed_fx)
	fx_u_1.choices.append(inner_gate)
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 2
	card.general_ability.append(fx_1)
	
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.HAS_MORE_MORALE_THAN_OPPONENT
	
	var rout_all_fx = CardEffect.new()
	rout_all_fx.effect_type = CardData.EffectType.ROUT_ALL_COMMAND_LEVEL_0_UNITS
	rout_all_fx.target_type = CardData.TargetType.OPPONENT
	
	fx_2.choices.append(rout_all_fx)
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_UNROUTED_UNITS
	
	var rout_highest_fx = CardEffect.new()
	rout_highest_fx.effect_type = CardData.EffectType.ROUT_HIGHEST_TIER
	rout_highest_fx.target_type = CardData.TargetType.OPPONENT
	
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
	fx_1.pool_type = CardData.CombatTokenType.OFFENSE
	card.general_ability.append(fx_1)
	
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_2.target_type = CardData.TargetType.SELF
	fx_2.value = 1
	fx_2.pool_type = CardData.CombatTokenType.DEFENSE
	card.general_ability.append(fx_2)
	
	fx_3 = CardEffect.new()
	fx_3.effect_type = CardData.EffectType.REROLL
	fx_3.target_type = CardData.TargetType.OPPONENT
	fx_3.value = 1
	card.general_ability.append(fx_3)
	
	# --- UNIT ABILITY (Refactored to If/Else Pipelines) ---
	# Friendly Line: If player HAS routed units -> destroy 1 routed; ELSE destroy 1 any standing unit
	var friendly_fork = CardEffect.new()
	friendly_fork.effect_type = CardData.EffectType.CONDITIONAL
	friendly_fork.condition_type = CardData.ConditionType.HAS_ROUTED_UNITS
	
	var friendly_true = CardEffect.new()
	friendly_true.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	friendly_true.target_type = CardData.TargetType.SELF
	friendly_true.value = 1
	friendly_true.destruction_mode = CardData.DestructionMode.ROUTED
	friendly_fork.choices.append(friendly_true)
	
	var friendly_else = CardEffect.new()
	friendly_else.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	friendly_else.target_type = CardData.TargetType.SELF
	friendly_else.value = 1
	friendly_else.destruction_mode = CardData.DestructionMode.ANY
	friendly_fork.else_choices.append(friendly_else)
	
	card.unit_ability.append(friendly_fork)
	
	# Hostile Line: If opponent HAS routed units -> destroy 1 enemy routed; ELSE destroy 1 enemy standing unit
	var hostile_fork = CardEffect.new()
	hostile_fork.effect_type = CardData.EffectType.CONDITIONAL
	hostile_fork.condition_type = CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS
	
	var hostile_true = CardEffect.new()
	hostile_true.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	hostile_true.target_type = CardData.TargetType.OPPONENT
	hostile_true.value = 1
	hostile_true.destruction_mode = CardData.DestructionMode.ROUTED
	hostile_fork.choices.append(hostile_true)
	
	var hostile_else = CardEffect.new()
	hostile_else.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	hostile_else.target_type = CardData.TargetType.OPPONENT
	hostile_else.value = 1
	hostile_else.destruction_mode = CardData.DestructionMode.ANY
	hostile_fork.else_choices.append(hostile_else)
	
	card.unit_ability.append(hostile_fork)
	
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
	
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.REROLL_ALL_SPECIFIC_DICE
	fx_2.target_type = CardData.TargetType.OPPONENT
	fx_2.pool_type = CardData.DicePoolType.MORALE
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
	fx_u_1.pool_type = CardData.CombatTokenType.OFFENSE
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
	node.pool_type = CardData.DicePoolType.MORALE
	
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
	fx_1.pool_type = CardData.DicePoolType.DEFENSE
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.value = 1
	fx_u_1.pool_type = CardData.CombatTokenType.DEFENSE
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
	fx_u_1.pool_type = CardData.CombatTokenType.OFFENSE
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
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 2
	opt_a.pool_type = CardData.CombatTokenType.OFFENSE
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 2
	opt_b.pool_type = CardData.CombatTokenType.DEFENSE
	
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
	fx_u_1.pool_type = CardData.CombatTokenType.OFFENSE
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
	fx_u_1.effect_type = CardData.EffectType.DISCARD_BEST_FACEUP_CARD
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 2
	fx_1.pool_type = CardData.CombatTokenType.OFFENSE
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY (Refactored to nested atomic logic tree) ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
	# Inner Gate: Evaluate if the opponent has unrouted assets
	inner_gate = CardEffect.new()
	inner_gate.effect_type = CardData.EffectType.CONDITIONAL
	inner_gate.condition_type = CardData.ConditionType.OPPONENT_HAS_UNROUTED_UNITS
	
	var rout_lowest_fx = CardEffect.new()
	rout_lowest_fx.effect_type = CardData.EffectType.ROUT_LOWEST_TIER
	rout_lowest_fx.target_type = CardData.TargetType.OPPONENT
	
	inner_gate.choices.append(rout_lowest_fx)
	fx_u_1.choices.append(inner_gate)
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.IS_ATTACKING
	
	var token_off = CardEffect.new()
	token_off.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	token_off.target_type = CardData.TargetType.SELF
	token_off.value = 1
	token_off.pool_type = CardData.CombatTokenType.OFFENSE
	
	var token_def = CardEffect.new()
	token_def.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	token_def.target_type = CardData.TargetType.SELF
	token_def.value = 1
	token_def.pool_type = CardData.CombatTokenType.DEFENSE
	
	fx_1.choices.append(token_off)
	fx_1.choices.append(token_def)
	card.general_ability.append(fx_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 4005: Command of the Autarch ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = 4005
	card.card_name = "Command of the Autarch"
	card.card_tier = CardData.CardTier.STARTER
	card.required_unit_types = []
	
	# --- GENERAL ABILITY 1 (Refactored to single clean If/Else fork) ---
	var fx_fork = CardEffect.new()
	fx_fork.effect_type = CardData.EffectType.CONDITIONAL
	fx_fork.condition_type = CardData.ConditionType.HAS_ROUTED_UNITS
	
	# IF TRUE: Execute Rally logic cascade
	var rally_node = CardEffect.new()
	rally_node.effect_type = CardData.EffectType.RALLY
	rally_node.target_type = CardData.TargetType.SELF
	rally_node.value = 1
	fx_fork.choices.append(rally_node)
	
	# IF FALSE / ELSE: Gain 1 Morale Die
	var morale_node = CardEffect.new()
	morale_node.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	morale_node.target_type = CardData.TargetType.SELF
	morale_node.value = 1
	morale_node.pool_type = CardData.DicePoolType.MORALE
	fx_fork.else_choices.append(morale_node)
	
	card.general_ability.append(fx_fork)
	
	# --- GENERAL ABILITY 2 ---
	fx_3 = CardEffect.new()
	fx_3.effect_type = CardData.EffectType.PLAY_RANDOM_CARD_DO_NOT_RESOLVE_ABILITIES
	fx_3.target_type = CardData.TargetType.SELF
	card.general_ability.append(fx_3)
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.IS_ATTACKING
	
	var prevent_node = CardEffect.new()
	prevent_node.effect_type = CardData.EffectType.PREVENT_OPPONENT_GAINING_DEFENSE_TOKENS_THIS_ROUND
	prevent_node.target_type = CardData.TargetType.OPPONENT
	
	fx_1.choices.append(prevent_node)
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.IS_DEFENDING
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_a.target_type = CardData.TargetType.OPPONENT
	opt_a.pool_type = CardData.CombatTokenType.OFFENSE
	opt_a.value = -3
	
	fx_1.choices.append(opt_a)
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	fx_u_1.target_type = CardData.TargetType.SELF
	fx_u_1.pool_type = CardData.DicePoolType.MORALE
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CHOICE
	fx_1.target_type = CardData.TargetType.SELF
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_DICE
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 1
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 1
	opt_b.pool_type = CardData.DicePoolType.MORALE
	
	fx_1.choices = [opt_a, opt_b]
	card.general_ability.append(fx_1)
	
	# --- GENERAL ABILITY 2 ---
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONVERT_DICE_TO_SPECIFIC_DICE
	fx_2.target_type = CardData.TargetType.SELF
	fx_2.value = 2
	fx_2.pool_type = CardData.DicePoolType.OFFENSE
	fx_2.max_spend = CardData.DicePoolType.DEFENSE
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY (Refactored into unified master gate and single internal fork node) ---
	fx_u = CardEffect.new()
	fx_u.effect_type = CardData.EffectType.CONDITIONAL
	fx_u.condition_type = CardData.ConditionType.OPPONENT_HAS_UNROUTED_UNITS
	
	fork = CardEffect.new()
	fork.effect_type = CardData.EffectType.CONDITIONAL
	fork.condition_type = CardData.ConditionType.OPPONENT_HAS_MORALE_DICE
	
	# IF TRUE: Strip 1 Morale die
	opt_u_a = CardEffect.new()
	opt_u_a.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_u_a.target_type = CardData.TargetType.OPPONENT
	opt_u_a.value = 1
	opt_u_a.pool_type = CardData.DicePoolType.MORALE
	fork.choices.append(opt_u_a)
	
	# IF FALSE / ELSE: Rout lowest tier unit
	opt_u_b = CardEffect.new()
	opt_u_b.effect_type = CardData.EffectType.ROUT_LOWEST_TIER
	opt_u_b.target_type = CardData.TargetType.OPPONENT
	opt_u_b.value = 1
	fork.else_choices.append(opt_u_b)
	
	fx_u.choices.append(fork)
	card.unit_ability.append(fx_u)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 4009: Wraithguard Support ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ELDAR_WRAITHGUARD_SUPPORT
	card.card_name = "Wraithguard Support"
	card.card_tier = CardData.CardTier.TIER_0
	card.defence_icons = 1
	card.morale_icons = 1
	card.required_unit_types = [
		CardData.UnitType.WRAITHGUARDS, 
		CardData.UnitType.HELLEBORE_FRIGATES, 
		CardData.UnitType.VOID_STALKERS
	]
	
	# --- GENERAL ABILITY 1 ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CHOICE
	fx_1.target_type = CardData.TargetType.SELF
	
	opt_a = CardEffect.new()
	opt_a.effect_type = CardData.EffectType.GAIN_DICE
	opt_a.target_type = CardData.TargetType.SELF
	opt_a.value = 1
	
	opt_b = CardEffect.new()
	opt_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_b.target_type = CardData.TargetType.SELF
	opt_b.value = 1
	opt_b.pool_type = CardData.DicePoolType.MORALE
	
	# Use append to keep the typed array happy
	fx_1.choices.append(opt_a)
	fx_1.choices.append(opt_b)
	card.general_ability.append(fx_1)
	
	# --- GENERAL ABILITY 2 ---
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONVERT_DICE_TO_SPECIFIC_DICE
	fx_2.target_type = CardData.TargetType.SELF
	fx_2.value = 2
	fx_2.pool_type = CardData.DicePoolType.DEFENSE
	fx_2.max_spend = CardData.DicePoolType.OFFENSE
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	fx_u = CardEffect.new()
	fx_u.effect_type = CardData.EffectType.CONDITIONAL
	fx_u.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
	# Step 1: Pay cost
	var opt_u_cost = CardEffect.new()
	opt_u_cost.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_u_cost.target_type = CardData.TargetType.SELF
	opt_u_cost.value = 1
	opt_u_cost.pool_type = CardData.DicePoolType.MORALE
	
	# Step 2: Rally effect
	var opt_u_effect = CardEffect.new()
	opt_u_effect.effect_type = CardData.EffectType.RALLY
	opt_u_effect.target_type = CardData.TargetType.SELF
	opt_u_effect.value = 1
	
	# Append
	fx_u.choices.append(opt_u_cost)
	fx_u.choices.append(opt_u_effect)
	card.unit_ability.append(fx_u)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 4010: Fire Prism ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ELDAR_FIRE_PRISM
	card.card_name = "Fire Prism"
	card.card_tier = CardData.CardTier.TIER_2
	card.offence_icons = 2
	card.defence_icons = 1
	card.required_unit_types = [
		CardData.UnitType.FALCONS, 
		CardData.UnitType.VOID_STALKERS
	]
	
	# --- GENERAL ABILITY ---
	# Conversion Node: Convert all Morale dice into Offence dice
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONVERT_DICE_TO_SPECIFIC_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 99 # 🎯 Using a high value ceiling acts as 'all available' in the conversion sweep
	fx_1.pool_type = CardData.DicePoolType.OFFENSE # Destination Pool
	fx_1.max_spend = CardData.DicePoolType.MORALE  # Source Pool
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY (Harnessing our new If/Else system) ---
	fx_u = CardEffect.new()
	fx_u.effect_type = CardData.EffectType.CONDITIONAL
	fx_u.condition_type = CardData.ConditionType.IS_ATTACKING
	
	# IF TRUE (Attacking): Gain 2 Offence Tokens
	opt_u_true = CardEffect.new()
	opt_u_true.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_u_true.target_type = CardData.TargetType.SELF
	opt_u_true.value = 2
	opt_u_true.pool_type = CardData.CombatTokenType.OFFENSE
	fx_u.choices.append(opt_u_true)
	
	# IF FALSE / ELSE (Defending): Opponent loses 5 Defence Tokens
	opt_u_else = CardEffect.new()
	opt_u_else.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_u_else.target_type = CardData.TargetType.OPPONENT
	opt_u_else.value = -5
	opt_u_else.pool_type = CardData.CombatTokenType.DEFENSE
	fx_u.else_choices.append(opt_u_else)
	
	card.unit_ability.append(fx_u)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 4011: Wave Serpent ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ELDAR_WAVE_SERPENT
	card.card_name = "Wave Serpent"
	card.card_tier = CardData.CardTier.TIER_2
	card.offence_icons = 1
	card.defence_icons = 2
	card.required_unit_types = [
		CardData.UnitType.FALCONS, 
		CardData.UnitType.VOID_STALKERS
	]
	
	# --- GENERAL ABILITY 1 ---
	# Gain 1 random dice
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- GENERAL ABILITY 2 (The "Unless" Structural Fork) ---
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.OPPONENT_HAS_MORALE_DICE
	
	# IF TRUE: Opponent spends (loses) 1 Morale die to break your shield deployment
	var opt_tax = CardEffect.new()
	opt_tax.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_tax.target_type = CardData.TargetType.OPPONENT
	opt_tax.value = 1
	opt_tax.pool_type = CardData.DicePoolType.MORALE
	fx_2.choices.append(opt_tax)
	
	# IF FALSE / ELSE: Your shield deploys successfully! Gain 3 Defense Tokens
	var opt_shield = CardEffect.new()
	opt_shield.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_shield.target_type = CardData.TargetType.SELF
	opt_shield.value = 3
	opt_shield.pool_type = CardData.CombatTokenType.DEFENSE
	fx_2.else_choices.append(opt_shield)
	
	card.general_ability.append(fx_2)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 4012: Spiritseer's Guidance ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ELDAR_SPRITSEERS_GUIDANCE
	card.card_name = "Spiritseer's Guidance"
	card.card_tier = CardData.CardTier.TIER_2
	card.offence_icons = 1
	card.defence_icons = 1
	card.morale_icons = 1
	card.required_unit_types = []
	
	# --- GENERAL ABILITY 1 ---
	# Gain 1 Morale Die
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	fx_1.pool_type = CardData.DicePoolType.MORALE
	card.general_ability.append(fx_1)
	
	# --- GENERAL ABILITY 2 (The Sacrificial Protection Gate) ---
	# Gate check: You must have an active, unrouted unit to pay the toll
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.HAS_UNROUTED_UNITS
	
	# Payload Step A: Rout 1 lowest-tier friendly unit
	var pay_rout = CardEffect.new()
	pay_rout.effect_type = CardData.EffectType.ROUT_LOWEST_TIER
	pay_rout.target_type = CardData.TargetType.SELF
	pay_rout.value = 1
	fx_2.choices.append(pay_rout)
	
	# Payload Step B: Trigger global damage immunity for the round
	var grant_immunity = CardEffect.new()
	grant_immunity.effect_type = CardData.EffectType.ALL_UNITS_GAIN_DAMAGE_IMMUNITY_THIS_ROUND
	grant_immunity.target_type = CardData.TargetType.SELF
	fx_2.choices.append(grant_immunity)
	
	card.general_ability.append(fx_2)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 4013: Holofield Emitter ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ELDAR_HOLOFIELD_EMITTER
	card.card_name = "Holofield Emitter"
	card.card_tier = CardData.CardTier.TIER_3
	card.offence_icons = 1
	card.defence_icons = 2
	card.morale_icons = 1
	card.required_unit_types = [
		CardData.UnitType.WARLOCK_TITANS, 
		CardData.UnitType.VOID_STALKERS
	]
	
	# --- GENERAL ABILITY 1 ---
	# Gain 1 random combat die
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- GENERAL ABILITY 2 ---
	# Draw 1 card from your combat deck into your hand
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.DRAW_COMBAT_CARDS
	fx_2.target_type = CardData.TargetType.SELF
	fx_2.value = 1
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	# Play card, do not resolve abilities on it
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.PLAY_RANDOM_CARD_DO_NOT_RESOLVE_ABILITIES
	fx_u_1.target_type = CardData.TargetType.SELF
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	# ==========================================================================
	# --- CARD 4014: Psychic Lance ---
	# ==========================================================================
	card = CardData.new()
	card.card_id = CardID.ELDAR_PSYCHIC_LANCE
	card.card_name = "Psychic Lance"
	card.card_tier = CardData.CardTier.TIER_3
	card.offence_icons = 2
	card.defence_icons = 1
	card.required_unit_types = [
		CardData.UnitType.WARLOCK_TITANS, 
		CardData.UnitType.VOID_STALKERS
	]
	
	# --- GENERAL ABILITY 1 ---
	# Gain 1 random combat die
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- GENERAL ABILITY 2 ---
	# Disruption: Opponent returns 1 random hand card back to their combat deck
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.DISCARD_RANDOM_CARD_FROM_HAND
	fx_2.target_type = CardData.TargetType.OPPONENT
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY (Nested Chronological Control Tree) ---
	# Outer Gate: Is this the opening round?
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.IS_FIRST_COMBAT_ROUND
	
	# --- TRACK A: IT IS ROUND 1 (True Branch) ---
	# Inner Gate: Evaluate tactical deployment roles
	var role_gate = CardEffect.new()
	role_gate.effect_type = CardData.EffectType.CONDITIONAL
	role_gate.condition_type = CardData.ConditionType.IS_ATTACKING
	
	# IF ATTACKING: Leave role_gate.choices empty so nothing happens!
	
	# IF DEFENDING (Else Branch of Round 1): Safely harvest the token payload
	var pay_offence_r1 = CardEffect.new()
	pay_offence_r1.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	pay_offence_r1.target_type = CardData.TargetType.SELF
	pay_offence_r1.value = 4
	pay_offence_r1.pool_type = CardData.CombatTokenType.OFFENSE
	role_gate.else_choices.append(pay_offence_r1)
	
	# Bind inner role checks to the top-level round 1 true track
	fx_u_1.choices.append(role_gate)
	
	# --- TRACK B: IT IS NOT ROUND 1 (False / Else Branch) ---
	# Escalation phase unlocked: Automatically gain the 4 offence tokens
	var pay_offence_escalation = CardEffect.new()
	pay_offence_escalation.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	pay_offence_escalation.target_type = CardData.TargetType.SELF
	pay_offence_escalation.value = 4
	pay_offence_escalation.pool_type = CardData.CombatTokenType.OFFENSE
	fx_u_1.else_choices.append(pay_offence_escalation)
	
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	return db
