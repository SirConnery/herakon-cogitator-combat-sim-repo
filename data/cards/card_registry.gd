extends RefCounted
class_name CardRegistry


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

@warning_ignore("unused_variable")
static func get_database() -> Dictionary:
	var db := {}
	
	# --- CORE OBJECTS ---
	var card: CardData
	var node: CardEffect # Reusable generic pointer for tree construction
	
	# --- STANDARD SEQUENTIAL EFFECTS (fx_) ---
	# Used for straightforward, back-to-back card actions
	var fx_1: CardEffect
	var fx_2: CardEffect
	var fx_3: CardEffect
	var fx_4: CardEffect
	
	# --- UPGRADED SEQUENTIAL EFFECTS (fx_u_) ---
	# Used for exclusive actions that only trigger on upgraded card variants
	var fx_u_1: CardEffect
	var fx_u_2: CardEffect
	var fx_u_3: CardEffect
	
	# --- STANDARD CHOICE OPTIONS (opt_) ---
	# Used for modal choices (e.g., "Choose: Gain X OR Do Y")
	var opt_1_a: CardEffect
	var opt_1_b: CardEffect
	#var opt_2_a: CardEffect
	
	# --- UPGRADED CHOICE OPTIONS (opt_u_) ---
	# Used for choices that change or unlock when the card is upgraded
	var opt_u_a: CardEffect
	var opt_u_b: CardEffect
	
	# --- CONDITIONAL GATES (gate_) ---
	# Replaced 'inner_gate' with structured conditional branch wrappers
	var gate_1: CardEffect
	
	# --- GATED BRANCH PATHS (branch_) ---
	var branch_true: CardEffect
	var branch_false: CardEffect
	var branch_else: CardEffect
	
	# --- UPGRADED GATED BRANCH PATHS (branch_u_) ---
	#var branch_u_true: CardEffect
	#var branch_u_false: CardEffect
	#var branch_u_else: CardEffect
	
	# --- FORKED TIMING EFFECTS (fork_) ---
	# Used for parallel execution paths or delayed triggers
	var fork_1: CardEffect
	var fork_2: CardEffect
	var branch_fork_true: CardEffect
	var branch_fork_else: CardEffect
	
	
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
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_1_a.target_type = CardData.TargetType.SELF
	opt_1_a.value = 2
	opt_1_a.pool_type = CardData.CombatTokenType.OFFENSE
	
	# Option B: Gain 2 Defence Tokens
	opt_1_b = CardEffect.new()
	opt_1_b.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_1_b.target_type = CardData.TargetType.SELF
	opt_1_b.value = 2
	opt_1_b.pool_type = CardData.CombatTokenType.DEFENSE
	
	fx_1.choices = [opt_1_a, opt_1_b]
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

	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.REROLL
	opt_1_a.target_type = CardData.TargetType.SELF
	opt_1_a.pool_type = CardData.DicePoolType.DEFENSE
	opt_1_a.value = 1

	opt_1_b = CardEffect.new()
	opt_1_b.effect_type = CardData.EffectType.NONE
	opt_1_b.target_type = CardData.TargetType.SELF

	fx_2.choices = [opt_1_a, opt_1_b]
	card.general_ability.append(fx_2)

	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_TWO_OR_MORE_DEFENSE_TOKENS
	
	# IF TRUE: Standard Tax -> Strip 2 Shield/Defense tokens
	branch_true = CardEffect.new()
	branch_true.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	branch_true.target_type = CardData.TargetType.OPPONENT
	branch_true.value = -2
	branch_true.pool_type = CardData.CombatTokenType.DEFENSE
	fx_u_1.choices.append(branch_true)

	# IF FALSE / ELSE: Fallback Penalty -> Destroy 1 Shield/Defense die
	branch_false = CardEffect.new()
	branch_false.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	branch_false.target_type = CardData.TargetType.OPPONENT
	branch_false.value = 1
	branch_false.pool_type = CardData.DicePoolType.DEFENSE
	fx_u_1.else_choices.append(branch_false)

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
	
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.RALLY
	opt_1_a.target_type = CardData.TargetType.SELF
	opt_1_a.value = 1
	
	opt_1_b = CardEffect.new()
	opt_1_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_1_b.target_type = CardData.TargetType.SELF
	opt_1_b.value = 1
	opt_1_b.pool_type = CardData.DicePoolType.MORALE
	
	fx_u_1.choices = [opt_1_a, opt_1_b]
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
	
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_1_a.target_type = CardData.TargetType.SELF
	opt_1_a.value = 1
	opt_1_a.pool_type = CardData.DicePoolType.DEFENSE
	
	opt_1_b = CardEffect.new()
	opt_1_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_1_b.target_type = CardData.TargetType.SELF
	opt_1_b.value = 1
	opt_1_b.pool_type = CardData.DicePoolType.MORALE
	
	fx_u_1.choices = [opt_1_a, opt_1_b]
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
	
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_1_a.target_type = CardData.TargetType.OPPONENT
	opt_1_a.value = 1
	opt_1_a.pool_type = CardData.DicePoolType.DEFENSE
	
	opt_1_b = CardEffect.new()
	opt_1_b.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_1_b.target_type = CardData.TargetType.OPPONENT
	opt_1_b.value = 1
	opt_1_b.pool_type = CardData.DicePoolType.MORALE
	
	fx_u_1.choices = [opt_1_a, opt_1_b]
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
	
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_1_a.target_type = CardData.TargetType.SELF
	opt_1_a.value = 1
	opt_1_a.pool_type = CardData.DicePoolType.MORALE
	
	opt_1_b = CardEffect.new()
	opt_1_b.effect_type = CardData.EffectType.SPAWN_UNIT
	opt_1_b.target_type = CardData.TargetType.SELF
	opt_1_b.value = 1
	opt_1_b.pool_type = CardData.UnitType.SPACE_MARINES as CardData.DicePoolType
	
	fx_u_1.choices = [opt_1_a, opt_1_b]
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
	
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_1_a.target_type = CardData.TargetType.SELF
	opt_1_a.value = 1
	opt_1_a.pool_type = CardData.DicePoolType.MORALE
	
	opt_1_b = CardEffect.new()
	opt_1_b.effect_type = CardData.EffectType.RALLY_ALL_FRIENDLY_UNITS
	opt_1_b.target_type = CardData.TargetType.SELF
	
	fx_u_1.choices = [opt_1_a, opt_1_b]
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
	
	# --- GENERAL ABILITY ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.OPPONENT_HAS_UNROUTED_UNITS
	
	# IF TRUE: Rout enemy lowest tier and grant them 1 die
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.ROUT_LOWEST_TIER
	opt_1_a.target_type = CardData.TargetType.OPPONENT
	opt_1_a.value = 1
	
	opt_1_b = CardEffect.new()
	opt_1_b.effect_type = CardData.EffectType.GAIN_DICE
	opt_1_b.target_type = CardData.TargetType.OPPONENT
	opt_1_b.value = 1
	
	fx_1.choices.append(opt_1_a)
	fx_1.choices.append(opt_1_b)
	
	# IF FALSE / ELSE: Spawn reinforcement token on friendly side
	branch_else = CardEffect.new()
	branch_else.effect_type = CardData.EffectType.SPAWN_REINFORCEMENT_TOKEN
	branch_else.target_type = CardData.TargetType.SELF
	branch_else.value = 1
	fx_1.else_choices.append(branch_else)
	
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
	
	# --- GENERAL ABILITY ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
	# IF TRUE: Convert 1 Morale Die to 3 Offence Tokens
	branch_true = CardEffect.new()
	branch_true.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	branch_true.target_type = CardData.TargetType.SELF
	branch_true.pool_type = CardData.DicePoolType.MORALE
	branch_true.gain_token_type = CardData.CombatTokenType.OFFENSE
	branch_true.value = 3
	branch_true.max_spend = 1
	fx_1.choices.append(branch_true)
	
	# IF FALSE / ELSE: Convert 1 Offence Die to 3 Offence Tokens
	branch_else = CardEffect.new()
	branch_else.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	branch_else.target_type = CardData.TargetType.SELF
	branch_else.pool_type = CardData.DicePoolType.OFFENSE
	branch_else.gain_token_type = CardData.CombatTokenType.OFFENSE
	branch_else.value = 3
	branch_else.max_spend = 1
	fx_1.else_choices.append(branch_else)
	
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS
	
	# Inner Check: Evaluated only if target has routed assets
	fork_1 = CardEffect.new()
	fork_1.effect_type = CardData.EffectType.CONDITIONAL
	fork_1.condition_type = CardData.ConditionType.OPPONENT_HAS_DEFENCE_DICE
	
	# IF TRUE: Tax 1 Defence die
	branch_fork_true = CardEffect.new()
	branch_fork_true.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	branch_fork_true.target_type = CardData.TargetType.OPPONENT
	branch_fork_true.pool_type = CardData.DicePoolType.DEFENSE
	branch_fork_true.value = 1
	fork_1.choices.append(branch_fork_true)
	
	# IF FALSE / ELSE: Force destruction of lowest tier routed unit
	branch_fork_else = CardEffect.new()
	branch_fork_else.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	branch_fork_else.target_type = CardData.TargetType.OPPONENT
	branch_fork_else.value = 1
	branch_fork_else.destruction_mode = CardData.DestructionMode.ROUTED 
	fork_1.else_choices.append(branch_fork_else)
	
	fx_u_1.choices.append(fork_1)
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_1.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
	# IF TRUE: Convert 1 Morale Die to 3 Defence Tokens
	branch_true = CardEffect.new()
	branch_true.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	branch_true.target_type = CardData.TargetType.SELF
	branch_true.pool_type = CardData.DicePoolType.MORALE
	branch_true.gain_token_type = CardData.CombatTokenType.DEFENSE
	branch_true.value = 3
	branch_true.max_spend = 1
	fx_1.choices.append(branch_true)
	
	# IF FALSE / ELSE: Convert 1 Defence Die to 3 Defence Tokens
	branch_else = CardEffect.new()
	branch_else.effect_type = CardData.EffectType.SPEND_SPECIFIC_DICE_TO_GAIN_TOKENS
	branch_else.target_type = CardData.TargetType.SELF
	branch_else.pool_type = CardData.DicePoolType.DEFENSE
	branch_else.gain_token_type = CardData.CombatTokenType.DEFENSE
	branch_else.value = 3
	branch_else.max_spend = 1
	fx_1.else_choices.append(branch_else)
	
	card.general_ability.append(fx_1)
	
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
	
	fx_2.choices = [node]
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
	
	gate_1 = CardEffect.new()
	gate_1.effect_type = CardData.EffectType.CONDITIONAL
	gate_1.condition_type = CardData.ConditionType.HAS_CULTISTS
	
	fx_3 = CardEffect.new()
	fx_3.effect_type = CardData.EffectType.SPAWN_UNIT
	fx_3.target_type = CardData.TargetType.SELF
	fx_3.value = 1
	@warning_ignore("int_as_enum_without_match")
	fx_3.pool_type = CardData.UnitType.CHAOS_SPACE_MARINES as CardData.DicePoolType
	
	fx_4 = CardEffect.new()
	fx_4.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	fx_4.target_type = CardData.TargetType.SELF
	fx_4.value = 1
	
	gate_1.choices.append(fx_3)
	gate_1.choices.append(fx_4)
	fx_2.choices.append(gate_1)
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
	
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_1_a.target_type = CardData.TargetType.SELF
	opt_1_a.value = 1
	opt_1_a.pool_type = CardData.DicePoolType.OFFENSE
	
	opt_1_b = CardEffect.new()
	opt_1_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_1_b.target_type = CardData.TargetType.SELF
	opt_1_b.value = 1
	opt_1_b.pool_type = CardData.DicePoolType.MORALE
	
	fx_1.choices.append(opt_1_a)
	fx_1.choices.append(opt_1_b)
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.HAS_TIER_0_UNITS
	
	fx_u_2 = CardEffect.new()
	fx_u_2.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	fx_u_2.target_type = CardData.TargetType.SELF
	fx_u_2.value = 1
	
	fx_u_3 = CardEffect.new()
	fx_u_3.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_u_3.target_type = CardData.TargetType.SELF
	fx_u_3.value = 4
	fx_u_3.pool_type = CardData.CombatTokenType.OFFENSE
	
	fx_u_1.choices.append(fx_u_2)
	fx_u_1.choices.append(fx_u_3)
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
	
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_1_a.target_type = CardData.TargetType.SELF
	opt_1_a.value = 1
	opt_1_a.pool_type = CardData.DicePoolType.DEFENSE
	
	opt_1_b = CardEffect.new()
	opt_1_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_1_b.target_type = CardData.TargetType.SELF
	opt_1_b.value = 1
	opt_1_b.pool_type = CardData.DicePoolType.MORALE
	
	fx_1.choices.append(opt_1_a)
	fx_1.choices.append(opt_1_b)
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
	
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_1_a.target_type = CardData.TargetType.SELF
	opt_1_a.value = 2
	opt_1_a.pool_type = CardData.DicePoolType.OFFENSE
	
	opt_1_b = CardEffect.new()
	opt_1_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_1_b.target_type = CardData.TargetType.SELF
	opt_1_b.value = 2
	opt_1_b.pool_type = CardData.DicePoolType.MORALE
	
	fx_1.choices.append(opt_1_a)
	fx_1.choices.append(opt_1_b)
	card.general_ability.append(fx_1)
	
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.DEATH_AND_DESPAIR_GENERAL_ABILITY_2
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.HAS_MORE_MORALE_THAN_OPPONENT
	
	gate_1 = CardEffect.new()
	gate_1.effect_type = CardData.EffectType.CONDITIONAL
	gate_1.condition_type = CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS
	
	fx_u_2 = CardEffect.new()
	fx_u_2.effect_type = CardData.EffectType.DESTROY_HIGHEST_TIER_ROUTED_UNIT
	fx_u_2.target_type = CardData.TargetType.OPPONENT
	fx_u_2.value = 1
	
	gate_1.choices.append(fx_u_2)
	fx_u_1.choices.append(gate_1)
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
	
	fx_3 = CardEffect.new()
	fx_3.effect_type = CardData.EffectType.ROUT_ALL_COMMAND_LEVEL_0_UNITS
	fx_3.target_type = CardData.TargetType.OPPONENT
	
	fx_2.choices.append(fx_3)
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_UNROUTED_UNITS
	
	fx_u_2 = CardEffect.new()
	fx_u_2.effect_type = CardData.EffectType.ROUT_HIGHEST_TIER
	fx_u_2.target_type = CardData.TargetType.OPPONENT
	
	fx_u_1.choices.append(fx_u_2)
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
	
	# --- GENERAL ABILITY 2 ---
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_2.target_type = CardData.TargetType.SELF
	fx_2.value = 1
	fx_2.pool_type = CardData.CombatTokenType.DEFENSE
	card.general_ability.append(fx_2)
	
	# --- GENERAL ABILITY 3 ---
	fx_3 = CardEffect.new()
	fx_3.effect_type = CardData.EffectType.REROLL
	fx_3.target_type = CardData.TargetType.OPPONENT
	fx_3.value = 1
	card.general_ability.append(fx_3)
	
	# --- UNIT ABILITY ---
	fork_1 = CardEffect.new()
	fork_1.effect_type = CardData.EffectType.CONDITIONAL
	fork_1.condition_type = CardData.ConditionType.HAS_ROUTED_UNITS
	
	branch_fork_true = CardEffect.new()
	branch_fork_true.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	branch_fork_true.target_type = CardData.TargetType.SELF
	branch_fork_true.value = 1
	branch_fork_true.destruction_mode = CardData.DestructionMode.ROUTED
	fork_1.choices.append(branch_fork_true)
	
	branch_fork_else = CardEffect.new()
	branch_fork_else.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	branch_fork_else.target_type = CardData.TargetType.SELF
	branch_fork_else.value = 1
	branch_fork_else.destruction_mode = CardData.DestructionMode.ANY
	fork_1.else_choices.append(branch_fork_else)
	
	card.unit_ability.append(fork_1)
	
	fork_2 = CardEffect.new()
	fork_2.effect_type = CardData.EffectType.CONDITIONAL
	fork_2.condition_type = CardData.ConditionType.OPPONENT_HAS_ROUTED_UNITS
	
	branch_true = CardEffect.new()
	branch_true.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	branch_true.target_type = CardData.TargetType.OPPONENT
	branch_true.value = 1
	branch_true.destruction_mode = CardData.DestructionMode.ROUTED
	fork_2.choices.append(branch_true)
	
	branch_else = CardEffect.new()
	branch_else.effect_type = CardData.EffectType.DESTROY_LOWEST_TIER
	branch_else.target_type = CardData.TargetType.OPPONENT
	branch_else.value = 1
	branch_else.destruction_mode = CardData.DestructionMode.ANY
	fork_2.else_choices.append(branch_else)
	
	card.unit_ability.append(fork_2)
	
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
	
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_1_a.target_type = CardData.TargetType.SELF
	opt_1_a.value = 2
	opt_1_a.pool_type = CardData.CombatTokenType.OFFENSE
	
	opt_1_b = CardEffect.new()
	opt_1_b.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_1_b.target_type = CardData.TargetType.SELF
	opt_1_b.value = 2
	opt_1_b.pool_type = CardData.CombatTokenType.DEFENSE
	
	fx_u_1.choices = [opt_1_a, opt_1_b]
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
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
	gate_1 = CardEffect.new()
	gate_1.effect_type = CardData.EffectType.CONDITIONAL
	gate_1.condition_type = CardData.ConditionType.OPPONENT_HAS_UNROUTED_UNITS
	
	fx_u_2 = CardEffect.new()
	fx_u_2.effect_type = CardData.EffectType.ROUT_LOWEST_TIER
	fx_u_2.target_type = CardData.TargetType.OPPONENT
	
	gate_1.choices.append(fx_u_2)
	fx_u_1.choices.append(gate_1)
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
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.LOSE_DICE
	fx_u_1.target_type = CardData.TargetType.OPPONENT
	fx_u_1.value = 1
	card.unit_ability.append(fx_u_1)
	
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
	
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_1_a.target_type = CardData.TargetType.SELF
	opt_1_a.value = 1
	opt_1_a.pool_type = CardData.CombatTokenType.OFFENSE
	
	opt_1_b = CardEffect.new()
	opt_1_b.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_1_b.target_type = CardData.TargetType.SELF
	opt_1_b.value = 1
	opt_1_b.pool_type = CardData.CombatTokenType.DEFENSE
	
	fx_1.choices.append(opt_1_a)
	fx_1.choices.append(opt_1_b)
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
	
	# --- GENERAL ABILITY 1 ---
	gate_1 = CardEffect.new()
	gate_1.effect_type = CardData.EffectType.CONDITIONAL
	gate_1.condition_type = CardData.ConditionType.HAS_ROUTED_UNITS
	
	# IF TRUE: Execute Rally logic cascade
	branch_true = CardEffect.new()
	branch_true.effect_type = CardData.EffectType.RALLY
	branch_true.target_type = CardData.TargetType.SELF
	branch_true.value = 1
	gate_1.choices.append(branch_true)
	
	# IF FALSE / ELSE: Gain 1 Morale Die
	branch_else = CardEffect.new()
	branch_else.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	branch_else.target_type = CardData.TargetType.SELF
	branch_else.value = 1
	branch_else.pool_type = CardData.DicePoolType.MORALE
	gate_1.else_choices.append(branch_else)
	
	card.general_ability.append(gate_1)
	
	# --- GENERAL ABILITY 2 ---
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.PLAY_RANDOM_CARD_DO_NOT_RESOLVE_ABILITIES
	fx_1.target_type = CardData.TargetType.SELF
	card.general_ability.append(fx_1)
	
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
	
	node = CardEffect.new()
	node.effect_type = CardData.EffectType.PREVENT_OPPONENT_GAINING_DEFENSE_TOKENS_THIS_ROUND
	node.target_type = CardData.TargetType.OPPONENT
	
	fx_1.choices.append(node)
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
	
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	opt_1_a.target_type = CardData.TargetType.OPPONENT
	opt_1_a.pool_type = CardData.CombatTokenType.OFFENSE
	opt_1_a.value = -3
	
	fx_1.choices.append(opt_1_a)
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
	
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.GAIN_DICE
	opt_1_a.target_type = CardData.TargetType.SELF
	opt_1_a.value = 1
	
	opt_1_b = CardEffect.new()
	opt_1_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_1_b.target_type = CardData.TargetType.SELF
	opt_1_b.value = 1
	opt_1_b.pool_type = CardData.DicePoolType.MORALE
	
	fx_1.choices = [opt_1_a, opt_1_b]
	card.general_ability.append(fx_1)
	
	# --- GENERAL ABILITY 2 ---
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONVERT_DICE_TO_SPECIFIC_DICE
	fx_2.target_type = CardData.TargetType.SELF
	fx_2.value = 2
	fx_2.pool_type = CardData.DicePoolType.OFFENSE
	fx_2.max_spend = CardData.DicePoolType.DEFENSE
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.OPPONENT_HAS_UNROUTED_UNITS
	
	fork_1 = CardEffect.new()
	fork_1.effect_type = CardData.EffectType.CONDITIONAL
	fork_1.condition_type = CardData.ConditionType.OPPONENT_HAS_MORALE_DICE
	
	# IF TRUE: Strip 1 Morale die
	branch_fork_true = CardEffect.new()
	branch_fork_true.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	branch_fork_true.target_type = CardData.TargetType.OPPONENT
	branch_fork_true.value = 1
	branch_fork_true.pool_type = CardData.DicePoolType.MORALE
	fork_1.choices.append(branch_fork_true)
	
	# IF FALSE / ELSE: Rout lowest tier unit
	branch_fork_else = CardEffect.new()
	branch_fork_else.effect_type = CardData.EffectType.ROUT_LOWEST_TIER
	branch_fork_else.target_type = CardData.TargetType.OPPONENT
	branch_fork_else.value = 1
	fork_1.else_choices.append(branch_fork_else)
	
	fx_u_1.choices.append(fork_1)
	card.unit_ability.append(fx_u_1)
	
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
	
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.GAIN_DICE
	opt_1_a.target_type = CardData.TargetType.SELF
	opt_1_a.value = 1
	
	opt_1_b = CardEffect.new()
	opt_1_b.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	opt_1_b.target_type = CardData.TargetType.SELF
	opt_1_b.value = 1
	opt_1_b.pool_type = CardData.DicePoolType.MORALE
	
	fx_1.choices.append(opt_1_a)
	fx_1.choices.append(opt_1_b)
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
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.HAS_MORALE_DICE
	
	# Step 1: Pay cost
	fx_u_2 = CardEffect.new()
	fx_u_2.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	fx_u_2.target_type = CardData.TargetType.SELF
	fx_u_2.value = 1
	fx_u_2.pool_type = CardData.DicePoolType.MORALE
	
	# Step 2: Rally effect
	fx_u_3 = CardEffect.new()
	fx_u_3.effect_type = CardData.EffectType.RALLY
	fx_u_3.target_type = CardData.TargetType.SELF
	fx_u_3.value = 1
	
	fx_u_1.choices.append(fx_u_2)
	fx_u_1.choices.append(fx_u_3)
	card.unit_ability.append(fx_u_1)
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.CONVERT_DICE_TO_SPECIFIC_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 99 
	fx_1.pool_type = CardData.DicePoolType.OFFENSE 
	fx_1.max_spend = CardData.DicePoolType.MORALE  
	card.general_ability.append(fx_1)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.IS_ATTACKING
	
	# IF TRUE (Attacking): Gain 2 Offence Tokens
	branch_true = CardEffect.new()
	branch_true.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	branch_true.target_type = CardData.TargetType.SELF
	branch_true.value = 2
	branch_true.pool_type = CardData.CombatTokenType.OFFENSE
	fx_u_1.choices.append(branch_true)
	
	# IF FALSE / ELSE (Defending): Opponent loses 5 Defence Tokens
	branch_else = CardEffect.new()
	branch_else.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	branch_else.target_type = CardData.TargetType.OPPONENT
	branch_else.value = -5
	branch_else.pool_type = CardData.CombatTokenType.DEFENSE
	fx_u_1.else_choices.append(branch_else)
	
	card.unit_ability.append(fx_u_1)
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- GENERAL ABILITY 2 ---
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.OPPONENT_HAS_MORALE_DICE
	
	# IF TRUE: Opponent spends (loses) 1 Morale die to break your shield deployment
	opt_1_a = CardEffect.new()
	opt_1_a.effect_type = CardData.EffectType.LOSE_SPECIFIC_DICE
	opt_1_a.target_type = CardData.TargetType.OPPONENT
	opt_1_a.value = 1
	opt_1_a.pool_type = CardData.DicePoolType.MORALE
	fx_2.choices.append(opt_1_a)
	
	# IF FALSE / ELSE: Your shield deploys successfully! Gain 3 Defense Tokens
	branch_else = CardEffect.new()
	branch_else.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	branch_else.target_type = CardData.TargetType.SELF
	branch_else.value = 3
	branch_else.pool_type = CardData.CombatTokenType.DEFENSE
	fx_2.else_choices.append(branch_else)
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_SPECIFIC_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	fx_1.pool_type = CardData.DicePoolType.MORALE
	card.general_ability.append(fx_1)
	
	# --- GENERAL ABILITY 2 ---
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.CONDITIONAL
	fx_2.condition_type = CardData.ConditionType.HAS_UNROUTED_UNITS
	
	# Payload Step A: Rout 1 lowest-tier friendly unit
	fx_3 = CardEffect.new()
	fx_3.effect_type = CardData.EffectType.ROUT_LOWEST_TIER
	fx_3.target_type = CardData.TargetType.SELF
	fx_3.value = 1
	fx_2.choices.append(fx_3)
	
	# Payload Step B: Trigger global damage immunity for the round
	fx_4 = CardEffect.new()
	fx_4.effect_type = CardData.EffectType.ALL_UNITS_GAIN_DAMAGE_IMMUNITY_THIS_ROUND
	fx_4.target_type = CardData.TargetType.SELF
	fx_2.choices.append(fx_4)
	
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- GENERAL ABILITY 2 ---
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.DRAW_COMBAT_CARDS
	fx_2.target_type = CardData.TargetType.SELF
	fx_2.value = 1
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
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
	fx_1 = CardEffect.new()
	fx_1.effect_type = CardData.EffectType.GAIN_DICE
	fx_1.target_type = CardData.TargetType.SELF
	fx_1.value = 1
	card.general_ability.append(fx_1)
	
	# --- GENERAL ABILITY 2 ---
	fx_2 = CardEffect.new()
	fx_2.effect_type = CardData.EffectType.DISCARD_RANDOM_CARD_FROM_HAND
	fx_2.target_type = CardData.TargetType.OPPONENT
	card.general_ability.append(fx_2)
	
	# --- UNIT ABILITY ---
	fx_u_1 = CardEffect.new()
	fx_u_1.effect_type = CardData.EffectType.CONDITIONAL
	fx_u_1.condition_type = CardData.ConditionType.IS_FIRST_COMBAT_ROUND
	
	# --- TRACK A: IT IS ROUND 1 (True Branch) ---
	gate_1 = CardEffect.new()
	gate_1.effect_type = CardData.EffectType.CONDITIONAL
	gate_1.condition_type = CardData.ConditionType.IS_ATTACKING
	
	# IF DEFENDING (Else Branch of Round 1): Safely harvest the token payload
	fx_u_2 = CardEffect.new()
	fx_u_2.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	fx_u_2.target_type = CardData.TargetType.SELF
	fx_u_2.value = 4
	fx_u_2.pool_type = CardData.CombatTokenType.OFFENSE
	gate_1.else_choices.append(fx_u_2)
	
	# Bind inner role checks to the top-level round 1 true track
	fx_u_1.choices.append(gate_1)
	
	# --- TRACK B: IT IS NOT ROUND 1 (False / Else Branch) ---
	branch_else = CardEffect.new()
	branch_else.effect_type = CardData.EffectType.GAIN_OR_LOSE_COMBAT_TOKENS
	branch_else.target_type = CardData.TargetType.SELF
	branch_else.value = 4
	branch_else.pool_type = CardData.CombatTokenType.OFFENSE
	fx_u_1.else_choices.append(branch_else)
	
	card.unit_ability.append(fx_u_1)
	
	db[card.card_id] = card
	
	return db
