extends GutTest


class Test__on_floor_input_event:
	extends GutTest
	var test_building
	var input

	class MockInput:
		var _pressed = []

		func press(key):
			_pressed.append(key)

		func release(key):
			_pressed.remove(key)

		func is_action_pressed(a):
			return a in _pressed

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

		test_building._on_floor_input_event(
			null,
			InputEventMouseButton.new(),
			Vector3(
				2.076785, 0.100007, 0.179358
			),
			null,
			null
		)

		input.press("main_button")

		var mouse_select = test_building.mouse_select

		assert_eq(
			mouse_select.get_translation(),
			Vector3(2, 0, 0),
			"Moving the mouse moves the mouse select object"
		)
