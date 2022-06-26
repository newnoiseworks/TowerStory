extends GutTest

# TODO: This file feels split between integration / unit tests (or is just integration) -- need to separate and distinguish in filename

# TODO: Make this globally accessible to the test suite somehow
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

	func is_action_just_released(a):
		return is_action_released(a)


	func _test_mouse_input_event(test_building, input_type, position):
		test_building._on_floor_input_event(
			null,
			input_type,
			position,
			null,
			null
		)



class Test__on_floor_input_event:
	extends GutTest

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

		input.release("main_button")

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


	func test_mouse_click_and_drag_to_add_rectangle():
		var current_floor = test_building.get_node("floors/floor1")
		var orig_children_count = current_floor.get_child_count()

		input._test_mouse_input_event(
			test_building,
			InputEventMouseMotion.new(),
			Vector3(
				2.076785, 0.100007, 0.179358
			)
		)

		input.press("main_button")

		input._test_mouse_input_event(
			test_building,
			InputEventMouseButton.new(),
			Vector3(
				2.076785, 0.100007, 0.179358
			)
		)

		gut.simulate(test_building, 2, 2)

		input._test_mouse_input_event(
			test_building,
			InputEventMouseMotion.new(),
			Vector3(
				4.076785, 0.100007, 4.179358
			)
		)

		input.release("main_button")

		input._test_mouse_input_event(
			test_building,
			InputEventMouseButton.new(),
			Vector3(
				4.076785, 0.100007, 4.179358
			)
		)

		gut.simulate(test_building, 2, 2)

		assert_gt(current_floor.get_child_count(), orig_children_count, "More children have been added")
		assert_eq(current_floor.get_child_count() - orig_children_count, 6, "Correct number of pieces have been assigned")

		current_floor = current_floor.find_node("floor")

		assert_not_null(current_floor.floor_data[2][0], "Piece set at right spot")
		assert_not_null(current_floor.floor_data[2][2], "Piece set at right spot")
		assert_not_null(current_floor.floor_data[2][4], "Piece set at right spot")
		assert_not_null(current_floor.floor_data[4][0], "Piece set at right spot")
		assert_not_null(current_floor.floor_data[4][2], "Piece set at right spot")
		assert_not_null(current_floor.floor_data[4][4], "Piece set at right spot")






class Test__unhandled_input:
	extends GutTest

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


class Test_SecondFloorWorkflow:
	extends GutTest

	var test_building
	var input

	func before_each():
		var prototype_script = load("res://scenes/building/building.tscn")
		test_building = prototype_script.instance()
		input = MockInput.new()
		test_building._set_input(input)
		add_child_autofree(test_building)

	func test_add_piece_where_one_exists():
		# first, make a piece on the first floor
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
		input.release("main_button")
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

		# second, move up a floor
		input.press("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 200, 20)

		# third, make a piece above the first - should be ok
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
		input.release("main_button")
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

		var current_floor = test_building.get_node_or_null("floors/floor2")

		assert_not_null(
			current_floor,
			"Second floor is created and added to the tree"
		)

		assert_eq(
			current_floor.get_child(current_floor.get_child_count() - 1).get_translation(),
			Vector3(2, 0, 0),
			"Moving and clicking the mouse adds a piece to the right area"
		)


	func test_cannot_add_piece_where_none_exists_on_first_floor_if_first_piece_on_second_floor():
		# first, make a piece on the first floor
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
		input.release("main_button")
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

		# second, move up a floor
		input.press("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 200, 20)

		# third, make a piece not above the first - should not be ok
		test_building._on_floor_input_event(
			null,
			InputEventMouseMotion.new(),
			Vector3(
				2.076785, 0.100007, 2.179358
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
				2.076785, 0.100007, 2.179358
			),
			null,
			null
		)
		input.release("main_button")
		test_building._on_floor_input_event(
			null,
			InputEventMouseButton.new(),
			Vector3(
				2.076785, 0.100007, 2.179358
			),
			null,
			null
		)
		gut.simulate(test_building, 2, 2)

		var current_floor = test_building.get_node_or_null("floors/floor2")

		assert_not_null(
			current_floor,
			"Second floor is created and added to the tree"
		)

		assert_ne(
			current_floor.get_child(current_floor.get_child_count() - 1).get_translation(),
			Vector3(2, 0, 2),
			"Cannot add a piece if floor underneath doesnt have one and this is the first piece being added"
		)


	func test_can_add_piece_where_none_exists_on_first_floor_if_contiguous_with_second_floor():
		# first, make a piece on the first floor
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
		input.release("main_button")
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

		# second, move up a floor
		input.press("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 200, 20)

		# third, make a piece above the first - should be ok
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
		input.release("main_button")
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

		# fourth, make a piece not above the first - should be ok
		test_building._on_floor_input_event(
			null,
			InputEventMouseMotion.new(),
			Vector3(
				2.076785, 0.100007, 2.179358
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
				2.076785, 0.100007, 2.179358
			),
			null,
			null
		)
		input.release("main_button")
		test_building._on_floor_input_event(
			null,
			InputEventMouseButton.new(),
			Vector3(
				2.076785, 0.100007, 2.179358
			),
			null,
			null
		)
		gut.simulate(test_building, 2, 2)

		var current_floor = test_building.get_node_or_null("floors/floor2")

		assert_not_null(
			current_floor,
			"Second floor is created and added to the tree"
		)

		assert_eq(
			current_floor.get_child(current_floor.get_child_count() - 1).get_translation(),
			Vector3(2, 0, 2),
			"Can add a piece if floor underneath doesnt have one and this is not the first piece being added to the second floor"
		)


# TODO: Move below into floor.gd
class Test__add_pieces_as_needed:
	extends GutTest

	var test_building
	var input

	func before_each():
		var prototype_script = load("res://scenes/building/building.tscn")
		test_building = prototype_script.instance()
		input = MockInput.new()
		test_building._set_input(input)
		add_child_autofree(test_building)


	func test_cant_add_non_contiguous_group_to_existing_group():
		# First, make a block in the center
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

		input.release("main_button")

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

		# Second, attempt to make 2x2 block off center -- shouldn't allow
		var current_floor = test_building.get_node("floors/floor1")
		var orig_children_count = current_floor.get_child_count()

		input._test_mouse_input_event(
			test_building,
			InputEventMouseMotion.new(),
			Vector3(
				12.076785, 0.100007, 0.179358
			)
		)

		input.press("main_button")

		input._test_mouse_input_event(
			test_building,
			InputEventMouseButton.new(),
			Vector3(
				12.076785, 0.100007, 0.179358
			)
		)

		gut.simulate(test_building, 2, 2)

		input._test_mouse_input_event(
			test_building,
			InputEventMouseMotion.new(),
			Vector3(
				14.076785, 0.100007, 4.179358
			)
		)

		input.release("main_button")

		input._test_mouse_input_event(
			test_building,
			InputEventMouseButton.new(),
			Vector3(
				14.076785, 0.100007, 4.179358
			)
		)

		gut.simulate(test_building, 2, 2)

		assert_eq(current_floor.get_child_count(), orig_children_count, "No extra children have been added when not contiguous")
