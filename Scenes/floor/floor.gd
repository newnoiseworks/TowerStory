extends Spatial

var floor_piece_packed = preload("res://scenes/floor/bottom_floor_piece.tscn")

var floor_data = {}

export var is_base = false
export var floor_idx = 1

enum SIDE {
	XUP, XDOWN, ZUP, ZDOWN
}


func draw_floor():
	for x in floor_data:
		for z in floor_data[x]:
			add_floor_piece_at(get_parent().global_transform.origin + Vector3(x, 0, z), true)

	for x in floor_data:
		for z in floor_data[x]:
			_add_wall_to_piece_at_edges(x, z)


func set_transparent():
	for x in floor_data:
		for z in floor_data[x]:
			floor_data[x][z]["object"].set_transparent()


func set_opaque():
	for x in floor_data:
		for z in floor_data[x]:
			floor_data[x][z]["object"].set_opaque()


func has_floor_piece_at(global_target: Vector3)-> bool:
	var target = get_parent().global_transform.origin + global_target

	var x = int(target.x)
	var z = int(target.z)

	return _has_floor_piece_at(x, z)


func add_floor_piece_at(global_target: Vector3, force: bool = false):
	var target = get_parent().global_transform.origin + global_target

	var x = int(target.x)
	var z = int(target.z)

	if !force and !_can_add_floor_piece_at(x, z): return

	if !floor_data.has(x): floor_data[x] = {}

	var floor_piece = floor_piece_packed.instance()

	floor_data[x][z] = {
		"type": "floor",
		"object": floor_piece
	}

	get_parent().add_child(floor_piece)

	floor_piece.global_transform.origin = target

	if !force:
		_add_wall_to_piece_at_edges(x, z)
		_add_edges_to_surrounding_pieces(x, z)


func remove_floor_piece_at(global_target: Vector3):
	var target = get_parent().global_transform.origin + global_target

	var x = int(target.x)
	var z = int(target.z)

	if _can_remove_floor_piece_at(x, z):
		floor_data[x][z]["object"].queue_free()
		floor_data[x].erase(z)

		_add_edges_to_surrounding_pieces(x, z)


func can_add_floor_piece_at(global_target: Vector3):
	var target = get_parent().global_transform.origin + global_target

	var x = int(target.x)
	var z = int(target.z)

	return _can_remove_floor_piece_at(x, z)


func _add_edges_to_surrounding_pieces(x: int, z: int):
	var edges = _is_piece_an_edge(x, z)

	if edges[SIDE.XUP] == 0: _add_wall_to_piece_at_edges(x+TowerGlobals.TILE_MULTIPLE, z)
	if edges[SIDE.XDOWN] == 0: _add_wall_to_piece_at_edges(x-TowerGlobals.TILE_MULTIPLE, z)
	if edges[SIDE.ZUP] == 0: _add_wall_to_piece_at_edges(x, z+TowerGlobals.TILE_MULTIPLE)
	if edges[SIDE.ZDOWN] == 0: _add_wall_to_piece_at_edges(x, z-TowerGlobals.TILE_MULTIPLE)


func _add_wall_to_piece_at_edges(x: int, z:int):
	var edges = _is_piece_an_edge(x, z)
	var floor_piece = floor_data[x][z]["object"]

	floor_piece.call("hide_walls")

	if edges[SIDE.XUP] == 1:
		floor_piece.call("add_wall_at_edge", SIDE.XUP)

	if edges[SIDE.XDOWN] == 1:
		floor_piece.call("add_wall_at_edge", SIDE.XDOWN)

	if edges[SIDE.ZUP] == 1:
		floor_piece.call("add_wall_at_edge", SIDE.ZUP)

	if edges[SIDE.ZDOWN] == 1:
		floor_piece.call("add_wall_at_edge", SIDE.ZDOWN)


func _can_add_floor_piece_at(x: int, z: int)-> bool:
	if _has_floor_piece_at(x, z):
		return false

	if _get_piece_count() > 0 and !_is_connected_at(x, z):
		return false

	return true


func _can_remove_floor_piece_at(x: int, z:int)-> bool:
	if !_has_floor_piece_at(x, z):
		print_debug("Can't delete a floor piece that doesn't exist")
		return false

	if floor_idx == 1 || _get_piece_count() > 1:
		var floor_copy = floor_data.duplicate(true)
		floor_copy[x].erase(z)

		if !_is_floor_contiguous(floor_copy):
			print_debug("Can't make a base floor non contiguous")
			return false

	return true


func _is_floor_contiguous(_floor):
	var x = _floor.keys()[0]
	var z = _floor[x].keys()[0]
	var touched = _get_pieces_contiguous_to(_floor, x, z, {}) 
	var count = touched.keys().size()
	return count == _get_piece_count(_floor)


func _is_piece_an_edge(x: int, z: int)-> PoolIntArray: 
	var edges: PoolIntArray = [0, 0, 0, 0]

	edges[SIDE.XUP] = 1 if !floor_data.has(x+TowerGlobals.TILE_MULTIPLE) or !floor_data[x+TowerGlobals.TILE_MULTIPLE].has(z) else 0
	edges[SIDE.XDOWN] = 1 if !floor_data.has(x-TowerGlobals.TILE_MULTIPLE) or !floor_data[x-TowerGlobals.TILE_MULTIPLE].has(z) else 0
	edges[SIDE.ZUP] = 1 if !floor_data[x].has(z+TowerGlobals.TILE_MULTIPLE) else 0
	edges[SIDE.ZDOWN] = 1 if !floor_data[x].has(z-TowerGlobals.TILE_MULTIPLE) else 0

	return edges


func _get_piece_count(_floor = null)-> int:
	if _floor == null:
		_floor = floor_data

	var piece_count = 0

	for x in _floor:
		piece_count += _floor[x].keys().size()

	return piece_count


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
		floor_data.has(x) and (floor_data[x].has(z-TowerGlobals.TILE_MULTIPLE) or floor_data[x].has(z+TowerGlobals.TILE_MULTIPLE))
	) or (
		floor_data.has(x-TowerGlobals.TILE_MULTIPLE) and floor_data[x-TowerGlobals.TILE_MULTIPLE].has(z)
	) or (
		floor_data.has(x+TowerGlobals.TILE_MULTIPLE) and floor_data[x+TowerGlobals.TILE_MULTIPLE].has(z)
	)):
		return true

	return false


func _has_floor_piece_at(x: int, z: int)-> bool:
	return floor_data.has(x) and floor_data[x].has(z)




