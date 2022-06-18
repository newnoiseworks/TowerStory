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

		var current_floor = test_building.get_node("floors/floor1")

		assert_eq(
			current_floor.get_child(current_floor.get_child_count() - 1).get_translation(),
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

	var test_building
	var input


	func before_each():
		var prototype_script = load("res://scenes/building/building.tscn")
		test_building = prototype_script.instance()
		input = MockInput.new()
		test_building._set_input(input)
		add_child_autofree(test_building)
		test_building.queue_free()


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
		assert_eq(test_building.find_node("current_level").text, "2", "Current level updated in UI")
		assert_eq(test_building.find_node("mouse_select").get_translation().y, 1.0, "Mouse select icon elevated")


	func test_moves_down_a_floor():
		input.press("move_down")

		test_building._unhandled_input(input)

		gut.simulate(test_building, 2, 20)

		var initial_camera_y = test_building.find_node("camera_gimbal").get_translation().y

		assert_eq(
			test_building.find_node("camera_gimbal").get_translation().y,
			initial_camera_y,
			"Camera doesn't move until move_down input is released"
		)

		input.release("move_down")

		test_building._unhandled_input(input)

		gut.simulate(test_building, 200, 20)

		assert_lt(
			test_building.find_node("camera_gimbal").get_translation().y,
			initial_camera_y,
			"Camera moves down upon input move_down release"
		)
		assert_eq(test_building.current_floor_idx, 0, "Current floor idx gets adjusted")
		assert_eq(test_building.find_node("current_level").text, "0", "Current level updated in UI")
		assert_eq(test_building.find_node("mouse_select").get_translation().y, -1.0, "Mouse select icon de-elevated")


	func test_cannot_move_up_more_than_one_floor():
		# move up once...
		input.press("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 200, 20)

		assert_eq(test_building.current_floor_idx, 2, "Current floor idx goes up one above what exists")

		# move up twice...
		input.press("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 200, 20)

		assert_eq(test_building.current_floor_idx, 2, "Current floor idx does not go down more than one floor above what exists")


	func test_cannot_move_down_more_than_one_floor():
		# move down once...
		input.press("move_down")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_down")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 200, 20)

		assert_eq(test_building.current_floor_idx, 0, "Current floor idx goes down one below what exists")

		# move down twice...
		input.press("move_down")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_down")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 200, 20)

		assert_eq(test_building.current_floor_idx, 0, "Current floor idx does not go down more than one floor below what exists")
