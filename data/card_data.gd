extends Resource
class_name CardData

enum EffectType { NONE, 
CHOICE,
GAIN_DICE, 
GAIN_SPECIFIC_DICE,
RALLY
}

enum TargetType { SELF, OPPONENT }
enum DicePoolType { RANDOM, OFFENSE, DEFENSE, MORALE }
enum UnitType {
	NONE,
	
	# --- SPACE MARINES ---
	SCOUTS,
	SPACE_MARINES,
	LAND_RAIDERS,
	WARLORD_TITANS,
	
	# --- ORKS ---
	ORK_BOYZ,
	NOBZ,
	BATTLEWAGONS,
	GARGANTS,
	
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
@export var general_ability: CardEffect
@export var unit_ability: CardEffect
@export var required_unit_types: int
@export var choices: Array[CardEffect] = []
