class_name CardRegistry
extends RefCounted

static func get_database() -> Dictionary:
	var db: Dictionary = {}
	
	# --- CARD 1: STRIKE ---
	var c1 = CardData.new()
	c1.card_id = 1
	c1.card_name = "Faith In the Emperor"
	c1.offence_icons = 0
	c1.defence_icons = 0
	c1.morale_icons = 0
	db[c1.card_id] = c1

	return db
