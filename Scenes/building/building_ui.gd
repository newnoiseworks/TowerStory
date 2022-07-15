extends CanvasLayer


signal tool_change(user_tool)


func _on_tool_change_pressed(user_tool):
	emit_signal("tool_change", user_tool)



