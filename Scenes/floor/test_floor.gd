extends GutTest

class Test__can__add_floor_piece_at:
	extends GutTest
	var double_script

	var tower_data = [
		{
			0: {
				0: {
					"type": "floor"
				}
			}
		}
	]

	func before_each():
		var prototype_script = partial_double("res://scenes/floor/floor.gd")
		double_script = prototype_script.new()
		double_script.floor_data = tower_data[0]


	func test_no_overlaps():
		var val: bool = double_script._can__add_floor_piece_at(0, 0)

		assert_eq(val, false, "Should not be able to add piece at 0, 0")


	func test_no_unattached_pieces():
		assert_eq(
			double_script._can__add_floor_piece_at(1 * TowerGlobals.TILE_MULTIPLE, 1 * TowerGlobals.TILE_MULTIPLE),
			false,
			"Should not be able to add piece at (1, 1) * TowerGlobals.TILE_MULTIPLE"
		)

		assert_eq(
			double_script._can__add_floor_piece_at(-1 * TowerGlobals.TILE_MULTIPLE, -1 * TowerGlobals.TILE_MULTIPLE),
			false,
			"Should not be able to add piece at (-1, -1) * TowerGlobals.TILE_MULTIPLE"
		)


	func test_can_attach_pieces():
		assert_eq(
			double_script._can__add_floor_piece_at(-1 * TowerGlobals.TILE_MULTIPLE, 0),
			true,
			"Should be able to add piece at (-1, 0) * TowerGlobals.TILE_MULTIPLE"
		)

		assert_eq(
			double_script._can__add_floor_piece_at(1 * TowerGlobals.TILE_MULTIPLE, 0),
			true,
			"Should be able to add piece at (1, 0) * TowerGlobals.TILE_MULTIPLE"
		)

		assert_eq(
			double_script._can__add_floor_piece_at(0, 1 * TowerGlobals.TILE_MULTIPLE),
			true,
			"Should be able to add piece at (0, 1) * TowerGlobals.TILE_MULTIPLE"
		)

		assert_eq(
			double_script._can__add_floor_piece_at(0, -1 * TowerGlobals.TILE_MULTIPLE),
			true,
			"Should be able to add piece at (0, -1) * TowerGlobals.TILE_MULTIPLE"
		)


	func test_can_add_when_nothing_exists():
		double_script.floor_data = {}

		assert_eq(
			double_script._can__add_floor_piece_at(0, 0),
			true,
			"Should be able to add piece at (0, 0) when none exists"
		)


class Test__get_piece_edges:
	extends GutTest
	var double_script

	var tower_data = [
		{
			0: {
				0: {
					"type": "floor"
				}
			}
		}
	]

	func before_each():
		var prototype_script = partial_double("res://scenes/floor/floor.gd")
		double_script = prototype_script.new()
		double_script.floor_data = tower_data[0]


	func test_is_center_an_edge():
		var edges = double_script._get_piece_edges(0, 0)

		assert_eq(
			edges,
			[1, 1, 1, 1] as PoolIntArray,
			"Centerpiece and nothing else has edges on all sides"
		)



class Test__is_floor_contiguous:
	extends GutTest
	var double_script

	func before_each():
		var prototype_script = partial_double("res://scenes/floor/floor.gd")
		double_script = prototype_script.new()


	func test_simple_is_contiguous():
		double_script.floor_data = Globals.get_simple_tower_data(TowerGlobals.TILE_MULTIPLE)[0]

		assert_eq(
			double_script._is_floor_contiguous(double_script.floor_data),
			true,
			"Simple row reads as contiguous"
		)
		

class Test__can_remove_floor_piece_at:
	extends GutTest
	var double_script

	func before_each():
		var prototype_script = partial_double("res://scenes/floor/floor.gd")
		double_script = prototype_script.new()


	func test_can_remove_end_in_simple_row():
		double_script.floor_data = Globals.get_simple_tower_data(TowerGlobals.TILE_MULTIPLE)[0]

		assert_eq(
			double_script._can_remove_floor_piece_at(0, 0),
			true,
			"Can remove piece at end of simple three piece row, no islands"
		)


	func test_cannot_remove_center_in_simple_row():
		double_script.floor_data = Globals.get_simple_tower_data(TowerGlobals.TILE_MULTIPLE)[0]

		assert_eq(
			double_script._can_remove_floor_piece_at(0, 1 * TowerGlobals.TILE_MULTIPLE),
			false,
			"Cannot remove piece in center of simple three piece row, no islands"
		)


	func test_can_remove_center_in_square():
		double_script.floor_data = Globals.get_simple_square_tower_data(TowerGlobals.TILE_MULTIPLE)[0]

		assert_eq(
			double_script._can_remove_floor_piece_at(1 * TowerGlobals.TILE_MULTIPLE, 1 * TowerGlobals.TILE_MULTIPLE),
			true,
			"Can remove piece in center of 9 piece square"
		)



