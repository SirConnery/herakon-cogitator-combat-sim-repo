extends Control
class_name UI

@onready var round_panel_scene: PackedScene = preload("res://ui/combat_round_panel.tscn")

@onready var round_1_container: VBoxContainer = $MainLayout/CentralCombatView/RoundsContainer/Round1
@onready var round_2_container: VBoxContainer = $MainLayout/CentralCombatView/RoundsContainer/Round2
@onready var round_3_container: VBoxContainer = $MainLayout/CentralCombatView/RoundsContainer/Round3


func _ready() -> void:
	# Reset logger state
	G_Logger.clear_session()

	var round_containers := [
		round_1_container,
		round_2_container,
		round_3_container
	]

	# Build one panel per container
	for i in range(3):
		var panel_instance = round_panel_scene.instantiate() as CombatRoundPanel

		# Add to the specific round container
		round_containers[i].add_child(panel_instance)

		# Configure labels
		panel_instance.set_round_header_labels(i + 1)

		# Register with logger
		G_Logger.active_round_panels.append(panel_instance)

	# Start simulation
	var sim = SimController.new()
	add_child(sim)
