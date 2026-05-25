class_name FactionRegistry
extends RefCounted

enum FactionID {
	SPACE_MARINES,
	ORKS,
	CSM,
	ELDAR
}

static func get_database() -> Dictionary:
	var db: Dictionary = {}
	
	# --- SPACE MARINES (SM) ---
	db[FactionID.SPACE_MARINES] = {
		"name": "Space Marines",
		"debug_deck": [1014], # used instead of combat_deck when game_stage_generator.use_debug_deck_for_testing == true
		"upgrade_deck": [1001,1002,1003,1004,1005],
		"combat_deck": [],
		"units": [
			{"unit_type": CardData.UnitType.SCOUTS, "unit_name": "Scouts", "tier": 0, "is_ship": false, "unit_count": 6, "combat_value": 1, "health_value": 2, "morale_value": 2},
			{"unit_type": CardData.UnitType.SPACE_MARINES, "unit_name": "Space Marines", "tier": 1, "is_ship": false, "unit_count": 6, "combat_value": 2, "health_value": 3, "morale_value": 3},
			{"unit_type": CardData.UnitType.LAND_RAIDERS, "unit_name": "Land Raiders", "tier": 2, "is_ship": false, "unit_count": 6, "combat_value": 3, "health_value": 4, "morale_value": 3},
			{"unit_type": CardData.UnitType.WARLORD_TITANS, "unit_name": "Warlord Titans", "tier": 3, "is_ship": false, "unit_count": 3, "combat_value": 3, "health_value": 5, "morale_value": 4},
			# Space Marine Ships
			{"unit_type": CardData.UnitType.STRIKE_CRUISERS, "unit_name": "Strike Cruisers", "tier": 0, "is_ship": true, "unit_count": 3, "combat_value": 2, "health_value": 2, "morale_value": 2},
			{"unit_type": CardData.UnitType.BATTLE_BARGES, "unit_name": "Battle Barges", "tier": 2, "is_ship": true, "unit_count": 3, "combat_value": 4, "health_value": 5, "morale_value": 4},
		]
	}
	
	# --- ORKS ---
	db[FactionID.ORKS] = {
		"name": "Orks",
		"debug_deck": [3007],
		"upgrade_deck": [3001,3002,3003,],
		"combat_deck": [],
		"units": [
			{"unit_type": CardData.UnitType.ORK_BOYZ, "unit_name": "Ork Boyz", "tier": 0, "is_ship": false, "unit_count": 9, "combat_value": 2, "health_value": 2, "morale_value": 1},
			{"unit_type": CardData.UnitType.NOBZ, "unit_name": "Nobz", "tier": 1, "is_ship": false, "unit_count": 6, "combat_value": 2, "health_value": 4, "morale_value": 2},
			{"unit_type": CardData.UnitType.BATTLEWAGONS, "unit_name": "Battlewagons", "tier": 2, "is_ship": false, "unit_count": 3, "combat_value": 3, "health_value": 5, "morale_value": 2},
			{"unit_type": CardData.UnitType.GARGANTS, "unit_name": "Gargants", "tier": 3, "is_ship": false, "unit_count": 3, "combat_value": 3, "health_value": 6, "morale_value": 3},
			# Ork Ships
			{"unit_type": CardData.UnitType.ONSLAUGHTS, "unit_name": "Onslaughts", "tier": 0, "is_ship": true, "unit_count": 3, "combat_value": 1, "health_value": 3, "morale_value": 2},
			{"unit_type": CardData.UnitType.KILL_KROOZERS, "unit_name": "Kill Kroozers", "tier": 2, "is_ship": true, "unit_count": 3, "combat_value": 3, "health_value": 6, "morale_value": 4}
		]
	}

	return db
