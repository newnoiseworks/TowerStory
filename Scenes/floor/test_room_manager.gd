extends GutTest

var SpecHelper = preload("res://utils/test/spec_helper.gd")

class Test__can_place_room_at:
	extends GutTest

	var room_manager
	var room_manager_node

	func before_each():
		var prototype_script = load("res://scenes/floor/room_manager.gd")
		var fdd_script = load("res://utils/floor_data_details.gd")

		room_manager = prototype_script.new()
		room_manager_node = Spatial.new()
		room_manager_node.set_script(room_manager)

		var data = {
			0: {
				0: {
					"type": "floor",
				},
				2: {
					"type": "floor",
				},
			},
		}

		data[TowerGlobals.TILE_MULTIPLE * 1] = {}
		data[TowerGlobals.TILE_MULTIPLE * 1][0] = {
			"type": "floor"
		}

		room_manager.floor_data_details = fdd_script.new(data)

		room_manager._hover_item = room_manager._small_office_1x2.instance()
		room_manager_node.add_child(room_manager._hover_item)

		add_child_autofree(room_manager_node)


	func after_each():
		room_manager._hover_item.free()
		room_manager.queue_free()


	func test_places_item_in_appropriate_spot():
		var result = room_manager._can_place_room_at(Vector3(0, 0, 0))

		assert_true(result, "Can place room in available area")


	func test_cannot_place_item_in_completely_inappropriate_spot():
		var result = room_manager._can_place_room_at(Vector3(1, 0, 0))

		assert_false(result, "Cannot place room in completely unavailable area")


	func test_cannot_place_item_in_partially_inappropriate_spot():
		var result = room_manager._can_place_room_at(Vector3(0, 0, 1))

		assert_false(result, "Cannot place room in partially unavailable area")


