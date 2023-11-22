extends GutTest

var SpecHelper = preload("res://utils/test/spec_helper.gd")

class Test_is_floor_contiguous:
	extends GutTest
	var script_double

	func before_each():
		var prototype_script = load("res://utils/floor_data_details.gd")
		script_double = prototype_script.new({})


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
			script_double.is_floor_contiguous(data),
			"Simple row reads as contiguous"
		)


class Test__get_piece_edges:
	extends GutTest
	var script_double

	func before_each():
		var prototype_script = load("res://utils/floor_data_details.gd")
		script_double = prototype_script.new(
			{
				0: {
					0: {
						"type": "base_tile",
					}
				}
			}
		)


	func test_is_center_an_edge():
		var edges = script_double._get_piece_edges(0, 0)

		assert_eq(
			edges,
			[1, 1, 1, 1] as PackedInt32Array,
			"Centerpiece and nothing else has edges on all sides"
		)


class Test_can_add_floor_piece_at:
	extends GutTest
	var script_double

	func before_each():
		var prototype_script = load("res://utils/floor_data_details.gd")
		var data = {
			0: {
				0: {
					"type": "floor",
				},
			}
		}

		script_double = prototype_script.new(data)


	func test_no_overlaps():
		var val: bool = script_double.can_add_floor_piece_at(0, 0)

		assert_eq(val, false, "Should not be able to add piece at 0, 0")


	func test_no_unattached_pieces():
		assert_eq(
			script_double.can_add_floor_piece_at(1 * TowerGlobals.TILE_MULTIPLE, 1 * TowerGlobals.TILE_MULTIPLE),
			false,
			"Should not be able to add piece at (1, 1) * TowerGlobals.TILE_MULTIPLE"
		)

		assert_eq(
			script_double.can_add_floor_piece_at(-1 * TowerGlobals.TILE_MULTIPLE, -1 * TowerGlobals.TILE_MULTIPLE),
			false,
			"Should not be able to add piece at (-1, -1) * TowerGlobals.TILE_MULTIPLE"
		)


	func test_can_attach_pieces():
		assert_eq(
			script_double.can_add_floor_piece_at(-1 * TowerGlobals.TILE_MULTIPLE, 0),
			true,
			"Should be able to add piece at (-1, 0) * TowerGlobals.TILE_MULTIPLE"
		)

		assert_eq(
			script_double.can_add_floor_piece_at(1 * TowerGlobals.TILE_MULTIPLE, 0),
			true,
			"Should be able to add piece at (1, 0) * TowerGlobals.TILE_MULTIPLE"
		)

		assert_eq(
			script_double.can_add_floor_piece_at(0, 1 * TowerGlobals.TILE_MULTIPLE),
			true,
			"Should be able to add piece at (0, 1) * TowerGlobals.TILE_MULTIPLE"
		)

		assert_eq(
			script_double.can_add_floor_piece_at(0, -1 * TowerGlobals.TILE_MULTIPLE),
			true,
			"Should be able to add piece at (0, -1) * TowerGlobals.TILE_MULTIPLE"
		)


	func test_can_add_when_nothing_exists():
		script_double._floor_data = {}

		assert_eq(
			script_double.can_add_floor_piece_at(0, 0),
			true,
			"Should be able to add piece at (0, 0) when none exists"
		)


class Test_can_remove_floor_piece_at:
	extends GutTest
	var script_double

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

		script_double = prototype_script.new(data)


	func test_can_remove_end_in_simple_row():
		script_double._floor_data = SpecHelper.get_simple_tower_data(TowerGlobals.TILE_MULTIPLE)[0]

		assert_eq(
			script_double.can_remove_floor_piece_at(0, 0),
			true,
			"Can remove piece at end of simple three piece row, no islands"
		)


	func test_cannot_remove_center_in_simple_row():
		script_double._floor_data = SpecHelper.get_simple_tower_data(TowerGlobals.TILE_MULTIPLE)[0]

		assert_eq(
			script_double.can_remove_floor_piece_at(0, 1 * TowerGlobals.TILE_MULTIPLE),
			false,
			"Cannot remove piece in center of simple three piece row, no islands"
		)


	func test_can_remove_center_in_square():
		script_double._floor_data = SpecHelper.get_simple_square_tower_data(TowerGlobals.TILE_MULTIPLE)[0]

		assert_eq(
			script_double.can_remove_floor_piece_at(1 * TowerGlobals.TILE_MULTIPLE, 1 * TowerGlobals.TILE_MULTIPLE),
			true,
			"Can remove piece in center of 9 piece square"
		)



