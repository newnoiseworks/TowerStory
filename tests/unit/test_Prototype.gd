extends GutTest

class Test__can_add_floor_piece_at:
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
		var prototype_script = partial_double("res://Scenes/Prototype.gd")
		double_script = prototype_script.new()
		double_script.floor_data = tower_data[0]


	func test_no_overlaps():
		var val: bool = double_script._can_add_floor_piece_at(0, 0)

		assert_eq(val, false, "Should not be able to add piece at 0, 0")


	func test_no_unattached_pieces():
		assert_eq(
			double_script._can_add_floor_piece_at(1 * double_script.MULTIPLE, 1 * double_script.MULTIPLE),
			false,
			"Should not be able to add piece at (1, 1) * MULTIPLE"
		)

		assert_eq(
			double_script._can_add_floor_piece_at(-1 * double_script.MULTIPLE, -1 * double_script.MULTIPLE),
			false,
			"Should not be able to add piece at (-1, -1) * MULTIPLE"
		)


	func test_can_attach_pieces():
		assert_eq(
			double_script._can_add_floor_piece_at(-1 * double_script.MULTIPLE, 0),
			true,
			"Should be able to add piece at (-1, 0) * MULTIPLE"
		)

		assert_eq(
			double_script._can_add_floor_piece_at(1 * double_script.MULTIPLE, 0),
			true,
			"Should be able to add piece at (1, 0) * MULTIPLE"
		)

		assert_eq(
			double_script._can_add_floor_piece_at(0, 1 * double_script.MULTIPLE),
			true,
			"Should be able to add piece at (0, 1) * MULTIPLE"
		)

		assert_eq(
			double_script._can_add_floor_piece_at(0, -1 * double_script.MULTIPLE),
			true,
			"Should be able to add piece at (0, -1) * MULTIPLE"
		)


class Test__is_piece_an_edge:
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
		var prototype_script = partial_double("res://Scenes/Prototype.gd")
		double_script = prototype_script.new()
		double_script.floor_data = tower_data[0]


	func test_is_center_an_edge():
		var edges = double_script._is_piece_an_edge(0, 0)

		assert_eq(
			edges,
			[1, 1, 1, 1] as PoolIntArray,
			"Centerpiece and nothing else has edges on all sides"
		)