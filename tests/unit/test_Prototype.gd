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


class Test__can_remove_floor_piece_at:
	extends GutTest
	var double_script

	var tower_data_simple_row = [
		{
			0: {
				0: {
					"type": "floor"
				},
				1: {
					"type": "floor"
				},
				2: {
					"type": "floor"
				}
			}
		}
	]

	var tower_data_square = [
		{
			0: {
				0: {
					"type": "floor"
				},
				1: {
					"type": "floor"
				},
				2: {
					"type": "floor"
				}
			},
			1: {
				0: {
					"type": "floor"
				},
				1: {
					"type": "floor"
				},
				2: {
					"type": "floor"
				}
			},
			2: {
				0: {
					"type": "floor"
				},
				1: {
					"type": "floor"
				},
				2: {
					"type": "floor"
				}
			}
		}
	]


	func before_each():
		var prototype_script = partial_double("res://Scenes/Prototype.gd")
		double_script = prototype_script.new()


	func test_cannot_remove_center_in_simple_row():
		double_script.floor_data = tower_data_simple_row[0]

		assert_eq(
			double_script._can_remove_floor_piece_at(0, 1),
			false,
			"Cannot remove piece in center of simple three piece row, no islands"
		)


	func test_can_remove_center_in_square():
		double_script.floor_data = tower_data_square[0]

		assert_eq(
			double_script._can_remove_floor_piece_at(0, 1),
			true,
			"Can remove piece in center of 9 piece square"
		)


class Test__get_piece_count:
	extends GutTest
	var double_script

	var tower_data_simple_row = [
		{
			0: {
				0: {
					"type": "floor"
				},
				1: {
					"type": "floor"
				},
				2: {
					"type": "floor"
				}
			}
		}
	]

	var tower_data_square = [
		{
			0: {
				0: {
					"type": "floor"
				},
				1: {
					"type": "floor"
				},
				2: {
					"type": "floor"
				}
			},
			1: {
				0: {
					"type": "floor"
				},
				1: {
					"type": "floor"
				},
				2: {
					"type": "floor"
				}
			},
			2: {
				0: {
					"type": "floor"
				},
				1: {
					"type": "floor"
				},
				2: {
					"type": "floor"
				}
			}
		}
	]


	func before_each():
		var prototype_script = partial_double("res://Scenes/Prototype.gd")
		double_script = prototype_script.new()


	func test_count_simple():
		double_script.floor_data = tower_data_simple_row[0]

		assert_eq(
			double_script._get_piece_count(),
			3,
			"Simple count is 3 pieces"
		)


	func test_count_square():
		double_script.floor_data = tower_data_square[0]

		assert_eq(
			double_script._get_piece_count(),
			9,
			"Square count is 9 pieces"
		)
