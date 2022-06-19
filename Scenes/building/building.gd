extends Spatial

onready var floor_packed = preload("res://scenes/floor/floor.tscn")

onready var mouse_select: Spatial = find_node("mouse_select")
onready var camera_gimbal: Spatial = find_node("camera_gimbal")
onready var current_level_ui: Label = find_node("current_level")
onready var floors: Spatial = find_node("floors")
onready var basement: Spatial = find_node("basement")
onready var current_floor = get_node("floors/floor%s/floor" % [current_floor_idx])
onready var previous_floor = current_floor

var _inputter = Input

var current_floor_idx = 1


# Pass a mock input object for testing
func _set_input(input):
	_inputter = input


func _ready():
	current_floor.draw_floor()


func _unhandled_input(event):

	if event.is_action_released("move_up") and floors.get_child_count() >= current_floor_idx:
		previous_floor = get_node("floors/floor%s/floor" % [current_floor_idx])
		current_floor_idx += 1
		mouse_select.translate_object_local(Vector3(
			0,
			camera_gimbal.camera_y_diff_per_floor,
			0
		))
	elif event.is_action_released("move_down") and basement.get_child_count() < current_floor_idx:
		previous_floor = get_node("floors/floor%s/floor" % [current_floor_idx])
		current_floor_idx -= 1
		mouse_select.translate_object_local(Vector3(
			0,
			camera_gimbal.camera_y_diff_per_floor * -1,
			0
		))

	current_floor = get_node_or_null("floors/floor%s/floor" % [current_floor_idx])
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

		if current_floor == null:
			_create_new_current_floor()

		if _inputter.is_action_pressed("main_button"):
			if (current_floor_idx > 1 and current_floor._get_piece_count() == 0):
				var floor_under = get_node("floors/floor%s/floor" % [current_floor_idx - 1])
				if (floor_under.has_floor_piece_at(global_target)):
					current_floor.add_floor_piece_at(global_target)
			else:
				current_floor.add_floor_piece_at(global_target)
		elif _inputter.is_action_pressed("secondary_button"):
			current_floor.remove_floor_piece_at(global_target)


func _create_new_current_floor():
			var new_floor_container = Spatial.new()
			current_floor = floor_packed.instance()
			new_floor_container.add_child(current_floor)
			new_floor_container.name = "floor%s" % [current_floor_idx]

			if current_floor_idx > 0:
				floors.add_child(new_floor_container)
			else:
				basement.add_child(new_floor_container)

			new_floor_container.translate_object_local(Vector3(
				0, 1 * (current_floor_idx - 1), 0
			))

			current_floor.draw_floor()


func _closest_multiple_of(x: int)-> int:
	return _closest_multiple_of_n(
		x,
		TowerGlobals.TILE_MULTIPLE	
	)


func _closest_multiple_of_n(x: int, n: int)-> int:
	if (x % n == 0):
		return x

	var val: int = x / n

	return val * n

