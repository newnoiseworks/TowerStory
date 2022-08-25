extends CanvasLayer

func _on_tool_change_pressed(user_tool):
	TowerGlobals.emit_signal("tool_change", TowerGlobals.UI_TOOL.get(user_tool))


func _unhandled_input(event):
	if event.is_action_pressed("facade_swap"):
		TowerGlobals.emit_signal("facade_swap")


