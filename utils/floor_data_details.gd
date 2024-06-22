extends Resource

class_name FloorDataDetails

var _floor_data = {}
var room_data_tiles = {}

var _floor_idx

func _init(floor_data, floor_idx = null):
	_floor_data = floor_data
	_floor_idx = floor_idx


func get_piece_count(_floor = null)-> int:
	if _floor == null:
		_floor = _floor_data

	var piece_count = 0

	for y in _floor:
		for x in _floor:
			piece_count += _floor[y][x].keys().size()

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

	var floor_edges = enclosing_floor_details._get_piece_edges(floor_pos)
	var room_edges = _get_piece_edges(room_tile_position)
	var floor_piece = _floor_data[room_tile_position.y][room_tile_position.x][room_tile_position.z]["object"]

	for i in range(4):
		var room_edge_idx = TowerGlobals.get_rotated_side(i as TowerGlobals.SIDE, rotation)

		floor_piece.call("hide_wall_at_edge", room_edge_idx)

		var floor_edge = floor_edges[i]
		var room_edge = room_edges[room_edge_idx]
		var room_adjacent = _is_room_adjacent_to_tile_on_side(
			enclosing_floor_details,
			floor_pos,
			i as TowerGlobals.SIDE
		)

		if floor_edge == 0 && room_edge == 1 && !room_adjacent:
			floor_piece.call("add_wall_at_edge", room_edge_idx)


func add_edges_to_surrounding_pieces(pos: Vector3i):
	var edges = _get_piece_edges(pos)

	if edges[TowerGlobals.SIDE.XUP] == 0: add_wall_to_piece_at_edges(Vector3i(pos.x+TowerGlobals.TILE_MULTIPLE, pos.y, pos.z))
	if edges[TowerGlobals.SIDE.XDOWN] == 0: add_wall_to_piece_at_edges(Vector3i(pos.x-TowerGlobals.TILE_MULTIPLE, pos.y, pos.z))
	if edges[TowerGlobals.SIDE.ZUP] == 0: add_wall_to_piece_at_edges(Vector3i(pos.x, pos.y, pos.z+TowerGlobals.TILE_MULTIPLE))
	if edges[TowerGlobals.SIDE.ZDOWN] == 0: add_wall_to_piece_at_edges(Vector3i(pos.x, pos.y, pos.z-TowerGlobals.TILE_MULTIPLE))


func add_wall_to_piece_at_edges(pos: Vector3i):
	var edges = _get_piece_edges(pos)

	var floor_piece = _floor_data[pos.y][pos.x][pos.z]["object"]

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

	var y = _floor.keys()[0]
	var x = _floor[y].keys()[0]
	var z = _floor[y][x].keys()[0]
	var touched = _get_pieces_contiguous_to(_floor, Vector3i(x, y, z), {})
	var count = touched.keys().size()
	return count == get_piece_count(_floor)


func has_floor_piece_at(pos: Vector3i)-> bool:
	return _floor_data.has(pos.y) and _floor_data[pos.y].has(pos.x) and _floor_data[pos.y][pos.x].has(pos.z)


func can_add_floor_piece_at(pos: Vector3i)-> bool:
	if has_floor_piece_at(pos):
		return false

	if get_piece_count() > 0 and !_is_connected_at(pos):
		return false

	return true


func can_remove_floor_piece_at(pos: Vector3i, is_transparent = false)-> bool:
	if !has_floor_piece_at(pos):
		print_debug("Can't delete a floor piece that doesn't exist")
		return false

	if _floor_idx == 1 || get_piece_count() > 1:
		var floor_copy = _floor_data.duplicate(true)
		floor_copy[pos.y][pos.x].erase(pos.z)

		if !is_transparent and get_piece_count(floor_copy) > 0 and !is_floor_contiguous(floor_copy):
			print_debug("Can't make a base floor non contiguous")
			return false

		if is_transparent and !_floor_data[pos.x][pos.z]["object"].is_transparent:
			return false

	return true


