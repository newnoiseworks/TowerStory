extends Spatial

onready var mouse_select: Spatial = find_node("mouse_select")
onready var camera_gimbal: Spatial = find_node("camera_gimbal")
onready var current_level_ui: Label = find_node("current_level")
onready var current_floor = get_node("floors/floor%s/floor" % [current_floor_idx])

var _inputter = Input

var current_floor_idx = 1


# Pass a mock input object for testing
func _set_input(input):
	_inputter = input


func _ready():
	current_floor.draw_floor()


func _unhandled_input(event):
	if event.is_action_released("move_up"):
		current_floor_idx += 1
		mouse_select.translate_object_local(Vector3(
			0,
			camera_gimbal.camera_y_diff_per_floor,
			0
		))
	elif event.is_action_released("move_down"):
		current_floor_idx -= 1
		mouse_select.translate_object_local(Vector3(
			0,
			camera_gimbal.camera_y_diff_per_floor * -1,
			0
		))

	current_level_ui.text = str(current_floor_idx)
	camera_gimbal.change_floor(current_floor_idx)


func _on_floor_input_event(_camera, event, position, _normal, _shape_idx):
	if event is InputEventMouseMotion:
		var mouse_position = position
		mouse_position.y = mouse_select.global_transform.origin.y

		var adjustment = mouse_position - mouse_select.global_transform.origin

		adjustment.x = _closest_multiple_of(int(adjustment.x))
		adjustment.z = _closest_multiple_of(int(adjustment.z))

		if adjustment != Vector3.ZERO:
			mouse_select.translate_object_local(adjustment)

	elif event is InputEventMouseButton:
		var global_target = mouse_select.global_transform.origin
		global_target.y = 0

		if _inputter.is_action_pressed("main_button"):
			current_floor.add_floor_piece_at(global_target)
		elif _inputter.is_action_pressed("secondary_button"):
			current_floor.remove_floor_piece_at(global_target)


func _closest_multiple_of(x: int)-> int:
	return _closest_multiple_of_n(x, current_floor.MULTIPLE)


func _closest_multiple_of_n(x: int, n: int)-> int:
	if (x % n == 0):
		return x

	var val: int = x / n

	return val * n

