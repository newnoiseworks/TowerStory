extends GutTest

var FloorDataDetails = preload("res://utils/floor_data_details.gd")

class Test_place_walls_where_needed:
	extends GutTest
	var test_room

	func before_each():
		var prototype_script = load("res://scenes/room/room_1x2.tscn")
		test_room = prototype_script.instance()
		add_child_autofree(test_room)


	func test_no_middle_wall_between_cells():
		var fdd = FloorDataDetails.new({
			-1 * TowerGlobals.TILE_MULTIPLE: {
				-1 * TowerGlobals.TILE_MULTIPLE: {
					"type": "base_tile",
				},
				0: {
					"type": "base_tile",
				},
				1 * TowerGlobals.TILE_MULTIPLE: {
					"type": "base_tile",
				}
			},
			0: {
				-1 * TowerGlobals.TILE_MULTIPLE: {
					"type": "base_tile",
				},
				0: {
					"type": "base_tile",
				},
				1 * TowerGlobals.TILE_MULTIPLE: {
					"type": "base_tile",
				}
			},
			1 * TowerGlobals.TILE_MULTIPLE: {
				-1 * TowerGlobals.TILE_MULTIPLE: {
					"type": "base_tile",
				},
				0: {
					"type": "base_tile",
				},
				1 * TowerGlobals.TILE_MULTIPLE: {
					"type": "base_tile",
				}
			},
		})

		test_room.place_walls_where_needed(fdd)

		assert_false(
			test_room.floor_data[0][0]["object"].find_node("wall0").is_visible()
		)

		assert_true(
			test_room.floor_data[0][0]["object"].find_node("wall1").is_visible()
		)



