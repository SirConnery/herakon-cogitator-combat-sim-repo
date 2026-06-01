extends Node

signal mass_sim_completed

func mass_combat_simulation_done() -> void:
	mass_sim_completed.emit()
