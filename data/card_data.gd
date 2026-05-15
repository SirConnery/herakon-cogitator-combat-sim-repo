extends Resource
class_name CardData

enum EffectType { NONE, GAIN_DICE }
enum TargetType { SELF, OPPONENT }

@export var card_id: int
@export var card_name: String

@export_category("Combat Stats")
@export var offence_icons: int
@export var defence_icons: int
@export var morale_icons: int

@export_category("Abilities")
@export var general_ability: CardEffect
@export var unit_ability: CardEffect
