extends GutTest

# TODO: This file feels split between integration / unit tests (or is just integration?) -- need to separate and distinguish in filename
class Test__on_floor_input_event:
	extends GutTest

	var test_building
	var input
	var timer

	func before_each():
		var prototype_script = load("res://scenes/building/building.tscn")
		test_building = prototype_script.instantiate()
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
			mouse_select.get_position(),
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
			current_floor.get_child(current_floor.get_child_count() - 1).get_position(),
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

		await get_tree().create_timer(0.015).timeout

		assert_gt(current_floor.get_child_count(), orig_children_count, "More children have been added")
		assert_eq(current_floor.get_child_count() - orig_children_count, 6, "Correct number of pieces have been assigned")

		current_floor = test_building.get_node("floors/floor1/floor")

		assert_not_null(current_floor.floor_data[2][0], "Piece set at right spot")
		assert_not_null(current_floor.floor_data[2][2], "Piece set at right spot")
		assert_not_null(current_floor.floor_data[2][4], "Piece set at right spot")
		assert_not_null(current_floor.floor_data[4][0], "Piece set at right spot")
		assert_not_null(current_floor.floor_data[4][2], "Piece set at right spot")
		assert_not_null(current_floor.floor_data[4][4], "Piece set at right spot")

	func test_mouse_click_and_drag_to_add_rectangle_adds_transparent_pieces():
		await get_tree().create_timer(0.015).timeout

		var current_floor = test_building.get_node("floors/floor1")
		var orig_children_count = current_floor.get_child_count()

		input._click_and_drag(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			),
			Vector3(
				4.076785, 0.100007, 4.179358
			)
		)

		await get_tree().create_timer(0.015).timeout

		assert_gt(current_floor.get_child_count(), orig_children_count, "More children have been added")
		assert_eq(current_floor.get_child_count() - orig_children_count, 6, "Correct number of pieces have been assigned")

		current_floor = test_building.get_node("floors/floor1/floor")

		assert_not_null(current_floor.floor_data[2][0], "Piece set at right spot")
		assert_true(current_floor.floor_data[2][0]["object"].is_transparent, "Piece set to transparent")
		assert_not_null(current_floor.floor_data[2][2], "Piece set at right spot")
		assert_true(current_floor.floor_data[2][2]["object"].is_transparent, "Piece set to transparent")
		assert_not_null(current_floor.floor_data[2][4], "Piece set at right spot")
		assert_true(current_floor.floor_data[2][4]["object"].is_transparent, "Piece set to transparent")
		assert_not_null(current_floor.floor_data[4][0], "Piece set at right spot")
		assert_true(current_floor.floor_data[4][0]["object"].is_transparent, "Piece set to transparent")
		assert_not_null(current_floor.floor_data[4][2], "Piece set at right spot")
		assert_true(current_floor.floor_data[4][2]["object"].is_transparent, "Piece set to transparent")
		assert_not_null(current_floor.floor_data[4][4], "Piece set at right spot")
		assert_true(current_floor.floor_data[4][4]["object"].is_transparent, "Piece set to transparent")

		input._release(
			test_building,
			Vector3(
				4.076785, 0.100007, 4.179358
			)
		)

		await get_tree().create_timer(0.02).timeout

		assert_not_null(current_floor.floor_data[2][0], "Piece set at right spot")
		assert_false(current_floor.floor_data[2][0]["object"].is_transparent, "Piece not set to transparent")
		assert_not_null(current_floor.floor_data[2][2], "Piece set at right spot")
		assert_false(current_floor.floor_data[2][2]["object"].is_transparent, "Piece not set to transparent")
		assert_not_null(current_floor.floor_data[2][4], "Piece set at right spot")
		assert_false(current_floor.floor_data[2][4]["object"].is_transparent, "Piece not set to transparent")
		assert_not_null(current_floor.floor_data[4][0], "Piece set at right spot")
		assert_false(current_floor.floor_data[4][0]["object"].is_transparent, "Piece not set to transparent")
		assert_not_null(current_floor.floor_data[4][2], "Piece set at right spot")
		assert_false(current_floor.floor_data[4][2]["object"].is_transparent, "Piece not set to transparent")
		assert_not_null(current_floor.floor_data[4][4], "Piece set at right spot")
		assert_false(current_floor.floor_data[4][4]["object"].is_transparent, "Piece not set to transparent")

		current_floor = test_building.get_node("floors/floor1")

		assert_gt(current_floor.get_child_count(), orig_children_count, "More children have been added")
		assert_eq(current_floor.get_child_count() - orig_children_count, 6, "Correct number of pieces have been assigned")


