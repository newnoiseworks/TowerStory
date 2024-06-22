extends GutTest

var SpecHelper = preload("res://utils/test/spec_helper.gd")

class Test_get_piece_count:
	extends GutTest
	var script_double

	func before_each():
		var prototype_script = load("res://scenes/floor/floor.gd")
		script_double = prototype_script.new()


	func after_each():
		script_double.free()


	func test_count_simple():
		script_double.floor_data = SpecHelper.get_simple_tower_floor(TowerGlobals.TILE_MULTIPLE)

		assert_eq(
			script_double.get_piece_count(),
			3,
			"Simple count is 3 pieces"
		)


	func test_count_square():
		script_double.floor_data = SpecHelper.get_simple_square_tower_data(TowerGlobals.TILE_MULTIPLE)[0]

		assert_eq(
			script_double.get_piece_count(),
			9,
			"Square count is 9 pieces"
		)


class Test_add_pieces_as_needed:
	extends GutTest

	var test_floor
	var building

	func before_each():
		var prototype_script = load("res://scenes/floor/floor.tscn")
		test_floor = prototype_script.instantiate()
		building = Node3D.new()
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
		test_floor = prototype_script.instantiate()
		var building = Node3D.new()
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

		assert_eq(first_piece.find_child("wall1").is_visible(), false, "Walls turned off in appropriate area of overlapping pieces")
		assert_eq(first_piece.find_child("wall3").is_visible(), false, "Walls turned off in appropriate area of overlapping pieces")


