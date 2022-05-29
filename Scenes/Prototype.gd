extends Spatial

const MULTIPLE = 2

var tower_data = [ # top level tower
	{ # first indent level first story -- towers should always be ascending, no floating floors
		0: { # first story x (tile)
			0: { # first story z (tile)
				"type": "floor",
				# "object": godot object
			}
		}
	}
]

onready var mouse_select: Spatial = find_node("mouse_select")
onready var floor_piece_packed = preload("res://Scenes/bottomFloorPiece.tscn")
onready var floor_data = tower_data[0]

enum SIDE {
	XUP, XDOWN, ZUP, ZDOWN
}


func _ready():
	for x in floor_data:
		for z in floor_data[x]:
			_add_floor_piece_at(global_transform.origin + Vector3(x, 0, z), true)

	for x in floor_data:
		for z in floor_data[x]:
			_add_wall_to_piece_at_edges(x, z)


func _on_floor_input_event(_camera, event, position, _normal, _shape_idx):
	if event is InputEventMouseMotion:
		var mouse_position = position
		mouse_position.y = mouse_select.global_transform.origin.y

		var adjustment = mouse_position - mouse_select.global_transform.origin

		adjustment.x = _closest_multiple_of(int(adjustment.x))
		adjustment.z = _closest_multiple_of(int(adjustment.z))

		if adjustment != Vector3.ZERO:
			mouse_select.translate_object_local(adjustment)

	elif event is InputEventMouseButton:
		var global_target = mouse_select.global_transform.origin
		global_target.y = 0

		if Input.is_action_pressed("main_button"):
			_add_floor_piece_at(global_target)
		elif Input.is_action_pressed("secondary_button"):
			_remove_floor_piece_at(global_target)


func _remove_floor_piece_at(global_target: Vector3):
	var target = global_transform.origin + global_target

	var x = int(target.x)
	var z = int(target.z)

	if _can_remove_floor_piece_at(x, z):
		floor_data[x][z]["object"].queue_free()
		floor_data[x].erase(z)

		_add_edges_to_surrouding_pieces(x, z)


func _can_remove_floor_piece_at(x: int, z:int)-> bool:
	if !_has_floor_piece_at(x, z):
		print_debug("Can't delete a floor piece that doesn't exist")
		return false

	var floor_copy = floor_data.duplicate(true)
	floor_copy[x].erase(z)

	if !_is_floor_contiguous(floor_copy):
		return false

	return true


func _get_pieces_contiguous_to(_floor: Dictionary, x: int, z: int, touched: Dictionary) -> Dictionary:
	touched["%s,%s" % [x, z]] = true

	if _floor[x].has(z-MULTIPLE) && !touched.has("%s,%s" % [x, z-MULTIPLE]):
		touched = _get_pieces_contiguous_to(_floor, x, z-MULTIPLE, touched)

	if _floor[x].has(z+MULTIPLE) && !touched.has("%s,%s" % [x, z+MULTIPLE]):
		touched = _get_pieces_contiguous_to(_floor, x, z+MULTIPLE, touched)

	if _floor.has(x-MULTIPLE) and _floor[x-MULTIPLE].has(z) && !touched.has("%s,%s" % [x-MULTIPLE, z]):
		touched = _get_pieces_contiguous_to(_floor, x-MULTIPLE, z, touched)

	if _floor.has(x+MULTIPLE) and _floor[x+MULTIPLE].has(z) && !touched.has("%s,%s" % [x+MULTIPLE, z]):
		touched = _get_pieces_contiguous_to(_floor, x+MULTIPLE, z, touched)

	return touched


func _is_floor_contiguous(_floor):
	var x = _floor.keys()[0]
	var z = _floor[x].keys()[0]
	var touched = _get_pieces_contiguous_to(_floor, x, z, {}) 
	var count = touched.keys().size()
	return count == _get_piece_count(_floor)


func _get_piece_count(_floor = null)-> int:
	if _floor == null:
		_floor = floor_data

	var piece_count = 0

	for x in _floor:
		piece_count += _floor[x].keys().size()

	return piece_count


func _add_floor_piece_at(global_target: Vector3, startup: bool = false):
	var target = global_transform.origin + global_target

	var x = int(target.x)
	var z = int(target.z)

	if !startup and !_can_add_floor_piece_at(x, z): return

	if !floor_data.has(x): floor_data[x] = {}

	var floor_piece = floor_piece_packed.instance()

	floor_data[x][z] = {
		"type": "floor",
		"object": floor_piece
	}

	add_child(floor_piece)

	floor_piece.global_transform.origin = target

	_add_wall_to_piece_at_edges(x, z)

	if !startup:
		_add_edges_to_surrouding_pieces(x, z)


func _add_edges_to_surrouding_pieces(x: int, z: int):
	var edges = _is_piece_an_edge(x, z)

	if edges[SIDE.XUP] == 0: _add_wall_to_piece_at_edges(x+MULTIPLE, z)
	if edges[SIDE.XDOWN] == 0: _add_wall_to_piece_at_edges(x-MULTIPLE, z)
	if edges[SIDE.ZUP] == 0: _add_wall_to_piece_at_edges(x, z+MULTIPLE)
	if edges[SIDE.ZDOWN] == 0: _add_wall_to_piece_at_edges(x, z-MULTIPLE)


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
		print_debug("Can't place a tile where one already exists")
		return false

	if !_is_connected_at(x, z):
		print_debug("Can't place a tile unconnected to the building")
		return false

	return true


func _is_connected_at(x: int, z: int)-> bool:
	if ((
		floor_data.has(x) and (floor_data[x].has(z-MULTIPLE) or floor_data[x].has(z+MULTIPLE))
	) or (
		floor_data.has(x-MULTIPLE) and floor_data[x-MULTIPLE].has(z)
	) or (
		floor_data.has(x+MULTIPLE) and floor_data[x+MULTIPLE].has(z)
	)):
		return true

	return false


func _has_floor_piece_at(x: int, z: int)-> bool:
	return floor_data.has(x) and floor_data[x].has(z)


func _closest_multiple_of(x: int)-> int:
	return _closest_multiple_of_n(x, MULTIPLE)


func _closest_multiple_of_n(x: int, n: int)-> int:
	if (x % n == 0):
		return x

	var val: int = x / n

	return val * n


func _is_piece_an_edge(x: int, z: int)-> PoolIntArray: 
	var edges: PoolIntArray = [0, 0, 0, 0]

	edges[SIDE.XUP] = 1 if !floor_data.has(x+MULTIPLE) or !floor_data[x+MULTIPLE].has(z) else 0
	edges[SIDE.XDOWN] = 1 if !floor_data.has(x-MULTIPLE) or !floor_data[x-MULTIPLE].has(z) else 0
	edges[SIDE.ZUP] = 1 if !floor_data[x].has(z+MULTIPLE) else 0
	edges[SIDE.ZDOWN] = 1 if !floor_data[x].has(z-MULTIPLE) else 0

	return edges
