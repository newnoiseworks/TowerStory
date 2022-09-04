extends GutTest

var SpecHelper = preload("res://utils/test/spec_helper.gd")

class Test_is_floor_contiguous:
	extends GutTest
	var double_script

	func before_each():
		var prototype_script = load("res://utils/floor_data_details.gd")
		double_script = prototype_script.new({})


	func test_simple_is_contiguous():
		var data = {
			0: {
				0: {
					"type": "floor",
				},
			}
		}

		data[0][1 * TowerGlobals.TILE_MULTIPLE] = {
			"type": "floor",
		}

		assert_true(
			double_script.is_floor_contiguous(data),
			"Simple row reads as contiguous"
		)


class Test__get_piece_edges:
	extends GutTest
	var double_script

	func before_each():
		var prototype_script = load("res://utils/floor_data_details.gd")
		double_script = prototype_script.new(
			{
				0: {
					0: {
						"type": "base_tile",
					}
				}
			}
		)


	func test_is_center_an_edge():
		var edges = double_script._get_piece_edges(0, 0)

		assert_eq(
			edges,
			[1, 1, 1, 1] as PoolIntArray,
			"Centerpiece and nothing else has edges on all sides"
		)


class Test_can_add_floor_piece_at:
	extends GutTest
	var double_script

	func before_each():
		var prototype_script = load("res://utils/floor_data_details.gd")
		var data = {
			0: {
				0: {
					"type": "floor",
				},
			}
		}

		double_script = prototype_script.new(data)


	func test_no_overlaps():
		var val: bool = double_script.can_add_floor_piece_at(0, 0)

		assert_eq(val, false, "Should not be able to add piece at 0, 0")


	func test_no_unattached_pieces():
		assert_eq(
			double_script.can_add_floor_piece_at(1 * TowerGlobals.TILE_MULTIPLE, 1 * TowerGlobals.TILE_MULTIPLE),
			false,
			"Should not be able to add piece at (1, 1) * TowerGlobals.TILE_MULTIPLE"
		)

		assert_eq(
			double_script.can_add_floor_piece_at(-1 * TowerGlobals.TILE_MULTIPLE, -1 * TowerGlobals.TILE_MULTIPLE),
			false,
			"Should not be able to add piece at (-1, -1) * TowerGlobals.TILE_MULTIPLE"
		)


	func test_can_attach_pieces():
		assert_eq(
			double_script.can_add_floor_piece_at(-1 * TowerGlobals.TILE_MULTIPLE, 0),
			true,
			"Should be able to add piece at (-1, 0) * TowerGlobals.TILE_MULTIPLE"
		)

		assert_eq(
			double_script.can_add_floor_piece_at(1 * TowerGlobals.TILE_MULTIPLE, 0),
			true,
			"Should be able to add piece at (1, 0) * TowerGlobals.TILE_MULTIPLE"
		)

		assert_eq(
			double_script.can_add_floor_piece_at(0, 1 * TowerGlobals.TILE_MULTIPLE),
			true,
			"Should be able to add piece at (0, 1) * TowerGlobals.TILE_MULTIPLE"
		)

		assert_eq(
			double_script.can_add_floor_piece_at(0, -1 * TowerGlobals.TILE_MULTIPLE),
			true,
			"Should be able to add piece at (0, -1) * TowerGlobals.TILE_MULTIPLE"
		)


	func test_can_add_when_nothing_exists():
		double_script._floor_data = {}

		assert_eq(
			double_script.can_add_floor_piece_at(0, 0),
			true,
			"Should be able to add piece at (0, 0) when none exists"
		)


class Test_can_remove_floor_piece_at:
	extends GutTest
	var double_script

	func before_each():
		var prototype_script = load("res://utils/floor_data_details.gd")
		var data = {
			0: {
				0: {
					"type": "floor",
				},
			}
		}

		data[0][1 * TowerGlobals.TILE_MULTIPLE] = {
			"type": "floor",
		}

		double_script = prototype_script.new(data)


	func test_can_remove_end_in_simple_row():
		double_script._floor_data = SpecHelper.get_simple_tower_data(TowerGlobals.TILE_MULTIPLE)[0]

		assert_eq(
			double_script.can_remove_floor_piece_at(0, 0),
			true,
			"Can remove piece at end of simple three piece row, no islands"
		)


	func test_cannot_remove_center_in_simple_row():
		double_script._floor_data = SpecHelper.get_simple_tower_data(TowerGlobals.TILE_MULTIPLE)[0]

		assert_eq(
			double_script.can_remove_floor_piece_at(0, 1 * TowerGlobals.TILE_MULTIPLE),
			false,
			"Cannot remove piece in center of simple three piece row, no islands"
		)


	func test_can_remove_center_in_square():
		double_script._floor_data = SpecHelper.get_simple_square_tower_data(TowerGlobals.TILE_MULTIPLE)[0]

		assert_eq(
			double_script.can_remove_floor_piece_at(1 * TowerGlobals.TILE_MULTIPLE, 1 * TowerGlobals.TILE_MULTIPLE),
			true,
			"Can remove piece in center of 9 piece square"
		)



