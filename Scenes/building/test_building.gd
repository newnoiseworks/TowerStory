extends GutTest

const MockInput = preload("res://utils/test/MockInput.gd")

# TODO: This file feels split between integration / unit tests (or is just integration?) -- need to separate and distinguish in filename
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
		input._test_mouse_input_event(
			test_building,
			InputEventMouseMotion.new(),
			Vector3(
				2.076785, 0.100007, 0.179358
			)
		)

		var mouse_select = test_building.mouse_select

		assert_eq(
			mouse_select.get_translation(),
			Vector3(2, 0, 0),
			"Moving the mouse moves the mouse select object"
		)

	func test_mouse_add_piece():
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			)
		)

		var current_floor = test_building.get_node("floors/floor1")

		assert_eq(
			current_floor.get_child(current_floor.get_child_count() - 1).get_translation(),
			Vector3(2, 0, 0),
			"Moving and clicking the mouse adds a piece to the right area"
		)


	func test_mouse_click_and_drag_to_add_rectangle():
		var current_floor = test_building.get_node("floors/floor1")
		var orig_children_count = current_floor.get_child_count()

		input._click_and_drag_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			),
			Vector3(
				4.076785, 0.100007, 4.179358
			)
		)

		assert_gt(current_floor.get_child_count(), orig_children_count, "More children have been added")
		assert_eq(current_floor.get_child_count() - orig_children_count, 6, "Correct number of pieces have been assigned")

		current_floor = test_building.get_node("floors/floor1/floor")

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
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			)
		)

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
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			)
		)

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
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			)
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
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			)
		)

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
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			)
		)

		# second, move up a floor
		input.press("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 200, 20)

		# third, make a piece not above the first - should not be ok
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 2.179358
			)
		)

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
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			)
		)

		# second, move up a floor
		input.press("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 200, 20)

		# third, make a piece above the first - should be ok
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			)
		)

		# fourth, make a piece not above the first - should be ok
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 2.179358
			)
		)

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


	func test_cannot_move_to_third_floor_without_piece_on_second_floor():
		# first, make a piece on the first floor
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			)
		)

		# second, move up a floor
		input.press("move_up")
		input.release("move_up")
		test_building._unhandled_input(input)

		# third, make a piece above the first - should be ok
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			)
		)

		input._reset()

		# fourth, remove that piece on the second floor
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			),
			true,
			"secondary_button"
		)

		# fifth, try to go up to third floor -- shouldn't be able to
		input.press("move_up")
		input.release("move_up")
		test_building._unhandled_input(input)

		assert_ne(
			test_building.current_floor_idx, 3,
			"Not allowed to go up to third floor w/ no pieces on second"
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
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			)
		)

		# Second, attempt to make 2x2 block off center -- shouldn't allow
		var current_floor = test_building.get_node("floors/floor1")
		var orig_children_count = current_floor.get_child_count()

		input._click_and_drag_and_release(
			test_building,
			Vector3(
				12.076785, 0.100007, 0.179358
			),
			Vector3(
				14.076785, 0.100007, 4.179358
			)
		)

		assert_eq(current_floor.get_child_count(), orig_children_count, "No extra children have been added when not contiguous")


class Test__add_multiple_pieces_if_adjacent:
	extends GutTest

	var test_building
	var input

	func before_each():
		var prototype_script = load("res://scenes/building/building.tscn")
		test_building = prototype_script.instance()
		input = MockInput.new()
		test_building._set_input(input)
		add_child_autofree(test_building)


	func test__can_add_overlapping_pieces():
		var current_floor = test_building.get_node("floors/floor1/floor")

		input._click_and_drag_and_release(
			test_building,
			Vector3(
				0.076785, 0.100007, 0.179358
			),
			Vector3(
				0.076785, 0.100007, 0.179358
			)
		)

		gut.simulate(test_building, 5, 15)

		input._click_and_drag_and_release(
			test_building,
			Vector3(
				-18.076785, 0.100007, -18.179358
			),
			Vector3(
				18.076785, 0.100007, 18.179358
			)
		)

		gut.simulate(test_building, 5, 15)

		var first_piece = current_floor.floor_data[0][0]["object"]
		var first_node = test_building.get_node("floors/floor1/bottomFloorPiece")

		assert_eq(first_piece, first_node, "First piece is correctly set, no double creation of pieces")

		assert_eq(first_piece.find_node("wall1").is_visible(), false, "Walls turned off in appropriate area of overlapping pieces")
		assert_eq(first_piece.find_node("wall3").is_visible(), false, "Walls turned off in appropriate area of overlapping pieces")
