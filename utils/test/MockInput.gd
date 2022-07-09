class_name MockInput

var _pressed = []
var _released = []

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


func _test_mouse_input_event(test_building, input_type, position):
	test_building._on_floor_input_event(
		null,
		input_type,
		position,
		null,
		null
	)


func _click_and_drag(test_building, start, finish):
	_test_mouse_input_event(
		test_building,
		InputEventMouseMotion.new(),
		start
	)

	press("main_button")

	_test_mouse_input_event(
		test_building,
		InputEventMouseButton.new(),
		start
	)

	_test_mouse_input_event(
		test_building,
		InputEventMouseMotion.new(),
		finish
	)

	release("main_button")

	_test_mouse_input_event(
		test_building,
		InputEventMouseButton.new(),
		finish
	)
