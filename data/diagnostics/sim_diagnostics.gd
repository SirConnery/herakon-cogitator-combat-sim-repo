class_name SimDiagnostics
extends RefCounted

var atk_name_string := ""
var def_name_string := ""
var total_matches_targeted := 0

var attacker_wins := 0
var defender_wins := 0

# Database placeholder for tracking: card_id -> {"seen": int, "wins": int}
var card_stats := {}

## Prepares the analytics tracker with faction identities and active database entries
func initialize_session(atk_name: String, def_name: String, total_count: int, raw_cards: Dictionary) -> void:
	atk_name_string = atk_name
	def_name_string = def_name
	total_matches_targeted = total_count
	
	attacker_wins = 0
	defender_wins = 0
	card_stats.clear()
	
	for card_id in raw_cards.keys():
		if card_id > 0: # Safely ignore the structural dummy slot
			card_stats[card_id] = {"seen": 0, "wins": 0}
			
	print("Starting Mass Simulation: %s vs %s (%d matches)\n" % [atk_name_string, def_name_string, total_matches_targeted])


## Records metrics out of a single completed engine match iteration
func record_match_result(match_index: int, attacker_won: bool, atk_initial_hand: Array, def_initial_hand: Array) -> void:
	if attacker_won:
		attacker_wins += 1
		print("Match #%d: WINNER -> %s" % [match_index + 1, atk_name_string])
	else:
		defender_wins += 1
		print("Match #%d: WINNER -> %s" % [match_index + 1, def_name_string])
		
	# Deduplicate hand arrays to ensure accurate indicators per match pass
	var atk_unique := []
	for card_id in atk_initial_hand:
		if card_id > 0 and not card_id in atk_unique:
			atk_unique.append(card_id)
			
	var def_unique := []
	for card_id in def_initial_hand:
		if card_id > 0 and not card_id in def_unique:
			def_unique.append(card_id)
			
	# Process updates onto tracking collections safely
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


## Aggregates total wins and compiles the sorted performance leaderboard table
func generate_final_report(controller_ref: Node) -> void:
	print("\n=================== SIMULATION SUMMARY ===================")
	print("%s Total Wins: %d" % [atk_name_string, attacker_wins])
	print("%s Total Wins: %d" % [def_name_string, defender_wins])
	
	var global_win_rate := (float(attacker_wins) / float(total_matches_targeted)) * 100.0
	print("%s Cumulative Win Rate: %.1f%%" % [atk_name_string, global_win_rate])
	
	print("\n=================== CARD PERFORMANCE REPORT ===================")
	print("%-26s | %-9s | %-6s | %-8s" % ["Card Name", "In Hand", "Wins", "Hand WR"])
	print("---------------------------+-----------+--------+----------")
	
	# Filter unrepresented entries and sort from highest win rate to lowest
	var active_tracked_cards := card_stats.keys().filter(func(id): return card_stats[id]["seen"] > 0)
	active_tracked_cards.sort_custom(func(a, b):
		var wr_a := float(card_stats[a]["wins"]) / float(card_stats[a]["seen"])
		var wr_b := float(card_stats[b]["wins"]) / float(card_stats[b]["seen"])
		if wr_a == wr_b:
			return card_stats[a]["seen"] > card_stats[b]["seen"] # Tiebreaker: frequency
		return wr_a > wr_b
	)
	
	for card_id in active_tracked_cards:
		var name_string: String = controller_ref.get_card_metadata(card_id, "card_name")
		var seen_count: int = card_stats[card_id]["seen"]
		var wins_count: int = card_stats[card_id]["wins"]
		var win_rate := (float(wins_count) / float(seen_count)) * 100.0
		
		print("%-26s | %-9d | %-6d | %.1f%%" % [name_string, seen_count, wins_count, win_rate])
	print("===============================================================\n")
