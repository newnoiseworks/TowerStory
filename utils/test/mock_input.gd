class_name MockInput

var _pressed = []
var _released = []

var input_method = "_on_floor_input_event"

func press(key):
	_pressed.append(key)

	if _released.has(key):
		_released.erase(key)


func release(key):
	if _pressed.has(key):
		_pressed.erase(key)

	_released.append(key)


func is_action_pressed(a):
	return _pressed.has(a)


func is_action_released(a):
	return _released.has(a)


func is_action_just_released(a):
	return is_action_released(a)


func _reset():
	_pressed = []
	_released = []


func _test_mouse_input_event(node: Node, input_type, position):
	var args

	if input_method == "_on_floor_input_event": # presumably from building.gd
		args = [null, input_type, position, null, null]

	node.callv(input_method, args)


func _click(node, start, move_in_place=true, button="main_button"):
	if move_in_place:
		_move(node, start)

	press(button)

	_test_mouse_input_event(
		node,
		InputEventMouseButton.new(),
		start
	)

	
func _release(node, finish, button="main_button"):
	release(button)

	_test_mouse_input_event(
		node,
		InputEventMouseButton.new(),
		finish
	)


func _click_and_release(node, start, move_in_place=true, button="main_button"):
	_click(node, start, move_in_place, button)
	_release(node, start, button)


func _move(node, position):
	_test_mouse_input_event(
		node,
		InputEventMouseMotion.new(),
		position
	)


func _click_and_drag(node, start, finish, move_in_place=true, button="main_button"):
	_click(node, start, move_in_place, button)
	_move(node, finish)


func _click_and_drag_and_release(node, start, finish, move_in_place=true, button="main_button"):
	_click_and_drag(node, start, finish, move_in_place, button)
	_release(node, finish, button)
