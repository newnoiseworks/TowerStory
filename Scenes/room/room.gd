extends Node3D

@onready var tiles = find_child("tiles")

var FloorDataDetails = preload("res://utils/floor_data_details.gd")

var floor_data = {}

var _room_data_details = FloorDataDetails.new(floor_data)


func set_transparent():
	for tile in tiles.get_children():
		tile.set_transparent()


func set_opaque():
	for tile in tiles.get_children():
		tile.set_opaque()


func place_walls_where_needed(enclosing_floor_data_details: FloorDataDetails, room_rotation: TowerGlobals.ROTATION = TowerGlobals.ROTATION.ZERO):
	for x in floor_data:
		for z in floor_data[x]:
			_room_data_details.adjust_room_walls_on_piece_at(
				Vector3i(x, 0, z),
				enclosing_floor_data_details,
				Vector3(
					TowerGlobals.closest_multiple_of(
						int(global_transform.origin.x),
					),
					global_transform.origin.y,
					TowerGlobals.closest_multiple_of(
						int(global_transform.origin.z),
					),
				),
				room_rotation
			)


func _ready():
	_assemble_floor_data()


func _assemble_floor_data():
	for tile in tiles.get_children():
		var origin = tile.global_transform.origin

		var x = int(origin.x)
		var z = int(origin.z)

		if !floor_data.has(x):
			floor_data[x] = {}

		floor_data[x][z] = {
			"type": "base_tile",
			"object": tile,
		}


