extends Resource

class_name FloorDataDetails

var _floor_data = {}
var _floor_idx

func _init(floor_data, floor_idx = null):
	_floor_data = floor_data
	_floor_idx = floor_idx


func get_piece_count(_floor = null)-> int:
	if _floor == null:
		_floor = _floor_data

	var piece_count = 0

	for x in _floor:
		piece_count += _floor[x].keys().size()

	return piece_count


func adjust_room_walls_on_piece_at(
	room_tile_position: Vector3i,
	enclosing_floor_details: FloorDataDetails,
	position_of_room_in_floor: Vector3 = Vector3.ZERO,
	rotation: TowerGlobals.ROTATION = TowerGlobals.ROTATION.ZERO
):
	var floor_pos = TowerGlobals.adjust_position_based_on_room_rotation(
		room_tile_position,
		position_of_room_in_floor,
		rotation
	)

	var floor_edges = enclosing_floor_details._get_piece_edges(floor_pos.x, floor_pos.z)
	var room_edges = _get_piece_edges(room_tile_position.x, room_tile_position.z)
	var floor_piece = _floor_data[room_tile_position.x][room_tile_position.z]["object"]

	for i in range(4):
		var room_edge_idx = TowerGlobals.get_rotated_side(i as TowerGlobals.SIDE, rotation)

		floor_piece.call("hide_wall_at_edge", room_edge_idx)

		var floor_edge = floor_edges[i]
		var room_edge = room_edges[room_edge_idx]

		if floor_edge == 0 && room_edge == 1:
			floor_piece.call("add_wall_at_edge", room_edge_idx)


func add_edges_to_surrounding_pieces(x: int, z: int):
	var edges = _get_piece_edges(x, z)

	if edges[TowerGlobals.SIDE.XUP] == 0: add_wall_to_piece_at_edges(x+TowerGlobals.TILE_MULTIPLE, z)
	if edges[TowerGlobals.SIDE.XDOWN] == 0: add_wall_to_piece_at_edges(x-TowerGlobals.TILE_MULTIPLE, z)
	if edges[TowerGlobals.SIDE.ZUP] == 0: add_wall_to_piece_at_edges(x, z+TowerGlobals.TILE_MULTIPLE)
	if edges[TowerGlobals.SIDE.ZDOWN] == 0: add_wall_to_piece_at_edges(x, z-TowerGlobals.TILE_MULTIPLE)


func add_wall_to_piece_at_edges(x: int, z:int):
	var edges = _get_piece_edges(x, z)

	var floor_piece = _floor_data[x][z]["object"]

	floor_piece.call("hide_walls")

	if edges[TowerGlobals.SIDE.XUP] == 1:
		floor_piece.call("add_wall_at_edge", TowerGlobals.SIDE.XUP)

	if edges[TowerGlobals.SIDE.XDOWN] == 1:
		floor_piece.call("add_wall_at_edge", TowerGlobals.SIDE.XDOWN)

	if edges[TowerGlobals.SIDE.ZUP] == 1:
		floor_piece.call("add_wall_at_edge", TowerGlobals.SIDE.ZUP)

	if edges[TowerGlobals.SIDE.ZDOWN] == 1:
		floor_piece.call("add_wall_at_edge", TowerGlobals.SIDE.ZDOWN)


func is_floor_contiguous(_floor = null)-> bool:
	if _floor == null:
		_floor = _floor_data

	var x = _floor.keys()[0]
	var z = _floor[x].keys()[0]
	var touched = _get_pieces_contiguous_to(_floor, x, z, {})
	var count = touched.keys().size()
	return count == get_piece_count(_floor)


func has_floor_piece_at(x: int, z: int)-> bool:
	return _floor_data.has(x) and _floor_data[x].has(z)


func can_add_floor_piece_at(x: int, z: int)-> bool:
	if has_floor_piece_at(x, z):
		return false

	if get_piece_count() > 0 and !_is_connected_at(x, z):
		return false

	return true


