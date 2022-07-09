var _pressed = []
var _released = []

var input_method = "_on_floor_input_event"

func press(key):
	_pressed.append(key)

	if key in _released:
		_released.remove(key)

func release(key):
	if key in _pressed:
		_pressed.remove(key)

	_released.append(key)

func is_action_pressed(a):
	return a in _pressed

func is_action_released(a):
	return a in _released

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
		_test_mouse_input_event(
			node,
			InputEventMouseMotion.new(),
			start
		)

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


func _click_and_drag(node, start, finish, move_in_place=true, button="main_button"):
	_click(node, start, move_in_place, button)

	_test_mouse_input_event(
		node,
		InputEventMouseMotion.new(),
		finish
	)


func _click_and_drag_and_release(node, start, finish, move_in_place=true, button="main_button"):
	_click_and_drag(node, start, finish, move_in_place, button)
	_release(node, finish, button)
