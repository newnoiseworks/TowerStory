extends Spatial

onready var tiles = find_node("tiles")

var FloorDataDetails = preload("res://utils/floor_data_details.gd")

var floor_data = {}

var _floor_data_details_obj


func set_transparent():
	for tile in tiles.get_children():
		tile.set_transparent()


func set_opaque():
	for tile in tiles.get_children():
		tile.set_opaque()


func place_walls_where_needed():
	for x in floor_data:
		for z in floor_data[x]:
			_floor_data_details().add_edges_to_surrounding_pieces(x, z)


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


func _floor_data_details():
	if _floor_data_details_obj == null:
		_floor_data_details_obj = FloorDataDetails.new(floor_data)

	return _floor_data_details_obj