class Test_adjust_room_walls_on_piece_at:
	extends GutTest
	var room_data_script
	var prototype_script
	var floor_pieces = []


	func before_each():
		prototype_script = load("res://utils/floor_data_details.gd")

		var data = {}
		data[0] = {}
		data[0][0] = _create_floor_piece()
		data[0][1 * TowerGlobals.TILE_MULTIPLE] = _create_floor_piece()

		room_data_script = prototype_script.new(data)

	func after_each():
		for fp in floor_pieces:
			fp["object"].free()

		floor_pieces = []


	func _create_floor_piece():
		var floor_piece = load("res://scenes/floor/bottom_floor_piece.tscn")

		var obj = {
			"type": "floor",
			"object": floor_piece.instantiate()
		}

		floor_pieces.append(obj)

		return obj


	func test_hides_wall_in_middle_of_room_and_edges_in_one_by_two_floor():
		var data = {}

		data[0] = {}
		data[0][0 * TowerGlobals.TILE_MULTIPLE] = _create_floor_piece()
		data[0][1 * TowerGlobals.TILE_MULTIPLE] = _create_floor_piece()

		var floor_data_script = prototype_script.new(data)

		room_data_script.adjust_room_walls_on_piece_at(0, 0, floor_data_script)
		var first_object = room_data_script._floor_data[0][0]["object"]

		assert_false(first_object.find_child("wall%s" % FloorDataDetails.SIDE.XUP).is_visible())
		assert_false(first_object.find_child("wall%s" % FloorDataDetails.SIDE.XDOWN).is_visible())
		assert_false(first_object.find_child("wall%s" % FloorDataDetails.SIDE.ZUP).is_visible())
		assert_false(first_object.find_child("wall%s" % FloorDataDetails.SIDE.ZDOWN).is_visible())

		room_data_script.adjust_room_walls_on_piece_at(0, 1 * TowerGlobals.TILE_MULTIPLE, floor_data_script)
		var second_object = room_data_script._floor_data[0][1 * TowerGlobals.TILE_MULTIPLE]["object"]

		assert_false(second_object.find_child("wall%s" % FloorDataDetails.SIDE.XUP).is_visible())
		assert_false(second_object.find_child("wall%s" % FloorDataDetails.SIDE.XDOWN).is_visible())
		assert_false(second_object.find_child("wall%s" % FloorDataDetails.SIDE.ZUP).is_visible())
		assert_false(second_object.find_child("wall%s" % FloorDataDetails.SIDE.ZDOWN).is_visible())


	func test_hides_wall_in_middle_of_room_and_appropriate_edges_in_bigger_floor_at_edge():
		var data = {}

		for i in range(2):
			data[i * TowerGlobals.TILE_MULTIPLE] = {}

			for y in range(3):
				data[i * TowerGlobals.TILE_MULTIPLE][y * TowerGlobals.TILE_MULTIPLE] = _create_floor_piece()

		var floor_data_script = prototype_script.new(data)

		room_data_script.adjust_room_walls_on_piece_at(0, 0, floor_data_script)

		var first_object = room_data_script._floor_data[0][0]["object"]

		assert_true(first_object.find_child("wall%s" % FloorDataDetails.SIDE.XUP).is_visible())
		assert_false(first_object.find_child("wall%s" % FloorDataDetails.SIDE.XDOWN).is_visible())
		assert_false(first_object.find_child("wall%s" % FloorDataDetails.SIDE.ZUP).is_visible())
		assert_false(first_object.find_child("wall%s" % FloorDataDetails.SIDE.ZDOWN).is_visible())


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

		assert_true(first_object.find_child("wall%s" % FloorDataDetails.SIDE.XUP).is_visible())
		assert_true(first_object.find_child("wall%s" % FloorDataDetails.SIDE.XDOWN).is_visible())
		assert_false(first_object.find_child("wall%s" % FloorDataDetails.SIDE.ZUP).is_visible())
		assert_true(first_object.find_child("wall%s" % FloorDataDetails.SIDE.ZDOWN).is_visible())

		assert_false(second_object.find_child("wall%s" % FloorDataDetails.SIDE.XUP).is_visible())
		assert_false(second_object.find_child("wall%s" % FloorDataDetails.SIDE.XDOWN).is_visible())
		assert_false(second_object.find_child("wall%s" % FloorDataDetails.SIDE.ZUP).is_visible())
		assert_true(second_object.find_child("wall%s" % FloorDataDetails.SIDE.ZDOWN).is_visible())


