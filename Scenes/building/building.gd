extends Node3D

@onready var floor_packed = preload("res://scenes/floor/floor.tscn")

@onready var mouse_select: Node3D = find_child("mouse_select")
@onready var camera_gimbal: Node3D = find_child("camera_gimbal")
@onready var current_level_ui: Label = find_child("current_level")
@onready var floors: Node3D = find_child("floors")
@onready var basement: Node3D = find_child("basement")
@onready var debug_cursor_label: Label = find_child("cursor_position")

var _inputter = Input
var _main_button_press_target: Vector3
var _pieces_added_at: Vector3
var _is_main_button_pressed: bool = false
var _current_tool: int = TowerGlobals.UI_TOOL.BASE_TILE
var _is_facade_visible: bool = false

var previous_floor: Area3D
var current_floor: Area3D
var current_floor_idx = 1


func get_mouse_target_pos():
	var target = mouse_select.global_transform.origin

	target.x = TowerGlobals.closest_multiple_of(int(target.x))
	target.z = TowerGlobals.closest_multiple_of(int(target.z))

	return target


# Pass a mock input object for testing
func _set_input(input):
	_inputter = input


func _ready():
	_create_new_current_floor()

	var _c = TowerGlobals.connect("tool_change", Callable(self, "_on_tool_change_pressed"))
	_c = TowerGlobals.connect("facade_swap", Callable(self, "_toggle_facade"))


func _unhandled_input(event):
	if event.is_action_released("move_up") or event.is_action_released("move_down"):
		_handle_floor_move(event)


func _toggle_facade():
	for i in range(floors.get_child_count()):
		var a_floor = floors.get_node("floor%s/floor" % [i+1])

		if _is_facade_visible:
			if i != current_floor_idx - 1:
				a_floor.set_transparent()
			else:
				a_floor.set_opaque()

			a_floor.hide_ceiling()
		else:
			a_floor.set_opaque()
			a_floor.show_ceiling()

	_is_facade_visible = !_is_facade_visible


func _on_tool_change_pressed(user_tool):
	_current_tool = user_tool


func _handle_floor_move(event):
	if _is_facade_visible:
		_toggle_facade()

	if event.is_action_released("move_up") and floors.get_child_count() >= current_floor_idx and (current_floor_idx < 1 or current_floor.get_piece_count() > 0):
		previous_floor = _get_current_floor()
		current_floor_idx += 1
		mouse_select.translate_object_local(Vector3(
			0, camera_gimbal.camera_y_diff_per_floor, 0
		))

		_post_floor_change()
	elif event.is_action_released("move_down") and (current_floor_idx == 1 or basement.get_child_count() >= abs(current_floor_idx) and current_floor_idx <= 0 and current_floor.get_piece_count() > 0 or current_floor_idx > 0):
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

	if previous_floor.is_connected("input_event", Callable(self, "_on_floor_input_event")):
		previous_floor.disconnect("input_event", Callable(self, "_on_floor_input_event"))

	if !current_floor.is_connected("input_event", Callable(self, "_on_floor_input_event")):
		var _c = current_floor.connect("input_event", Callable(self, "_on_floor_input_event"))

	previous_floor.input_ray_pickable = false
	current_floor.input_ray_pickable = true

	previous_floor.set_transparent()
	current_floor.set_opaque()

	current_level_ui.text = str(current_floor_idx)
	camera_gimbal.change_floor(current_floor_idx)


func _on_floor_input_event(_camera, event, target_pos, _normal, _shape_idx):
	target_pos.x = TowerGlobals.closest_multiple_of(int(target_pos.x))
	target_pos.z = TowerGlobals.closest_multiple_of(int(target_pos.z))

	if event is InputEventMouseMotion:
		_on_select_move(target_pos)

	if event is InputEventMouseButton:
		_on_button_click()


func _on_button_click():
	var target = mouse_select.global_transform.origin
	target.y = 0

	if _inputter.is_action_pressed("main_button") and _is_main_button_pressed == false:
		_main_button_press_target = target
		_is_main_button_pressed = true

		if _current_tool == TowerGlobals.UI_TOOL.BASE_TILE:
			current_floor.add_pieces_as_needed(target, _main_button_press_target, true)

	elif _inputter.is_action_just_released("main_button"):
		_is_main_button_pressed = false

		match _current_tool:
			TowerGlobals.UI_TOOL.SMALL_OFFICE_1x2, TowerGlobals.UI_TOOL.SMALL_OFFICE_2x2:
				current_floor.room_manager.place_hover_item()
			TowerGlobals.UI_TOOL.BASE_TILE:
				current_floor.remove_pieces_as_needed(target, _main_button_press_target, true)
				current_floor.add_pieces_as_needed(target, _main_button_press_target)
			TowerGlobals.UI_TOOL.REMOVE_TILE:
				current_floor.remove_pieces_as_needed(target, _main_button_press_target)


func _on_select_move(mouse_position: Vector3):
	mouse_position.y = mouse_select.global_transform.origin.y

	var adjustment = mouse_position - mouse_select.global_transform.origin

	adjustment.x = TowerGlobals.closest_multiple_of(int(adjustment.x))
	adjustment.z = TowerGlobals.closest_multiple_of(int(adjustment.z))

	if adjustment != Vector3.ZERO:
		mouse_select.translate_object_local(adjustment)
		debug_cursor_label.text = "x: %s z: %s" % [mouse_select.transform.origin.x, mouse_select.transform.origin.z]

		if _is_main_button_pressed:
			if _current_tool == TowerGlobals.UI_TOOL.BASE_TILE:
				current_floor.remove_pieces_as_needed(_pieces_added_at, _main_button_press_target, true)
				current_floor.add_pieces_as_needed(mouse_position, _main_button_press_target, true)
				_pieces_added_at = mouse_position


func _create_new_current_floor():
	var new_floor_container = Node3D.new()
	current_floor = floor_packed.instantiate()
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
	var _c = current_floor.connect(
		"input_event",
		Callable(
			self,
			"_on_floor_input_event"
		)
	)
	current_floor.input_ray_pickable = true

	current_floor.building = self