func can_remove_floor_piece_at(x: int, z: int, is_transparent = false)-> bool:
	if !has_floor_piece_at(x, z):
		print_debug("Can't delete a floor piece that doesn't exist")
		return false

	if _floor_idx == 1 || get_piece_count() > 1:
		var floor_copy = _floor_data.duplicate(true)
		floor_copy[x].erase(z)

		if !is_transparent and get_piece_count(floor_copy) > 0 and !is_floor_contiguous(floor_copy):
			print_debug("Can't make a base floor non contiguous")
			return false

		if is_transparent and !_floor_data[x][z]["object"].is_transparent:
			return false

	return true


func _get_piece_edges(x: int, z: int)-> PackedInt32Array:
	var edges: PackedInt32Array = [0, 0, 0, 0]

	if !_floor_data.has(x+TowerGlobals.TILE_MULTIPLE) or !_floor_data[x+TowerGlobals.TILE_MULTIPLE].has(z):
		edges[TowerGlobals.SIDE.XUP] = 1
	else:
		edges[TowerGlobals.SIDE.XUP] = 0

	if !_floor_data.has(x-TowerGlobals.TILE_MULTIPLE) or !_floor_data[x-TowerGlobals.TILE_MULTIPLE].has(z):
		edges[TowerGlobals.SIDE.XDOWN] = 1
	else:
		edges[TowerGlobals.SIDE.XDOWN] = 0

	if !_floor_data.has(x) or !_floor_data[x].has(z+TowerGlobals.TILE_MULTIPLE):
		edges[TowerGlobals.SIDE.ZUP] = 1
	else:
		edges[TowerGlobals.SIDE.ZUP] = 0

	if !_floor_data.has(x) or !_floor_data[x].has(z-TowerGlobals.TILE_MULTIPLE):
		edges[TowerGlobals.SIDE.ZDOWN] = 1 
	else:
		edges[TowerGlobals.SIDE.ZDOWN] = 0

	return edges


func _get_pieces_contiguous_to(_floor: Dictionary, x: int, z: int, touched: Dictionary) -> Dictionary:
	touched["%s,%s" % [x, z]] = true

	if _floor[x].has(z-TowerGlobals.TILE_MULTIPLE) && !touched.has("%s,%s" % [x, z-TowerGlobals.TILE_MULTIPLE]):
		touched = _get_pieces_contiguous_to(_floor, x, z-TowerGlobals.TILE_MULTIPLE, touched)

	if _floor[x].has(z+TowerGlobals.TILE_MULTIPLE) && !touched.has("%s,%s" % [x, z+TowerGlobals.TILE_MULTIPLE]):
		touched = _get_pieces_contiguous_to(_floor, x, z+TowerGlobals.TILE_MULTIPLE, touched)

	if _floor.has(x-TowerGlobals.TILE_MULTIPLE) and _floor[x-TowerGlobals.TILE_MULTIPLE].has(z) && !touched.has("%s,%s" % [x-TowerGlobals.TILE_MULTIPLE, z]):
		touched = _get_pieces_contiguous_to(_floor, x-TowerGlobals.TILE_MULTIPLE, z, touched)

	if _floor.has(x+TowerGlobals.TILE_MULTIPLE) and _floor[x+TowerGlobals.TILE_MULTIPLE].has(z) && !touched.has("%s,%s" % [x+TowerGlobals.TILE_MULTIPLE, z]):
		touched = _get_pieces_contiguous_to(_floor, x+TowerGlobals.TILE_MULTIPLE, z, touched)

	return touched


func _is_connected_at(x: int, z: int)-> bool:
	if ((
		_floor_data.has(x) and (_floor_data[x].has(z-TowerGlobals.TILE_MULTIPLE) or _floor_data[x].has(z+TowerGlobals.TILE_MULTIPLE))
	) or (
		_floor_data.has(x-TowerGlobals.TILE_MULTIPLE) and _floor_data[x-TowerGlobals.TILE_MULTIPLE].has(z)
	) or (
		_floor_data.has(x+TowerGlobals.TILE_MULTIPLE) and _floor_data[x+TowerGlobals.TILE_MULTIPLE].has(z)
	)):
		return true

	return false


