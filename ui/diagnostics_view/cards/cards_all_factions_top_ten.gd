extends Control

const FACTION_BAR_V = preload("uid://bpwm0ac0xfcbw")

@onready var cards_all_factions_top_ten_values: HBoxContainer = %CardsAllFactionsTopTenValues

## Dynamically populates the global tab sheet with the top 10 highest performing cards
func initialize_global_card_rows(sorted_card_data: Array[Dictionary]) -> void:
	if cards_all_factions_top_ten_values == null:
		return
		
	# 1. Clear out any previous layout generation nodes cleanly
	for child in cards_all_factions_top_ten_values.get_children():
		child.queue_free()
		
	# 2. Slice the dataset down to a maximum of the top 10 entries
	# (Since the main controller already passes this array presorted descending, 
	# the first 10 elements are guaranteed to be your highest win-rates)
	var top_ten_cards := sorted_card_data.slice(0, 10)
	
	# 3. Spawn a vertical card bar for each top tier card entry
	for card in top_ten_cards:
		var bar_instance = FACTION_BAR_V.instantiate()
		cards_all_factions_top_ten_values.add_child(bar_instance)
		
		# Draw name, win rate %, and total wins to the vertical bar layout component
		bar_instance.populate_bar(card["name"], card["rate"], card["wins"])
