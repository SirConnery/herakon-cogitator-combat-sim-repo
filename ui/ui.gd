extends Control

# Note: Ensure these nodes have Scene Unique Names (%) enabled in the Editor
@onready var console_log: RichTextLabel = %ConsoleLog
@onready var rounds_container: HBoxContainer = %RoundsContainer

var current_round_index: int = 0

func _ready() -> void:
	# Connect your button if you haven't via the editor
	%StartNewCombat.pressed.connect(_on_start_combat_pressed)

func _on_start_combat_pressed() -> void:
	# 1. Clear the old UI state
	console_log.text = "--- INITIALIZING NEW MATCH ---\n"
	
	# 2. Instantiate a fresh controller
	var sim = SimController.new() # Assuming your controller is named sim_controller.gd
	add_child(sim)
	
	# 3. You can set export variables here if your UI has dropdowns!
	# sim.attacker_faction = ...
	
	# 4. Run the battle, passing in our UI router function
	sim.run_single_logged_battle(_route_engine_event)
	
	# 5. Clean up the invisible engine node so we don't leak memory
	sim.queue_free()


## This is the Master Traffic Cop. Every single engine event passes through here.
func _route_engine_event(event_type: String, data: Array) -> void:
	
	# --- A: GLOBAL CHRONOLOGICAL LOGGING ---
	var log_string := _format_log_string(event_type, data)
	if log_string != "":
		console_log.append_text(log_string + "\n")
		
	# --- B: VISUAL UI PANEL ROUTING ---
	match event_type:
		"round_start":
			# The engine tells us which round we are on (0, 1, or 2)
			current_round_index = data[0] 
			
		"unit_status_logged":
			# Find the specific Round.tscn instance
			var active_round_panel = rounds_container.get_child(current_round_index)
			# Pass the data down to the encapsulated script!
			active_round_panel.update_army_lists(data[0], data[1], data[2])
			
		"dice_rolled":
			var active_round_panel = rounds_container.get_child(current_round_index)
			active_round_panel.update_dice_pools(data[0], data[1], data[2], data[3])
			
		# Add other specific visual routings here (cards played, damage markers, etc.)

## Helper to convert your old print() statements into strings for the RichTextLabel
func _format_log_string(event_type: String, data: Array) -> String:
	match event_type:
		"combat_start":
			return "[b]STARTED COMBAT[/b]\nMatchup Scale: " + str(data) # Simplify as needed
		"dice_rolled":
			return " -> %s Rolls: %d ⚔️, %d 🛡️, %d 🦅" % [data[0], data[1], data[2], data[3]]
		"unit_routed":
			return "   -> 🏳️ [color=yellow]%s '%s' took %d damage and ROUTED![/color]" % [data[0], data[1], data[2]]
		"unit_destroyed":
			return "   -> 💀 [color=red]%s '%s' was DESTROYED![/color]" % [data[0], data[1]]
	return "" # Ignore events you don't want in the text log
