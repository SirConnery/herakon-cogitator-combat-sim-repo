extends Node

# Emitted whenever a matrix matchup chunk completes processing
signal mass_sim_progress_updated(current: int, total: int)

func post_progress(current: int, total: int) -> void:
	mass_sim_progress_updated.emit(current, total)
