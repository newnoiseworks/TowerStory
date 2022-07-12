extends Spatial

onready var floor_packed = preload("res://scenes/floor/floor.tscn")

onready var mouse_select: Spatial = find_node("mouse_select")
onready var camera_gimbal: Spatial = find_node("camera_gimbal")
onready var current_level_ui: Label = find_node("current_level")
onready var floors: Spatial = find_node("floors")
onready var basement: Spatial = find_node("basement")

var _inputter = Input
var _main_button_press_target: Vector3
var _pieces_added_at: Vector3
var _is_main_button_pressed: bool = false

var previous_floor: Area
var current_floor: Area
var current_floor_idx = 1


# Pass a mock input object for testing
func _set_input(input):
	_inputter = input


func _ready():
	_create_new_current_floor()


func _unhandled_input(event):
	if event.is_action_released("move_up") or event.is_action_released("move_down"):
		_handle_floor_move(event)


func _handle_floor_move(event):
	if event.is_action_released("move_up") and floors.get_child_count() >= current_floor_idx and (current_floor_idx < 1 or current_floor._get_piece_count() > 0):
		previous_floor = _get_current_floor()
		current_floor_idx += 1
		mouse_select.translate_object_local(Vector3(
			0, camera_gimbal.camera_y_diff_per_floor, 0
		))

		_post_floor_change()
	elif event.is_action_released("move_down") and (current_floor_idx == 1 or basement.get_child_count() >= abs(current_floor_idx) and current_floor_idx <= 0 and current_floor._get_piece_count() > 0 or current_floor_idx > 0):
		previous_floor = _get_current_floor()
		current_floor_idx -= 1
		mouse_select.translate_object_local(Vector3(
			0, camera_gimbal.camera_y_diff_per_floor * -1, 0
		))

		_post_floor_change()


func _get_current_floor():
	return get_node_or_null("%s/floor%s/floor" % ["floors" if current_floor_idx > 0 else "basement", current_floor_idx])


func _post_floor_change():
	current_floor = _get_current_floor()
	if current_floor == null: _create_new_current_floor()

	if previous_floor.is_connected("input_event", self, "_on_floor_input_event"):
		previous_floor.disconnect("input_event", self, "_on_floor_input_event")

	if !current_floor.is_connected("input_event", self, "_on_floor_input_event"):
		var _c = current_floor.connect("input_event", self, "_on_floor_input_event")

	previous_floor.input_ray_pickable = false
	current_floor.input_ray_pickable = true

	previous_floor.set_transparent()
	current_floor.set_opaque()

	current_level_ui.text = str(current_floor_idx)
	camera_gimbal.change_floor(current_floor_idx)



func _on_floor_input_event(_camera, event, position, _normal, _shape_idx):
	position.x = TowerGlobals.closest_multiple_of(int(position.x))
	position.z = TowerGlobals.closest_multiple_of(int(position.z))

	if event is InputEventMouseMotion:
		_on_select_move(position)

	if event is InputEventMouseButton:
		_on_button_click()


func _on_button_click():
	var target = mouse_select.global_transform.origin
	target.y = 0

	if _inputter.is_action_pressed("main_button") and _is_main_button_pressed == false:
		_main_button_press_target = target
		_is_main_button_pressed = true
		current_floor.add_pieces_as_needed(target, _main_button_press_target, true)
	elif _inputter.is_action_just_released("main_button") and _is_main_button_pressed:
		current_floor.remove_pieces_as_needed(target, _main_button_press_target, true)
		current_floor.add_pieces_as_needed(target, _main_button_press_target)
		_is_main_button_pressed = false
	elif _inputter.is_action_just_released("secondary_button"):
		current_floor.remove_floor_piece_at(target)


func _on_select_move(mouse_position: Vector3):
	mouse_position.y = mouse_select.global_transform.origin.y

	var adjustment = mouse_position - mouse_select.global_transform.origin

	adjustment.x = TowerGlobals.closest_multiple_of(int(adjustment.x))
	adjustment.z = TowerGlobals.closest_multiple_of(int(adjustment.z))

	if adjustment != Vector3.ZERO:
		mouse_select.translate_object_local(adjustment)

		if _is_main_button_pressed:
			current_floor.remove_pieces_as_needed(_pieces_added_at, _main_button_press_target, true)
			current_floor.add_pieces_as_needed(mouse_position, _main_button_press_target, true)

			_pieces_added_at = mouse_position


func _create_new_current_floor():
	var new_floor_container = Spatial.new()
	current_floor = floor_packed.instance()
	current_floor.scale = Vector3(64, .1, 64)
	new_floor_container.add_child(current_floor)
	new_floor_container.name = "floor%s" % [current_floor_idx]
	current_floor.floor_idx = current_floor_idx

	if current_floor_idx > 0:
		floors.add_child(new_floor_container)
	else:
		basement.add_child(new_floor_container)

	new_floor_container.translate_object_local(Vector3(
		0, 1 * (current_floor_idx - 1), 0
	))

	current_floor.draw_floor()
	var _c = current_floor.connect("input_event", self, "_on_floor_input_event")
	current_floor.input_ray_pickable = true

	current_floor.building = self