class Test__unhandled_input:
	extends GutTest

	var test_building
	var input

	func before_each():
		var prototype_script = load("res://scenes/building/building.tscn")
		test_building = prototype_script.instantiate()
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

		var initial_camera_y = test_building.find_child("camera_gimbal").get_position().y

		assert_eq(
			test_building.find_child("camera_gimbal").get_position().y,
			initial_camera_y,
			"Camera3D doesn't move until move_up input is released"
		)

		input.release("move_up")

		test_building._unhandled_input(input)

		gut.simulate(test_building, 200, 20)

		assert_gt(
			test_building.find_child("camera_gimbal").get_position().y,
			initial_camera_y,
			"Camera3D moves up upon input move_up release"
		)
		assert_eq(test_building.current_floor_idx, 2, "Current floor idx gets adjusted")
		assert_eq(test_building.find_child("current_level").text, "2", "Current level updated in UI")
		assert_eq(test_building.find_child("mouse_select").get_position().y, 1.0, "Mouse select icon elevated")


	func test_moves_down_a_floor():
		input.press("move_down")

		test_building._unhandled_input(input)

		gut.simulate(test_building, 2, 20)

		var initial_camera_y = test_building.find_child("camera_gimbal").get_position().y

		assert_eq(
			test_building.find_child("camera_gimbal").get_position().y,
			initial_camera_y,
			"Camera3D doesn't move until move_down input is released"
		)

		input.release("move_down")

		test_building._unhandled_input(input)

		gut.simulate(test_building, 200, 20)

		assert_lt(
			test_building.find_child("camera_gimbal").get_position().y,
			initial_camera_y,
			"Camera3D moves down upon input move_down release"
		)
		assert_eq(test_building.current_floor_idx, 0, "Current floor idx gets adjusted")
		assert_eq(test_building.find_child("current_level").text, "0", "Current level updated in UI")
		assert_eq(test_building.find_child("mouse_select").get_position().y, -1.0, "Mouse select icon de-elevated")


	func test_cannot_move_up_more_than_one_floor():
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			)
		)

		assert_eq(test_building.current_floor_idx, 1, "Current floor idx correct")

		# move up once...
		input.press("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 200, 20)

		input._reset()
		assert_eq(test_building.current_floor_idx, 2, "Current floor idx goes up one above what exists")

		# move up twice...
		input.press("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 200, 20)

		assert_eq(test_building.current_floor_idx, 2, "Current floor idx does not go up more than one floor above what exists")


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


	func test_can_leave_basement_without_making_piece():
		# move down once...
		input.press("move_down")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_down")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 200, 20)

		assert_eq(test_building.current_floor_idx, 0, "Current floor idx goes down one below what exists")

		# move back up...
		input.press("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 200, 20)

		assert_eq(test_building.current_floor_idx, 1, "Current floor idx returns to first floor")


class Test__toggle_facade:
	extends GutTest

	var test_building
	var input

	func before_each():
		var prototype_script = load("res://scenes/building/building.tscn")
		test_building = prototype_script.instantiate()
		input = MockInput.new()
		test_building._set_input(input)

		add_child_autofree(test_building)


	func test_toggles_facade_via_method():
		input._click_and_drag_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			),
			Vector3(
				4.076785, 0.100007, 4.179358
			)
		)

		await get_tree().create_timer(0.015).timeout

		input.release("move_up")
		test_building._unhandled_input(input)

		await get_tree().create_timer(0.015).timeout

		input._click_and_drag_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			),
			Vector3(
				4.076785, 0.100007, 4.179358
			)
		)

		await get_tree().create_timer(0.015).timeout

		var first_floor = test_building.get_node("floors/floor1")
		var first_floor_piece = first_floor.get_child(first_floor.get_child_count() - 1)

		assert_eq(test_building.get_node("floors").get_child_count(), 2)

		assert_true(first_floor_piece.is_transparent, "First floor piece is transparent before toggle")

		test_building._toggle_facade()

		assert_false(first_floor_piece.is_transparent, "First floor piece isn't transparent after toggle")


	func test_toggles_facade_adds_ceiling_to_top_floor():
		input._click_and_drag_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			),
			Vector3(
				4.076785, 0.100007, 4.179358
			)
		)

		await get_tree().create_timer(0.015).timeout

		input.release("move_up")
		test_building._unhandled_input(input)

		await get_tree().create_timer(0.015).timeout

		input._click_and_drag_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			),
			Vector3(
				4.076785, 0.100007, 4.179358
			)
		)

		await get_tree().create_timer(0.015).timeout

		test_building._toggle_facade()

		var first_floor = test_building.get_node("floors/floor1")
		var first_piece = first_floor.get_child(first_floor.get_child_count() - 1)
		var second_floor = test_building.get_node("floors/floor2")
		var second_piece = second_floor.get_child(second_floor.get_child_count() - 1)

		assert_true(first_piece.ceiling.is_visible(), "First floor piece's ceiling is visible after toggle")
		assert_true(second_piece.ceiling.is_visible(), "Second floor piece's ceiling is visible after toggle")

		test_building._toggle_facade()

		assert_false(first_piece.ceiling.is_visible(), "First floor piece's ceiling is invisible after toggle")
		assert_false(second_piece.ceiling.is_visible(), "Second floor piece's ceiling is invisible after toggle")


	func test_toggles_facade_adds_ceiling_to_top_floor_only_if_pieces_exist():
		input._click_and_drag_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			),
			Vector3(
				4.076785, 0.100007, 4.179358
			)
		)

		await get_tree().create_timer(0.015).timeout

		input.release("move_up")
		test_building._unhandled_input(input)

		await get_tree().create_timer(0.015).timeout

		test_building._toggle_facade()

		var second_floor = test_building.get_node("floors/floor2")
		var first_floor = test_building.get_node("floors/floor1")
		var piece = first_floor.get_child(first_floor.get_child_count() - 1)

		assert_eq(second_floor.get_child_count(), 1, "No new pieces created on second floor")
		assert_true(piece.ceiling.is_visible(), "First floor piece has ceiling after move up")


