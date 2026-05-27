class_name FactionRegistry
extends RefCounted

enum FactionID {
	SPACE_MARINES,
	CHAOS,
	ORKS,
	ELDAR,
}

static func get_database() -> Dictionary:
	var db: Dictionary = {}
	
	# =========================================================================
	# --- SPACE MARINES (SM) ---
	# =========================================================================
	db[FactionID.SPACE_MARINES] = {
		"name": "Space Marines",
		"debug_deck": [1014], # place card number here. That card becomes your combat_deck with 10 copies. 
		"upgrade_deck": [1001,1002,1003,1004,1005,1006,1007,1008,1010,1011,1012,1013,1014],
		"combat_deck": [],
		"units": [
			# Ground Units
			{"unit_type": CardData.UnitType.SCOUTS, "unit_name": "Scouts", "tier": 0, "is_ship": false, "unit_count": 6, "combat_value": 1, "health_value": 2, "morale_value": 2},
			{"unit_type": CardData.UnitType.SPACE_MARINES, "unit_name": "Space Marines", "tier": 1, "is_ship": false, "unit_count": 6, "combat_value": 2, "health_value": 3, "morale_value": 3},
			{"unit_type": CardData.UnitType.LAND_RAIDERS, "unit_name": "Land Raiders", "tier": 2, "is_ship": false, "unit_count": 6, "combat_value": 3, "health_value": 4, "morale_value": 3},
			{"unit_type": CardData.UnitType.WARLORD_TITANS, "unit_name": "Warlord Titans", "tier": 3, "is_ship": false, "unit_count": 3, "combat_value": 3, "health_value": 5, "morale_value": 4},
			# Ships
			{"unit_type": CardData.UnitType.STRIKE_CRUISERS, "unit_name": "Strike Cruisers", "tier": 0, "is_ship": true, "unit_count": 3, "combat_value": 2, "health_value": 2, "morale_value": 2},
			{"unit_type": CardData.UnitType.BATTLE_BARGES, "unit_name": "Battle Barges", "tier": 2, "is_ship": true, "unit_count": 3, "combat_value": 4, "health_value": 5, "morale_value": 4},
		]
	}
	
	# =========================================================================
	# --- CHAOS SPACE MARINES (CSM) ---
	# =========================================================================
	db[FactionID.CHAOS] = {
		"name": "Chaos",
		"debug_deck": [2001],
		"upgrade_deck": [],
		"combat_deck": [],
		"units": [
			# Ground Units
			{"unit_type": CardData.UnitType.CULTISTS, "unit_name": "Cultists", "tier": 0, "is_ship": false, "unit_count": 9, "combat_value": 1, "health_value": 2, "morale_value": 2},
			{"unit_type": CardData.UnitType.CHAOS_SPACE_MARINES, "unit_name": "Chaos Marines", "tier": 1, "is_ship": false, "unit_count": 6, "combat_value": 3, "health_value": 3, "morale_value": 2},
			{"unit_type": CardData.UnitType.HELBRUTES, "unit_name": "Helbrutes", "tier": 2, "is_ship": false, "unit_count": 3, "combat_value": 3, "health_value": 4, "morale_value": 3},
			{"unit_type": CardData.UnitType.CHAOS_REAVER_TITANS, "unit_name": "Chaos Reaver Titans", "tier": 3, "is_ship": false, "unit_count": 3, "combat_value": 4, "health_value": 5, "morale_value": 3},
			# Ships
			{"unit_type": CardData.UnitType.ICONOCLAST_DESTROYERS, "unit_name": "Iconoclasts", "tier": 0, "is_ship": true, "unit_count": 3, "combat_value": 2, "health_value": 2, "morale_value": 2},
			{"unit_type": CardData.UnitType.REPULSIVE_GRAND_CRUISERS, "unit_name": "Grand Cruisers", "tier": 2, "is_ship": true, "unit_count": 3, "combat_value": 4, "health_value": 5, "morale_value": 4}
		]
	}
	
	# =========================================================================
	# --- ORKS ---
	# =========================================================================
	db[FactionID.ORKS] = {
		"name": "Orks",
		"debug_deck": [],
		"upgrade_deck": [3001,3002,3003,3004,3005,3006,3007,3008,3009,3010,3011,3012,3013,3014],
		"combat_deck": [],
		"units": [
			# Ground Units
			{"unit_type": CardData.UnitType.ORK_BOYZ, "unit_name": "Ork Boyz", "tier": 0, "is_ship": false, "unit_count": 9, "combat_value": 2, "health_value": 2, "morale_value": 1},
			{"unit_type": CardData.UnitType.NOBZ, "unit_name": "Nobz", "tier": 1, "is_ship": false, "unit_count": 6, "combat_value": 2, "health_value": 4, "morale_value": 2},
			{"unit_type": CardData.UnitType.BATTLE_WAGONS, "unit_name": "Battle Wagons", "tier": 2, "is_ship": false, "unit_count": 3, "combat_value": 3, "health_value": 5, "morale_value": 2},
			{"unit_type": CardData.UnitType.GARGANTS, "unit_name": "Gargants", "tier": 3, "is_ship": false, "unit_count": 3, "combat_value": 3, "health_value": 6, "morale_value": 3},
			# Ships
			{"unit_type": CardData.UnitType.ONSLAUGHTS, "unit_name": "Onslaughts", "tier": 0, "is_ship": true, "unit_count": 3, "combat_value": 1, "health_value": 3, "morale_value": 2},
			{"unit_type": CardData.UnitType.KILL_KROOZERS, "unit_name": "Kill Kroozers", "tier": 2, "is_ship": true, "unit_count": 3, "combat_value": 3, "health_value": 6, "morale_value": 4}
		]
	}

	# =========================================================================
	# --- ELDAR ---
	# =========================================================================
	db[FactionID.ELDAR] = {
		"name": "Eldar",
		"debug_deck": [],
		"upgrade_deck": [1001],
		"combat_deck": [],
		"units": [
			# Ground Units
			{"unit_type": CardData.UnitType.ASPECT_WARRIORS, "unit_name": "Aspect Warriors", "tier": 0, "is_ship": false, "unit_count": 6, "combat_value": 2, "health_value": 1, "morale_value": 2},
			{"unit_type": CardData.UnitType.WRAITHGUARDS, "unit_name": "Wraithguards", "tier": 1, "is_ship": false, "unit_count": 3, "combat_value": 2, "health_value": 4, "morale_value": 2},
			{"unit_type": CardData.UnitType.FALCONS, "unit_name": "Falcons", "tier": 2, "is_ship": false, "unit_count": 3, "combat_value": 3, "health_value": 4, "morale_value": 3},
			{"unit_type": CardData.UnitType.WARLOCK_TITANS, "unit_name": "Warlock Titans", "tier": 3, "is_ship": false, "unit_count": 3, "combat_value": 4, "health_value": 5, "morale_value": 3},
			# Ships
			{"unit_type": CardData.UnitType.HELLEBORE_FRIGATES, "unit_name": "Hellebore Frigates", "tier": 0, "is_ship": true, "unit_count": 6, "combat_value": 3, "health_value": 2, "morale_value": 1},
			{"unit_type": CardData.UnitType.VOID_STALKERS, "unit_name": "Void Stalkers", "tier": 2, "is_ship": true, "unit_count": 3, "combat_value": 4, "health_value": 5, "morale_value": 4}
		]
	}

	return db


