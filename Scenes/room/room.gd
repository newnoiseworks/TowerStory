extends Spatial

onready var tiles = find_node("tiles")

var FloorDataDetails = preload("res://utils/floor_data_details.gd")

var floor_data = {}

var _room_data_details = FloorDataDetails.new(floor_data)


func set_transparent():
	for tile in tiles.get_children():
		tile.set_transparent()


func set_opaque():
	for tile in tiles.get_children():
		tile.set_opaque()


func place_walls_where_needed(enclosing_floor_data_details: FloorDataDetails):
	for x in floor_data:
		for z in floor_data[x]:
			_room_data_details.adjust_room_walls_on_piece_at(
				x, z, enclosing_floor_data_details, global_transform.origin
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


