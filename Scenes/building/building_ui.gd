extends CanvasLayer

signal tool_change(user_tool)
signal facade_swap


func _on_tool_change_pressed(user_tool):
	emit_signal("tool_change", user_tool)


func _unhandled_input(event):
	if event.is_action_pressed("facade_swap"):
		emit_signal("facade_swap")


