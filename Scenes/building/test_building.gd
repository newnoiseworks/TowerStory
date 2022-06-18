extends GutTest

class Test__on_floor_input_event:
	extends GutTest

	class MockInput:
		var _pressed = []

		func press(key):
			_pressed.append(key)

		func release(key):
			_pressed.remove(key)

		func is_action_pressed(a):
			return a in _pressed


	var test_building
	var input

	func before_each():
		var prototype_script = load("res://scenes/building/building.tscn")
		test_building = prototype_script.instance()
		input = MockInput.new()
		test_building._set_input(input)
		add_child_autofree(test_building)


	func test_mouse_move():
		test_building._on_floor_input_event(
			null,
			InputEventMouseMotion.new(),
			Vector3(
				2.076785, 0.100007, 0.179358
			),
			null,
			null
		)

		var mouse_select = test_building.mouse_select

		assert_eq(
			mouse_select.get_translation(),
			Vector3(2, 0, 0),
			"Moving the mouse moves the mouse select object"
		)

	func test_mouse_add_piece():
		test_building._on_floor_input_event(
			null,
			InputEventMouseMotion.new(),
			Vector3(
				2.076785, 0.100007, 0.179358
			),
			null,
			null
		)

		gut.simulate(test_building, 2, 2)

		input.press("main_button")

		test_building._on_floor_input_event(
			null,
			InputEventMouseButton.new(),
			Vector3(
				2.076785, 0.100007, 0.179358
			),
			null,
			null
		)

		gut.simulate(test_building, 2, 2)

		assert_eq(
			test_building.get_child(test_building.get_child_count() - 1).get_translation(),
			Vector3(2, 0, 0),
			"Moving and clicking the mouse adds a piece to the right area"
		)


class Test__unhandled_input:
	extends GutTest

	class MockInput:
		var _pressed = []
		var _released = []

		func press(key):
			_pressed.append(key)

		func release(key):
			_pressed.remove(key)
			_released.append(key)

		func is_action_pressed(a):
			return a in _pressed

		func is_action_released(a):
			return a in _released

	var test_building
	var input


	func before_each():
		var prototype_script = load("res://scenes/building/building.tscn")
		test_building = prototype_script.instance()
		input = MockInput.new()
		test_building._set_input(input)
		add_child_autofree(test_building)


	func test_moves_up_a_floor():
		input.press("move_up")

		test_building._unhandled_input(input)

		gut.simulate(test_building, 2, 20)

		var initial_camera_y = test_building.find_node("camera_gimbal").get_translation().y

		assert_eq(
			test_building.find_node("camera_gimbal").get_translation().y,
			initial_camera_y,
			"Camera doesn't move until move_up input is released"
		)

		input.release("move_up")

		test_building._unhandled_input(input)

		gut.simulate(test_building, 200, 20)

		assert_gt(
			test_building.find_node("camera_gimbal").get_translation().y,
			initial_camera_y,
			"Camera moves up upon input move_up release"
		)
		
		assert_eq(test_building.current_floor_idx, 2, "Current floor idx gets adjusted")


