extends Spatial

func _unhandled_input(event):
	if event.is_action_pressed("ui_scroll_up"):
		translate_object_local(Vector3(0, 1, 0))

	if event.is_action_pressed("ui_scroll_down"):
		translate_object_local(Vector3(0, -1, 0))

