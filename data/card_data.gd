extends Resource
class_name CardData

enum EffectType { NONE, 
CHOICE,
GAIN_DICE, 
GAIN_SPECIFIC_DICE,
GAIN_SPECIFIC_COMBAT_TOKEN,
REROLL,
RALLY,
DESTROY_FOR_DESTROY,
DESTROY_ON_ROUT_OR_SPEND
}

enum TargetType { SELF, OPPONENT }
enum DicePoolType { RANDOM, OFFENSE, DEFENSE, MORALE }
enum TimingWindow {
	INSTANT,         # Resolves immediately when card is revealed (Stage 2)
	BEFORE_DAMAGE,   # Resolves right before offense/defense values match up
	DURING_DAMAGE,   # Resolves after raw damage numbers are calculated, before unit allocation
	AFTER_DAMAGE     # Resolves after figures are safely routed or destroyed
}
enum UnitType {
	NONE,
	
	# --- SPACE MARINES ---
	SCOUTS,
	SPACE_MARINES,
	LAND_RAIDERS,
	WARLORD_TITANS,
	STRIKE_CRUISERS,
	BATTLE_BARGES,
	
	# --- ORKS ---
	ORK_BOYZ,
	NOBZ,
	BATTLEWAGONS,
	GARGANTS,
	ONSLAUGHTS,
	KILL_KROOZERS,
	
	# --- CHAOS SPACE MARINES ---
	CULTISTS,
	CHAOS_SPACE_MARINES,
	HELBRUTES,
	CHAOS_REAVER_TITANS,
	
	# --- ELDAR ---
	ASPECT_WARRIORS,
	WRAITHGUARD,
	FALCONS,
	WARLOCK_TITANS
}

@export var card_id: int
@export var card_name: String

@export_category("Combat Stats")
@export var offence_icons: int
@export var defence_icons: int
@export var morale_icons: int

@export_category("Abilities")
@export var general_ability: Array[CardEffect] = []
@export var unit_ability: Array[CardEffect] = []
@export var required_unit_types: Array[UnitType] = []
