extends Control
class_name UI

func _ready() -> void:
	var sim = SimController.new()
	add_child(sim)
