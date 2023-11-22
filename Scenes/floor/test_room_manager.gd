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
		room_manager_node = Node3D.new()
		# room_manager_node.set_script(room_manager)

		var data = {
			0: {
				0: {
					"type": "floor",
				},
			},
		}

		data[TowerGlobals.TILE_MULTIPLE * 1] = {}
		data[TowerGlobals.TILE_MULTIPLE * 1][0] = {
			"type": "floor"
		}

		room_manager.floor_data_details = fdd_script.new(data)

		room_manager._hover_item = room_manager._small_office_1x2.instantiate()
		room_manager_node.add_child(room_manager._hover_item)

		add_child_autofree(room_manager_node)


	func after_each():
		room_manager._hover_item.free()
		room_manager.free()


	func test_places_item_in_appropriate_spot():
		var result = room_manager._can_place_room_at(Vector3(0, 0, 0))

		assert_true(result, "Can place room in available area")


	func test_cannot_place_item_in_completely_inappropriate_spot():
		var result = room_manager._can_place_room_at(Vector3(TowerGlobals.TILE_MULTIPLE, 0, 0))

		assert_false(result, "Cannot place room in completely unavailable area")


	func test_cannot_place_item_in_partially_inappropriate_spot():
		var result = room_manager._can_place_room_at(Vector3(0, 0, TowerGlobals.TILE_MULTIPLE))

		assert_false(result, "Cannot place room in partially unavailable area")


	func test_cannot_place_item_after_rotating():
		room_manager._rotate_hover_item()
		var result = room_manager._can_place_room_at(Vector3(0, 0, 0))

		assert_false(result, "Cannot place room after rotating")


	func test_can_place_item_after_rotating_four_time():
		room_manager._rotate_hover_item()
		room_manager._rotate_hover_item()
		room_manager._rotate_hover_item()
		room_manager._rotate_hover_item()
		var result = room_manager._can_place_room_at(Vector3(0, 0, 0))

		assert_true(result, "Can place room after rotating four times")
		assert_true(room_manager.floor_data_details != null)


class Test__rotate_hover_item:
	extends GutTest

	var room_manager
	var room_manager_node

	func before_each():
		var prototype_script = load("res://scenes/floor/room_manager.gd")
		var fdd_script = load("res://utils/floor_data_details.gd")

		room_manager = prototype_script.new()
		room_manager_node = Node3D.new()
		# room_manager_node.set_script(room_manager)

		var data = {
			0: {
				0: {
					"type": "floor",
				},
			},
		}

		data[0][TowerGlobals.TILE_MULTIPLE * 1] = {
			"type": "floor"
		}
		data[0][TowerGlobals.TILE_MULTIPLE * 2] = {
			"type": "floor"
		}
		data[TowerGlobals.TILE_MULTIPLE * 1] = {}
		data[TowerGlobals.TILE_MULTIPLE * 1][0] = {
			"type": "floor"
		}
		data[TowerGlobals.TILE_MULTIPLE * 1][TowerGlobals.TILE_MULTIPLE * 1] = {
			"type": "floor"
		}

		room_manager.floor_data_details = fdd_script.new(data)

		room_manager._hover_item = room_manager._small_office_1x2.instantiate()
		room_manager_node.add_child(room_manager._hover_item)

		add_child_autofree(room_manager_node)


	func after_each():
		room_manager._hover_item.free()
		room_manager.free()


	func test_rotate_adjusts_hover_item():
		room_manager._rotate_hover_item()
		assert_eq(room_manager._hover_item_rotation, TowerGlobals.ROTATION.NINETY)
		assert_eq(room_manager._hover_item.rotation_degrees.y, 90)

		room_manager._rotate_hover_item()
		assert_eq(room_manager._hover_item_rotation, TowerGlobals.ROTATION.ONEEIGHTY)
		assert_eq(room_manager._hover_item.rotation_degrees.y, 180)

		room_manager._rotate_hover_item()
		assert_eq(room_manager._hover_item_rotation, TowerGlobals.ROTATION.TWOSEVENTY)
		assert_eq(room_manager._hover_item.rotation_degrees.y, 270)

		room_manager._rotate_hover_item()
		assert_eq(room_manager._hover_item_rotation, TowerGlobals.ROTATION.ZERO)
		assert_eq(room_manager._hover_item.rotation_degrees.y, 0)


	func test_rotate_adjusts_hover_item_backwards():
		room_manager._rotate_hover_item(true)
		assert_eq(room_manager._hover_item_rotation, TowerGlobals.ROTATION.TWOSEVENTY)
		assert_eq(room_manager._hover_item.rotation_degrees.y, 270)

		room_manager._rotate_hover_item(true)
		assert_eq(room_manager._hover_item_rotation, TowerGlobals.ROTATION.ONEEIGHTY)
		assert_eq(room_manager._hover_item.rotation_degrees.y, 180)

		room_manager._rotate_hover_item(true)
		assert_eq(room_manager._hover_item_rotation, TowerGlobals.ROTATION.NINETY)
		assert_eq(room_manager._hover_item.rotation_degrees.y, 90)

		room_manager._rotate_hover_item(true)
		assert_eq(room_manager._hover_item_rotation, TowerGlobals.ROTATION.ZERO)
		assert_eq(room_manager._hover_item.rotation_degrees.y, 0)