class Test_SecondFloorWorkflow:
	extends GutTest

	var test_building
	var input

	func before_each():
		var prototype_script = load("res://scenes/building/building.tscn")
		test_building = prototype_script.instantiate()
		TowerGlobals.current_building = test_building
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
			current_floor.get_child(current_floor.get_child_count() - 1).get_position(),
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
			current_floor.get_child(current_floor.get_child_count() - 1).get_position(),
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
			current_floor.get_child(current_floor.get_child_count() - 1).get_position(),
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

		TowerGlobals.emit_signal("tool_change", TowerGlobals.UI_TOOL.REMOVE_TILE)

		# fourth, remove that piece on the second floor
		input._click_and_release(
			test_building,
			Vector3(
				2.076785, 0.100007, 0.179358
			)
		)

		# fifth, try to go up to third floor -- shouldn't be able to
		input.press("move_up")
		input.release("move_up")
		test_building._unhandled_input(input)

		assert_ne(
			test_building.current_floor_idx, 3,
			"Not allowed to go up to third floor w/ no pieces on second"
		)


class Test_AddRoomWorkflow:
	extends GutTest

	var test_building
	var input
	var room_manager

	func before_each():
		var prototype_script = load("res://scenes/building/building.tscn")

		test_building = prototype_script.instantiate()
		input = MockInput.new()
		test_building._set_input(input)
		add_child_autofree(test_building)
		TowerGlobals.current_building = test_building

		input._click_and_drag_and_release(
			test_building,
			Vector3(
				0.076785, 0.100007, 0.179358
			),
			Vector3(
				2.076785, 0.100007, 4.179358
			)
		)
		gut.simulate(test_building, 2, 2)

		room_manager = test_building.get_node("floors/floor1/floor/room_manager")

		# NOTE: Below simulates mouse position around area of UI buttons
		input._move(
			test_building,
			Vector3(-99, 0, -88)
		)

		TowerGlobals.tool_change.emit(TowerGlobals.UI_TOOL.SMALL_OFFICE_1x2)

		gut.simulate(test_building, 2, 2)


	func after_each():
		TowerGlobals.current_building = null

		if room_manager._hover_item != null:
			room_manager._hover_item.free()

		test_building.free()


	func test_hover_item_hides_when_in_inappropriate_spot():
		input._move(
			test_building,
			Vector3(3, 0, 3)
		)
		gut.simulate(test_building, 2, 2)

		assert_false(room_manager._hover_item.is_visible())


	func test_hover_item_appears_when_in_appropriate_spot():
		input._move(
			test_building,
			Vector3.ZERO
		)
		gut.simulate(test_building, 2, 2)

		assert_true(room_manager._hover_item.is_visible())


	func test_hover_item_hides_and_reappears_when_moved_back_to_appropriate_spot():
		input._move(
			test_building,
			Vector3(3, 0, 3)
		)
		gut.simulate(test_building, 2, 2)

		assert_false(room_manager._hover_item.is_visible())

		input._move(
			test_building,
			Vector3(1, 0, 1)
		)
		gut.simulate(test_building, 2, 2)

		assert_true(room_manager._hover_item.is_visible())


	func test_hover_item_hides_when_placed_over_existing_room():
		input._move(
			test_building,
			Vector3(1, 0, 2.2)
		)
		gut.simulate(test_building, 2, 2)

		room_manager.place_hover_item()

		input._move(
			test_building,
			Vector3(-99, 0, -88)
		)
		TowerGlobals.tool_change.emit(TowerGlobals.UI_TOOL.SMALL_OFFICE_1x2)
		gut.simulate(test_building, 2, 2)

		input._move(
			test_building,
			Vector3(1, 0, 2.2)
		)
		gut.simulate(test_building, 2, 2)

		assert_false(room_manager._hover_item.is_visible(), "Hover item hides when placed over existing room")


	func test_can_add_corner_shaped_room():
		TowerGlobals.tool_change.emit(TowerGlobals.UI_TOOL.SMALL_OFFICE_CORNER)
		gut.simulate(test_building, 2, 2)

		input._move(
			test_building,
			Vector3.ZERO
		)
		gut.simulate(test_building, 2, 2)

		input.input_method = "_on_button_click"

		input._click_and_release(
			test_building,
			Vector3.ZERO
		)
		gut.simulate(test_building, 2, 2)

		input._reset()

		var office_corner_piece = test_building.get_node("floors/floor1/office_corner/tiles/bottomFloorPiece")

		assert_false(office_corner_piece.is_transparent)
		assert_null(room_manager._hover_item)


	func test_can_add_room_to_second_floor_without_creating_hover_item_on_first_floor():
		TowerGlobals.tool_change.emit(TowerGlobals.UI_TOOL.BASE_TILE)

		input.press("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input._reset()

		input._click_and_drag_and_release(
			test_building,
			Vector3(
				0.076785, 0.100007, 0.179358
			),
			Vector3(
				2.076785, 0.100007, 4.179358
			)
		)
		gut.simulate(test_building, 20, 200)

		var room_manager_2 = test_building.get_node_or_null("floors/floor2/floor/room_manager")

		assert_not_null(room_manager_2, "Second floor room manager null when it should exist")

		TowerGlobals.tool_change.emit(TowerGlobals.UI_TOOL.SMALL_OFFICE_1x2)
		gut.simulate(test_building, 2, 2)

		input._move(
			test_building,
			Vector3.ZERO
		)
		gut.simulate(test_building, 2, 2)

		input.input_method = "_on_button_click"

		input._click_and_release(
			test_building,
			Vector3.ZERO
		)
		gut.simulate(test_building, 2, 2)

		input._reset()

		assert_null(room_manager_2._hover_item, "Second floor still has hover item when it shouldn't")

		input.press("move_down")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_down")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input._reset()

		assert_null(room_manager._hover_item, "First floor still has hover item when it shouldn't have in the first place")


	func test_can_move_hover_items_between_floors():
		TowerGlobals.tool_change.emit(TowerGlobals.UI_TOOL.BASE_TILE)

		input.press("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 2)
		input.release("move_up")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 2)
		input._reset()

		input._click_and_drag_and_release(
			test_building,
			Vector3(
				0.076785, 0.100007, 0.179358
			),
			Vector3(
				2.076785, 0.100007, 4.179358
			)
		)
		gut.simulate(test_building, 20, 200)

		var room_manager_2 = test_building.get_node_or_null("floors/floor2/floor/room_manager")

		assert_not_null(room_manager_2, "Second floor room manager null when it should exist")

		TowerGlobals.tool_change.emit(TowerGlobals.UI_TOOL.SMALL_OFFICE_1x2)
		gut.simulate(test_building, 2, 2)

		input.press("move_down")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input.release("move_down")
		test_building._unhandled_input(input)
		gut.simulate(test_building, 2, 20)
		input._reset()

		assert_not_null(room_manager._hover_item, "First floor doesn't have hover item when it should")

		assert_null(room_manager_2._hover_item, "Second floor still has hover item when it shouldn't")


