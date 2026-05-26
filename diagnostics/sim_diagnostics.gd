class_name SimDiagnostics
extends RefCounted

# Structure: faction_id (int) -> { "atk_wins": int, "atk_games": int, "def_wins": int, "def_games": int }
var faction_stats := {}

# Structure: card_id (int) -> { "seen": int, "wins": int }
var card_stats := {}

var total_matches_processed := 0


## Reads the multi-faction raw binary matrix file and compiles aggregate analytics
func load_and_parse_binary(file_path: String, factions_pool: Array[FactionRegistry.FactionID]) -> bool:
	if not FileAccess.file_exists(file_path):
		push_error("Analytics Error: Target binary dataset file not found.")
		return false
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
		
	# 1. RESET STATE & INITIALIZE TARGET DICTIONARIES
	total_matches_processed = 0
	faction_stats.clear()
	card_stats.clear()
	
	# Pre-populate structures for all participating factions in the simulation pool
	for f_id in factions_pool:
		faction_stats[int(f_id)] = {
			"atk_wins": 0,
			"atk_games": 0,
			"def_wins": 0,
			"def_games": 0
		}
		
	# Pre-populate card performance metrics tracker from the master database
	var raw_cards: Dictionary = CardRegistry.get_database()
	for card_id in raw_cards.keys():
		if card_id > 0:
			card_stats[card_id] = {"seen": 0, "wins": 0}
			
	# 2. DATA EXTRACTION CRUNCHING LOOP
	while file.get_position() < file.get_length():
		var data = file.get_var()
		if data is Array:
			total_matches_processed += 1
			
			var stage: int = data[1]
			var atk_id: int = data[2]
			var def_id: int = data[3]
			var attacker_won: bool = (data[4] == 1)
			var atk_hand: Array = data[5]
			var def_hand: Array = data[6]
			
			# Process faction wins/losses based on their matrix assignment
			_process_faction_metrics(atk_id, def_id, attacker_won)
			
			# Process individual card win-rates based on what was held in hand
			_process_card_metrics(attacker_won, atk_hand, def_hand)
			
	return true


## Internal aggregator for tracking global faction role performance counters
func _process_faction_metrics(atk_id: int, def_id: int, attacker_won: bool) -> void:
	# Ensure the tracking keys exist (handles dynamic pool registration safety)
	if not faction_stats.has(atk_id) or not faction_stats.has(def_id):
		return
		
	# Update denominator attempt totals
	faction_stats[atk_id]["atk_games"] += 1
	faction_stats[def_id]["def_games"] += 1
	
	# Award win state integers
	if attacker_won:
		faction_stats[atk_id]["atk_wins"] += 1
	else:
		faction_stats[def_id]["def_wins"] += 1


## Internal aggregator for card performance tracking loops
func _process_card_metrics(attacker_won: bool, atk_initial_hand: Array, def_initial_hand: Array) -> void:
	var atk_unique := []
	for card_id in atk_initial_hand:
		if card_id > 0 and not card_id in atk_unique:
			atk_unique.append(card_id)
			
	var def_unique := []
	for card_id in def_initial_hand:
		if card_id > 0 and not card_id in def_unique:
			def_unique.append(card_id)
			
	for card_id in atk_unique:
		if card_stats.has(card_id):
			card_stats[card_id]["seen"] += 1
			if attacker_won:
				card_stats[card_id]["wins"] += 1
				
	for card_id in def_unique:
		if card_stats.has(card_id):
			card_stats[card_id]["seen"] += 1
			if not attacker_won:
				card_stats[card_id]["wins"] += 1
