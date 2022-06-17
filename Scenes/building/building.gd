extends Spatial

onready var current_floor = find_node("floor")
onready var mouse_select: Spatial = find_node("mouse_select")

var _input = Input


# Pass a mock input object for testing
func _set_input(input):
	_input = input


func _ready():
	current_floor.draw_floor()


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

		if _input.is_action_pressed("main_button"):
			current_floor.add_floor_piece_at(global_target)
		elif _input.is_action_pressed("secondary_button"):
			current_floor.remove_floor_piece_at(global_target)


func _closest_multiple_of(x: int)-> int:
	return _closest_multiple_of_n(x, current_floor.MULTIPLE)


func _closest_multiple_of_n(x: int, n: int)-> int:
	if (x % n == 0):
		return x

	var val: int = x / n

	return val * n

