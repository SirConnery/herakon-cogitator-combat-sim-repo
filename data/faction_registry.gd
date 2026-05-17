class_name FactionRegistry
extends RefCounted

enum FactionID {
	ORKS,
	SM,
	CSM,
	ELDAR
}

static func get_database() -> Dictionary:
	var db: Dictionary = {}
	
	# --- SPACE MARINES (SM) ---
	db[FactionID.SM] = {
		"name": "Space Marines",
		"upgrade_deck": [1,1,1,1,1],
		"combat_deck": [1,1,1,1,1], # 10 cards
		"units": [
			{"unit_type": CardData.UnitType.SCOUTS, "unit_name": "Scouts", "tier": 0, "space_unit": false, "unit_count": 6, "combat_value": 1, "health_value": 2, "morale_value": 2},
			{"unit_type": CardData.UnitType.SPACE_MARINES, "unit_name": "Space Marines", "tier": 1, "space_unit": false, "unit_count": 6, "combat_value": 2, "health_value": 3, "morale_value": 3},
			{"unit_type": CardData.UnitType.LAND_RAIDERS, "unit_name": "Land Raiders", "tier": 2, "space_unit": false, "unit_count": 6, "combat_value": 3, "health_value": 4, "morale_value": 3},
			{"unit_type": CardData.UnitType.WARLORD_TITANS, "unit_name": "Warlord Titans", "tier": 3, "space_unit": false, "unit_count": 3, "combat_value": 3, "health_value": 5, "morale_value": 4}
		]
	}
	
	# --- ORKS ---
	db[FactionID.ORKS] = {
		"name": "Orks",
		"upgrade_deck": [1,1,1,1,1],
		"combat_deck": [1,1,1,1,1], # 10 cards
		"units": [
			{"unit_type": CardData.UnitType.ORK_BOYZ, "unit_name": "Ork Boyz", "tier": 0, "space_unit": false, "unit_count": 9, "combat_value": 2, "health_value": 2, "morale_value": 1},
			{"unit_type": CardData.UnitType.NOBZ, "unit_name": "Nobz", "tier": 1, "space_unit": false, "unit_count": 6, "combat_value": 2, "health_value": 4, "morale_value": 2},
			{"unit_type": CardData.UnitType.BATTLEWAGONS, "unit_name": "Battlewagons", "tier": 2, "space_unit": false, "unit_count": 3, "combat_value": 3, "health_value": 5, "morale_value": 2},
			{"unit_type": CardData.UnitType.GARGANTS, "unit_name": "Gargants", "tier": 3, "space_unit": false, "unit_count": 3, "combat_value": 3, "health_value": 6, "morale_value": 3}
		]
	}
	
	# --- CHAOS SPACE MARINES (CSM) ---
	db[FactionID.CSM] = {
		"name": "Chaos Space Marines",
		"upgrade_deck": [1],
		"combat_deck": [1], # 10 cards
		"units": [
			{"unit_type": CardData.UnitType.CULTISTS, "unit_name": "Cultists", "tier": 0, "space_unit": false, "unit_count": 9, "combat_value": 1, "health_value": 2, "morale_value": 2},
			{"unit_type": CardData.UnitType.CHAOS_SPACE_MARINES, "unit_name": "Chaos Space Marines", "tier": 1, "space_unit": false, "unit_count": 6, "combat_value": 3, "health_value": 3, "morale_value": 2},
			{"unit_type": CardData.UnitType.HELBRUTES, "unit_name": "Helbrutes", "tier": 2, "space_unit": false, "unit_count": 3, "combat_value": 3, "health_value": 4, "morale_value": 3},
			{"unit_type": CardData.UnitType.CHAOS_REAVER_TITANS, "unit_name": "Chaos Reaver Titans", "tier": 3, "space_unit": false, "unit_count": 3, "combat_value": 4, "health_value": 5, "morale_value": 3}
		]
	}
	
	# --- ELDAR ---
	db[FactionID.ELDAR] = {
		"name": "Eldar",
		"upgrade_deck": [1],
		"combat_deck": [1], # 10 cards
		"units": [
			{"unit_type": CardData.UnitType.ASPECT_WARRIORS, "unit_name": "Aspect Warriors", "tier": 0, "space_unit": false, "unit_count": 6, "combat_value": 2, "health_value": 1, "morale_value": 2},
			{"unit_type": CardData.UnitType.WRAITHGUARD, "unit_name": "Wraithguard", "tier": 1, "space_unit": false, "unit_count": 3, "combat_value": 2, "health_value": 4, "morale_value": 2},
			{"unit_type": CardData.UnitType.FALCONS, "unit_name": "Falcons", "tier": 2, "space_unit": false, "unit_count": 3, "combat_value": 3, "health_value": 4, "morale_value": 3},
			{"unit_type": CardData.UnitType.WARLOCK_TITANS, "unit_name": "Warlock Titans", "tier": 3, "space_unit": false, "unit_count": 3, "combat_value": 4, "health_value": 5, "morale_value": 3}
		]
	}
	
	return db
