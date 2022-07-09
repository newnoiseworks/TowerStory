extends Spatial

onready var floor_packed = preload("res://scenes/floor/floor.tscn")

onready var mouse_select: Spatial = find_node("mouse_select")
onready var camera_gimbal: Spatial = find_node("camera_gimbal")
onready var current_level_ui: Label = find_node("current_level")
onready var floors: Spatial = find_node("floors")
onready var basement: Spatial = find_node("basement")

var _inputter = Input
var _main_button_press_target: Vector3
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
	if event.is_action_released("move_up") and floors.get_child_count() >= current_floor_idx and (current_floor == null or current_floor._get_piece_count() > 0):
		previous_floor = _get_current_floor()
		current_floor_idx += 1
		mouse_select.translate_object_local(Vector3(
			0, camera_gimbal.camera_y_diff_per_floor, 0
		))

		_post_floor_change()
	elif event.is_action_released("move_down") and (current_floor_idx == 1 or basement.get_child_count() >= abs(current_floor_idx)) and current_floor_idx <= 0 and current_floor._get_piece_count() > 0 or current_floor_idx > 0:
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
	if event is InputEventMouseMotion:
		_on_select_move(position)

	if event is InputEventMouseButton:
		_on_button_click()


func _on_button_click():
	var target = mouse_select.global_transform.origin
	target.y = 0

	if _inputter.is_action_pressed("main_button") and _is_main_button_pressed == false:
		_is_main_button_pressed = true
		_main_button_press_target = target
	elif _inputter.is_action_just_released("main_button"):
		_add_pieces_as_needed(target)
		_is_main_button_pressed = false
	elif _inputter.is_action_just_released("secondary_button"):
		current_floor.remove_floor_piece_at(target)


func _on_select_move(mouse_position: Vector3):
	mouse_position.y = mouse_select.global_transform.origin.y

	var adjustment = mouse_position - mouse_select.global_transform.origin

	adjustment.x = _closest_multiple_of(int(adjustment.x))
	adjustment.z = _closest_multiple_of(int(adjustment.z))

	if adjustment != Vector3.ZERO:
		mouse_select.translate_object_local(adjustment)


# TODO: This code should most likely be pushed into floor.gd
func _add_pieces_as_needed(target, final_target = null):
	if final_target == null: final_target  = _main_button_press_target # for tests

	if (current_floor_idx > 1 and current_floor._get_piece_count() == 0):
		var floor_under = get_node("floors/floor%s/floor" % [current_floor_idx - 1])
		if (!floor_under.has_floor_piece_at(final_target)):
			return

	if target == final_target:
		current_floor.add_floor_piece_at(target)
		return

	var greaterx = final_target if final_target.x > target.x else target
	var lesserx = target if greaterx == final_target else final_target
	var greaterz = final_target if final_target.z > target.z else target
	var lesserz = target if greaterz == final_target else final_target

	_add_multiple_pieces_if_adjacent(lesserx, greaterx, lesserz, greaterz)


func _add_multiple_pieces_if_adjacent(lesserx, greaterx, lesserz, greaterz):
	var has_adjacent_piece = false

	for x in range(lesserx.x, greaterx.x + TowerGlobals.TILE_MULTIPLE, TowerGlobals.TILE_MULTIPLE):
		for z in range(lesserz.z, greaterz.z + TowerGlobals.TILE_MULTIPLE, TowerGlobals.TILE_MULTIPLE):
			if current_floor._can_add_floor_piece_at(x, z):
				has_adjacent_piece = true
				break

		if has_adjacent_piece: break

	if !has_adjacent_piece: return

	for x in range(lesserx.x, greaterx.x + TowerGlobals.TILE_MULTIPLE, TowerGlobals.TILE_MULTIPLE):
		for z in range(lesserz.z, greaterz.z + TowerGlobals.TILE_MULTIPLE, TowerGlobals.TILE_MULTIPLE):
			if !current_floor._has_floor_piece_at(x, z):
				current_floor.add_floor_piece_at(Vector3(x, 0, z), true)

	for x in range(lesserx.x, greaterx.x + TowerGlobals.TILE_MULTIPLE, TowerGlobals.TILE_MULTIPLE):
		for z in range(lesserz.z, greaterz.z + TowerGlobals.TILE_MULTIPLE, TowerGlobals.TILE_MULTIPLE):
			current_floor._add_wall_to_piece_at_edges(x, z)
			current_floor._add_edges_to_surrounding_pieces(x, z)


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
