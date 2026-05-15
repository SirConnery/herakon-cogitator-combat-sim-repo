class_name CardRegistry
extends RefCounted

static func get_database() -> Dictionary:
	var db: Dictionary = {}
	
	# --- CARD 1 ---
	var c1 = CardData.new()
	c1.card_id = 1
	c1.card_name = "Faith In the Emperor"
	c1.offence_icons = 1
	c1.defence_icons = 0
	c1.morale_icons = 0
	
	var fx1 = CardEffect.new()
	fx1.effect_type = CardData.EffectType.GAIN_DICE
	fx1.target_type = CardData.TargetType.SELF
	fx1.value = 1
	
	c1.general_ability = fx1
	
	db[c1.card_id] = c1
	
	return db