func _get_piece_edges(pos: Vector3i)-> PackedInt32Array:
	var edges: PackedInt32Array = [0, 0, 0, 0]

	if !_floor_data.has(pos.y) or !_floor_data[pos.y].has(pos.x+TowerGlobals.TILE_MULTIPLE) or !_floor_data[pos.y][pos.x+TowerGlobals.TILE_MULTIPLE].has(pos.z):
		edges[TowerGlobals.SIDE.XUP] = 1
	else:
		edges[TowerGlobals.SIDE.XUP] = 0

	if !_floor_data.has(pos.y) or !_floor_data[pos.y].has(pos.x-TowerGlobals.TILE_MULTIPLE) or !_floor_data[pos.y][pos.x-TowerGlobals.TILE_MULTIPLE].has(pos.z):
		edges[TowerGlobals.SIDE.XDOWN] = 1
	else:
		edges[TowerGlobals.SIDE.XDOWN] = 0

	if !_floor_data.has(pos.y) or !_floor_data[pos.y].has(pos.x) or !_floor_data[pos.y][pos.x].has(pos.z+TowerGlobals.TILE_MULTIPLE):
		edges[TowerGlobals.SIDE.ZUP] = 1
	else:
		edges[TowerGlobals.SIDE.ZUP] = 0

	if !_floor_data.has(pos.y) or !_floor_data[pos.y].has(pos.x) or !_floor_data[pos.y][pos.x].has(pos.z-TowerGlobals.TILE_MULTIPLE):
		edges[TowerGlobals.SIDE.ZDOWN] = 1 
	else:
		edges[TowerGlobals.SIDE.ZDOWN] = 0

	return edges


func _get_pieces_contiguous_to(_floor: Dictionary, pos: Vector3i, touched: Dictionary) -> Dictionary:
	var x = pos.x
	var y = pos.y
	var z = pos.z

	touched["%s,%s,%s" % [y, x, z]] = true

	if _floor.has(y) && _floor[y].has(x) && _floor[y][x].has(z-TowerGlobals.TILE_MULTIPLE) && !touched.has("%s,%s,%s" % [y, x, z-TowerGlobals.TILE_MULTIPLE]):
		touched = _get_pieces_contiguous_to(_floor, Vector3i(x, y, z-TowerGlobals.TILE_MULTIPLE), touched)

	if _floor.has(y) && _floor[y].has(x) && _floor[y][x].has(z+TowerGlobals.TILE_MULTIPLE) && !touched.has("%s,%s,%s" % [y, x, z+TowerGlobals.TILE_MULTIPLE]):
		touched = _get_pieces_contiguous_to(_floor, Vector3i(x, y, z+TowerGlobals.TILE_MULTIPLE), touched)

	if _floor.has(y) && _floor[y].has(x-TowerGlobals.TILE_MULTIPLE) and _floor[y][x-TowerGlobals.TILE_MULTIPLE].has(z) && !touched.has("%s,%s,%s" % [y, x-TowerGlobals.TILE_MULTIPLE, z]):
		touched = _get_pieces_contiguous_to(_floor, Vector3i(x-TowerGlobals.TILE_MULTIPLE, y, z), touched)

	if _floor.has(y) && _floor[y].has(x+TowerGlobals.TILE_MULTIPLE) and _floor[y][x+TowerGlobals.TILE_MULTIPLE].has(z) && !touched.has("%s,%s,%s" % [y, x+TowerGlobals.TILE_MULTIPLE, z]):
		touched = _get_pieces_contiguous_to(_floor, Vector3i(x+TowerGlobals.TILE_MULTIPLE, y, z), touched)

	return touched


func _is_connected_at(pos: Vector3i)-> bool:
	var x = pos.x
	var y = pos.y
	var z = pos.z

	if ((
		_floor_data.has(y) and _floor_data[y].has(x) and (_floor_data[y][x].has(z-TowerGlobals.TILE_MULTIPLE) or _floor_data[y][x].has(z+TowerGlobals.TILE_MULTIPLE))
	) or (
		_floor_data.has(y) and _floor_data[y].has(x-TowerGlobals.TILE_MULTIPLE) and _floor_data[y][x-TowerGlobals.TILE_MULTIPLE].has(z)
	) or (
		_floor_data.has(y) and _floor_data[y].has(x+TowerGlobals.TILE_MULTIPLE) and _floor_data[y][x+TowerGlobals.TILE_MULTIPLE].has(z)
	)):
		return true

	return false


func _is_room_adjacent_to_tile_on_side(
	enclosing_floor_details: FloorDataDetails,
	tile_pos: Vector3i,
	side: TowerGlobals.SIDE
)-> bool:
	var adjusted_tile_pos = tile_pos

	match side:
		TowerGlobals.SIDE.XUP:
			adjusted_tile_pos.x += TowerGlobals.TILE_MULTIPLE
		TowerGlobals.SIDE.ZUP:
			adjusted_tile_pos.z += TowerGlobals.TILE_MULTIPLE
		TowerGlobals.SIDE.XDOWN:
			adjusted_tile_pos.x -= TowerGlobals.TILE_MULTIPLE
		TowerGlobals.SIDE.ZDOWN:
			adjusted_tile_pos.z -= TowerGlobals.TILE_MULTIPLE

	return enclosing_floor_details.room_data_tiles.has(adjusted_tile_pos.x) && enclosing_floor_details.room_data_tiles[adjusted_tile_pos.x].has(adjusted_tile_pos.z)


