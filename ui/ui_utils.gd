extends RefCounted
class_name UI_Utils

## Safely and completely purges all child nodes from a target parent container
static func clear_children(container: Node) -> void:
	if container == null:
		return
		
	for child in container.get_children():
		if is_instance_valid(child):
			child.queue_free()