class Test_get_piece_count:
	extends GutTest
	var double_script

	func before_each():
		var prototype_script = partial_double("res://scenes/floor/floor.gd")
		double_script = prototype_script.new()


	func test_count_simple():
		double_script.floor_data = Globals.get_simple_tower_data(TowerGlobals.TILE_MULTIPLE)[0]

		assert_eq(
			double_script.get_piece_count(),
			3,
			"Simple count is 3 pieces"
		)


	func test_count_square():
		double_script.floor_data = Globals.get_simple_square_tower_data(TowerGlobals.TILE_MULTIPLE)[0]

		assert_eq(
			double_script.get_piece_count(),
			9,
			"Square count is 9 pieces"
		)


class Test_add_pieces_as_needed:
	extends GutTest

	var test_floor
	var building

	func before_each():
		var prototype_script = load("res://scenes/floor/floor.tscn")
		test_floor = prototype_script.instance()
		building = Spatial.new()
		building.add_child(test_floor)
		add_child_autofree(building)


	func test_cant_add_non_contiguous_group_to_existing_group():
		test_floor.add_pieces_as_needed(
			Vector3(
				-12.076785, 0.100007, 0.179358
			),
			Vector3(
				0.076785, 0.100007, 0.179358
			)
		)

		var orig_children_count = building.get_child_count()

		test_floor.add_pieces_as_needed(
			Vector3(
				4.076785, 0.100007, 4.179358
			),
			Vector3(
				8.076785, 0.100007, 8.179358
			)
		)

		assert_eq(building.get_child_count(), orig_children_count, "No extra children have been added when not contiguous")


class Test__add_multiple_pieces_if_adjacent:
	extends GutTest

	var test_floor

	func before_each():
		var prototype_script = load("res://scenes/floor/floor.tscn")
		test_floor = prototype_script.instance()
		var building = Spatial.new()
		building.add_child(test_floor)
		add_child_autofree(building)


	func test_can_add_overlapping_pieces():
		# adds a piece to start
		test_floor.add_pieces_as_needed(
			Vector3(
				0, 0, 0
			),
			Vector3(
				0, 0, 0
			)
		)

		test_floor._add_multiple_pieces_if_adjacent(
			Vector3(
				-18.076785, 0.100007, -18.179358
			),
			Vector3(
				18.076785, 0.100007, 18.179358
			),
			Vector3(
				-18.076785, 0.100007, -18.179358
			),
			Vector3(
				18.076785, 0.100007, 18.179358
			)
		)

		var first_piece = test_floor.floor_data[0][0]["object"]
		var first_node = test_floor.get_parent().get_node("bottomFloorPiece")

		assert_eq(first_piece, first_node, "First piece is correctly set, no double creation of pieces")

		assert_eq(first_piece.find_node("wall1").is_visible(), false, "Walls turned off in appropriate area of overlapping pieces")
		assert_eq(first_piece.find_node("wall3").is_visible(), false, "Walls turned off in appropriate area of overlapping pieces")


class Globals:
	static func get_empty_tower_data():
		return {}


	static func get_simple_tower_data(multiple):
		var tower_data_simple_floor = {}

		tower_data_simple_floor[0] = {}

		tower_data_simple_floor[0][0] = { "type": "floor" }
		tower_data_simple_floor[0][multiple] = { "type": "floor" }
		tower_data_simple_floor[0][multiple * 2] = { "type": "floor" }

		return [tower_data_simple_floor]

	static func get_simple_square_tower_data(multiple):
		var tower_data_simple_floor = {}

		tower_data_simple_floor[0] = {}
		tower_data_simple_floor[multiple] = {}
		tower_data_simple_floor[multiple * 2] = {}

		tower_data_simple_floor[0][0] = { "type": "floor" }
		tower_data_simple_floor[0][multiple] = { "type": "floor" }
		tower_data_simple_floor[0][multiple * 2] = { "type": "floor" }

		tower_data_simple_floor[multiple][0] = { "type": "floor" }
		tower_data_simple_floor[multiple][multiple] = { "type": "floor" }
		tower_data_simple_floor[multiple][multiple * 2] = { "type": "floor" }

		tower_data_simple_floor[multiple * 2][0] = { "type": "floor" }
		tower_data_simple_floor[multiple * 2][multiple] = { "type": "floor" }
		tower_data_simple_floor[multiple * 2][multiple * 2] = { "type": "floor" }

		return [tower_data_simple_floor]