static func fake_db () -> Dictionary:
	var db: Dictionary = {}
	# =========================================================================
	# --- IMPERIAL GUARD ---
	# =========================================================================
	var IG = {
		"name": "Imperial Guard",
		"debug_deck": [],
		"upgrade_deck": [],
		"combat_deck": [],
		"units": [
			# Ground Units 
			{"unit_type": CardData.UnitType.GUARDSMEN, "unit_name": "Guardsmen", "tier": 0, "is_ship": false, "unit_count": 12, "combat_value": 1, "health_value": 1, "morale_value": 2},
			{"unit_type": CardData.UnitType.OGRYNS, "unit_name": "Ogryns", "tier": 1, "is_ship": false, "unit_count": 6, "combat_value": 2, "health_value": 4, "morale_value": 2},
			{"unit_type": CardData.UnitType.LEMAN_RUSS_BATTLE_TANKS, "unit_name": "Leman Russ Tanks", "tier": 2, "is_ship": false, "unit_count": 6, "combat_value": 3, "health_value": 4, "morale_value": 3},
			{"unit_type": CardData.UnitType.WARHOUND_TITANS, "unit_name": "Warhound Titans", "tier": 3, "is_ship": false, "unit_count": 3, "combat_value": 3, "health_value": 5, "morale_value": 4},
			# Ships
			{"unit_type": CardData.UnitType.LUNAR_CLASS_CRUISERS, "unit_name": "Lunar Cruisers", "tier": 0, "is_ship": true, "unit_count": 3, "combat_value": 2, "health_value": 2, "morale_value": 2},
			{"unit_type": CardData.UnitType.EMPEROR_CLASS_BATTLESHIPS, "unit_name": "Emperor Battleships", "tier": 2, "is_ship": true, "unit_count": 3, "combat_value": 4, "health_value": 6, "morale_value": 3}
		]
	}
	
	# =========================================================================
	# --- TYRANIDS ---
	# =========================================================================
	var tyrannid = {
		"name": "Tyranids",
		"debug_deck": [],
		"upgrade_deck": [],
		"combat_deck": [],
		"units": [
			# Ground Units
			{"unit_type": CardData.UnitType.GAUNTS, "unit_name": "Gaunts", "tier": 0, "is_ship": false, "unit_count": 9, "combat_value": 1, "health_value": 1, "morale_value": 3},
			{"unit_type": CardData.UnitType.TYRANNID_WARRIORS, "unit_name": "Tyrannid Warriors", "tier": 1, "is_ship": false, "unit_count": 6, "combat_value": 3, "health_value": 2, "morale_value": 3},
			{"unit_type": CardData.UnitType.CARNIFEXES, "unit_name": "Carnifexes", "tier": 2, "is_ship": false, "unit_count": 3, "combat_value": 4, "health_value": 3, "morale_value": 3},
			{"unit_type": CardData.UnitType.HIEROPHANT_BIO_TITANS, "unit_name": "Bio Titans", "tier": 3, "is_ship": false, "unit_count": 3, "combat_value": 5, "health_value": 4, "morale_value": 3},
			# Ships
			{"unit_type": CardData.UnitType.DEVOURER_BIO_SHIPS, "unit_name": "Devourers", "tier": 0, "is_ship": true, "unit_count": 6, "combat_value": 1, "health_value": 2, "morale_value": 3},
			{"unit_type": CardData.UnitType.LEVIATHAN_HIVE_SHIPS, "unit_name": "Hive Ships", "tier": 2, "is_ship": true, "unit_count": 3, "combat_value": 3, "health_value": 6, "morale_value": 4}
		]
	}
	
	# =========================================================================
	# --- NECRONS ---
	# =========================================================================
	var necrons = {
		"name": "Necrons",
		"debug_deck": [],
		"upgrade_deck": [],
		"combat_deck": [],
		"units": [
			# Ground Units
			{"unit_type": CardData.UnitType.NECRON_WARRIORS, "unit_name": "Necron Warriors", "tier": 0, "is_ship": false, "unit_count": 4, "combat_value": 2, "health_value": 3, "morale_value": 0},
			{"unit_type": CardData.UnitType.IMMORTALS, "unit_name": "Immortals", "tier": 1, "is_ship": false, "unit_count": 3, "combat_value": 3, "health_value": 4, "morale_value": 1},
			{"unit_type": CardData.UnitType.MONOLITHS, "unit_name": "Monoliths", "tier": 2, "is_ship": false, "unit_count": 2, "combat_value": 3, "health_value": 5, "morale_value": 2},
			{"unit_type": CardData.UnitType.CTAN_SHARDS, "unit_name": "C'tan Shards", "tier": 3, "is_ship": false, "unit_count": 1, "combat_value": 3, "health_value": 6, "morale_value": 3},
			# Ships
			{"unit_type": CardData.UnitType.HARVEST_SHIPS, "unit_name": "Harvest Ships", "tier": 0, "is_ship": true, "unit_count": 3, "combat_value": 2, "health_value": 3, "morale_value": 1},
			{"unit_type": CardData.UnitType.CAIRN_TOMB_SHIPS, "unit_name": "Cairn Tomb Ships", "tier": 2, "is_ship": true, "unit_count": 2, "combat_value": 3, "health_value": 6, "morale_value": 4}
		]
	}
	
	# =========================================================================
	# --- T'AU EMPIRE ---
	# =========================================================================
	var tau = {
		"name": "T'au Empire",
		"debug_deck": [],
		"upgrade_deck": [],
		"combat_deck": [],
		"units": [
			# Ground Units
			{"unit_type": CardData.UnitType.FIRE_WARRIORS, "unit_name": "Fire Warriors", "tier": 0, "is_ship": false, "unit_count": 6, "combat_value": 2, "health_value": 1, "morale_value": 2},
			{"unit_type": CardData.UnitType.CRISIS_BATTLE_SUITS, "unit_name": "Crisis Battlesuits", "tier": 1, "is_ship": false, "unit_count": 6, "combat_value": 3, "health_value": 3, "morale_value": 2},
			{"unit_type": CardData.UnitType.HAMMERHEAD_GUNSHIPS, "unit_name": "Hammerhead Gunships", "tier": 2, "is_ship": false, "unit_count": 3, "combat_value": 4, "health_value": 4, "morale_value": 2},
			{"unit_type": CardData.UnitType.SUPREMACY_ARMOURS, "unit_name": "Supremacy Armours", "tier": 3, "is_ship": false, "unit_count": 3, "combat_value": 4, "health_value": 5, "morale_value": 3},
			# Ships
			{"unit_type": CardData.UnitType.PROTECTOR_CRUISERS, "unit_name": "Protector Cruisers", "tier": 0, "is_ship": true, "unit_count": 2, "combat_value": 3, "health_value": 1, "morale_value": 2},
			{"unit_type": CardData.UnitType.CUSTODIAN_CARRIERS, "unit_name": "Custodian Carriers", "tier": 2, "is_ship": true, "unit_count": 2, "combat_value": 5, "health_value": 4, "morale_value": 4}
		]
	}
	
	
	return db
