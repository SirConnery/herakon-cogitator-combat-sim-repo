extends Resource
class_name CardEffect

@export var effect_type: CardData.EffectType = CardData.EffectType.NONE
@export var target_type: CardData.TargetType = CardData.TargetType.SELF
@export var condition_type: CardData.ConditionType = CardData.ConditionType.NONE
@export var value := 0
@export var pool_type: int = 0 # defaults to RANDOM
@export var max_spend := -1
@export var choices: Array[CardEffect] = []
@export var destruction_mode: int = CardData.DestructionMode.ANY
@export var gain_token_type: int = 0 # Defaults to crashing if unset