class Test_adjust_room_walls_on_piece_at:
	extends GutTest
	var room_data_script
	var floor_piece_script
	var prototype_script

	func _create_floor_piece():
		return {
			"type": "floor",
			"object": floor_piece_script.new()
		}

	func before_each():
		prototype_script = load("res://utils/floor_data_details.gd")
		floor_piece_script = double("res://scenes/floor/bottom_floor_piece.gd")

		var data = {}
		data[0] = {}
		data[0][0 * TowerGlobals.TILE_MULTIPLE] = _create_floor_piece()
		data[0][1 * TowerGlobals.TILE_MULTIPLE] = _create_floor_piece()

		room_data_script = prototype_script.new(data)


	func test_hides_wall_in_middle_of_room_and_edges_in_one_by_two_floor():
		var data = {}

		data[0] = {}
		data[0][0 * TowerGlobals.TILE_MULTIPLE] = {
			"type": "floor",
			"object": floor_piece_script.new()
		}
		data[0][1 * TowerGlobals.TILE_MULTIPLE] = {
			"type": "floor",
			"object": floor_piece_script.new()
		}

		var floor_data_script = prototype_script.new(data)

		room_data_script.adjust_room_walls_on_piece_at(0, 0, floor_data_script)
		var first_object = room_data_script._floor_data[0][0]["object"]

		assert_called(first_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.XUP])
		assert_called(first_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.XDOWN])
		assert_called(first_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.ZUP])
		assert_called(first_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.ZDOWN])

		room_data_script.adjust_room_walls_on_piece_at(0, 1 * TowerGlobals.TILE_MULTIPLE, floor_data_script)
		var second_object = room_data_script._floor_data[0][1 * TowerGlobals.TILE_MULTIPLE]["object"]

		assert_called(second_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.XUP])
		assert_called(second_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.XDOWN])
		assert_called(second_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.ZUP])
		assert_called(second_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.ZDOWN])


	func test_hides_wall_in_middle_of_room_and_appropriate_edges_in_bigger_floor_at_edge():
		var data = {}

		for i in range(2):
			data[i * TowerGlobals.TILE_MULTIPLE] = {}

			for y in range(3):
				data[i * TowerGlobals.TILE_MULTIPLE][y * TowerGlobals.TILE_MULTIPLE] = _create_floor_piece()

		var floor_data_script = prototype_script.new(data)

		room_data_script.adjust_room_walls_on_piece_at(0, 0, floor_data_script)

		var first_object = room_data_script._floor_data[0][0]["object"]

		assert_not_called(first_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.XUP])
		assert_called(first_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.XDOWN])
		assert_called(first_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.ZUP])
		assert_called(first_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.ZDOWN])


	func test_hides_wall_in_middle_of_room_and_appropriate_edges_in_bigger_floor_at_center():
		var data = {}

		for i in range(3):
			data[i * TowerGlobals.TILE_MULTIPLE] = {}

			for y in range(4):
				data[i * TowerGlobals.TILE_MULTIPLE][y * TowerGlobals.TILE_MULTIPLE] = _create_floor_piece()

		var floor_data_script = prototype_script.new(data)

		room_data_script.adjust_room_walls_on_piece_at(
			0, 0, floor_data_script,
			Vector3(1 * TowerGlobals.TILE_MULTIPLE, 0, 1 * TowerGlobals.TILE_MULTIPLE)
		)
		room_data_script.adjust_room_walls_on_piece_at(
			0, 1 * TowerGlobals.TILE_MULTIPLE, floor_data_script,
			Vector3(1 * TowerGlobals.TILE_MULTIPLE, 0, 1 * TowerGlobals.TILE_MULTIPLE)
		)

		var first_object = room_data_script._floor_data[0][0]["object"]
		var second_object = room_data_script._floor_data[0][1 * TowerGlobals.TILE_MULTIPLE]["object"]

		assert_not_called(first_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.XUP])
		assert_not_called(first_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.XDOWN])
		assert_called(first_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.ZUP])
		assert_not_called(first_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.ZDOWN])

		assert_not_called(second_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.XUP])
		assert_not_called(second_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.XDOWN])
		assert_not_called(second_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.ZUP])
		assert_called(second_object, "hide_wall_at_edge", [FloorDataDetails.SIDE.ZDOWN])


