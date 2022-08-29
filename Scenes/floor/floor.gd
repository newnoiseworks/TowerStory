extends Spatial

export var is_base = false
export var floor_idx: int = 1

onready var room_manager = find_node("room_manager")

var floor_piece_packed = preload("res://scenes/floor/bottom_floor_piece.tscn")
var FloorDataDetails = preload("res://utils/floor_data_details.gd")

var floor_data = {}
var building
var is_ceiling_visible = false

var _floor_data_details = FloorDataDetails.new(floor_data, floor_idx)

func draw_floor():
	for x in floor_data:
		for z in floor_data[x]:
			_add_floor_piece_at(get_parent().global_transform.origin + Vector3(x, 0, z), true)

	for x in floor_data:
		for z in floor_data[x]:
			_floor_data_details.add_wall_to_piece_at_edges(x, z)


func set_transparent():
	for x in floor_data:
		for z in floor_data[x]:
			floor_data[x][z]["object"].set_transparent()

	for x in room_manager.room_data:
		for z in room_manager.room_data[x]:
			room_manager.room_data[x][z]["object"].set_transparent()


func set_opaque():
	for x in floor_data:
		for z in floor_data[x]:
			floor_data[x][z]["object"].set_opaque()

	for x in room_manager.room_data:
		for z in room_manager.room_data[x]:
			room_manager.room_data[x][z]["object"].set_opaque()


func show_ceiling():
	is_ceiling_visible = true

	for x in floor_data:
		for z in floor_data[x]:
			floor_data[x][z]["object"].ceiling.show()


func hide_ceiling():
	is_ceiling_visible = false

	for x in floor_data:
		for z in floor_data[x]:
			floor_data[x][z]["object"].ceiling.hide()


func has_floor_piece_at(global_target: Vector3)-> bool:
	var target = get_parent().global_transform.origin + global_target

	var x = int(target.x)
	var z = int(target.z)

	return _floor_data_details.has_floor_piece_at(x, z)


func remove_pieces_as_needed(target, final_target, is_transparent = false):
	return _add_or_remove_pieces_as_needed(target, final_target, is_transparent, true)


func add_pieces_as_needed(target, final_target, is_transparent = false):
	if (building != null and floor_idx > 1 and get_piece_count() == 0):
		var floor_under = building.get_node("floors/floor%s/floor" % [floor_idx - 1])
		if (floor_under != null and !floor_under.has_floor_piece_at(final_target)):
			return

	return _add_or_remove_pieces_as_needed(target, final_target, is_transparent)


func get_piece_count(_floor = null)-> int:
	if _floor == null:
		_floor = floor_data

	return _floor_data_details.get_piece_count(_floor)


func _add_or_remove_pieces_as_needed(target, final_target, is_transparent = false, remove = false):
	if target == final_target:
		if remove:
			_remove_floor_piece_at(target, is_transparent)
		else:
			_add_floor_piece_at(target, false, is_transparent)

		return

	var greaterx = final_target if final_target.x > target.x else target
	var lesserx = target if greaterx == final_target else final_target
	var greaterz = final_target if final_target.z > target.z else target
	var lesserz = target if greaterz == final_target else final_target

	if remove:
		_remove_multiple_pieces(lesserx, greaterx, lesserz, greaterz, is_transparent)
	else:
		_add_multiple_pieces_if_adjacent(lesserx, greaterx, lesserz, greaterz, is_transparent)


func _add_floor_piece_at(global_target: Vector3, force: bool = false, is_transparent=false):
	var target = get_parent().global_transform.origin + global_target

	var x = int(target.x)
	var z = int(target.z)

	if !force and !_floor_data_details.can_add_floor_piece_at(x, z): return

	if !floor_data.has(x): floor_data[x] = {}

	var floor_piece = floor_piece_packed.instance()

	if is_transparent:
		floor_piece.set_transparent()

	floor_data[x][z] = {
		"type": "floor",
		"object": floor_piece,
	}

	get_parent().add_child(floor_piece)

	floor_piece.global_transform.origin = target

	if !force:
		_floor_data_details.add_wall_to_piece_at_edges(x, z)
		_floor_data_details.add_edges_to_surrounding_pieces(x, z)


func _remove_floor_piece_at(global_target: Vector3, only_if_transparent=false):
	var target = get_parent().global_transform.origin + global_target

	var x = int(target.x)
	var z = int(target.z)

	if _floor_data_details.can_remove_floor_piece_at(x, z, only_if_transparent):
		floor_data[x][z]["object"].queue_free()
		floor_data[x].erase(z)

		_floor_data_details.add_edges_to_surrounding_pieces(x, z)


func _add_multiple_pieces_if_adjacent(lesserx, greaterx, lesserz, greaterz, is_transparent=false):
	var has_adjacent_piece = false

	for x in range(lesserx.x, greaterx.x + TowerGlobals.TILE_MULTIPLE, TowerGlobals.TILE_MULTIPLE):
		for z in range(lesserz.z, greaterz.z + TowerGlobals.TILE_MULTIPLE, TowerGlobals.TILE_MULTIPLE):
			if _floor_data_details.can_add_floor_piece_at(x, z):
				has_adjacent_piece = true
				break

		if has_adjacent_piece: break

	if !has_adjacent_piece: return

	return _add_or_remove_multiple_pieces(lesserx, greaterx, lesserz, greaterz, is_transparent)


func _remove_multiple_pieces(lesserx, greaterx, lesserz, greaterz, is_transparent):
	return _add_or_remove_multiple_pieces(lesserx, greaterx, lesserz, greaterz, is_transparent, true)


func _add_or_remove_multiple_pieces(lesserx, greaterx, lesserz, greaterz, is_transparent = false, remove = false):
	for x in range(lesserx.x, greaterx.x + TowerGlobals.TILE_MULTIPLE, TowerGlobals.TILE_MULTIPLE):
		for z in range(lesserz.z, greaterz.z + TowerGlobals.TILE_MULTIPLE, TowerGlobals.TILE_MULTIPLE):
			if _floor_data_details.has_floor_piece_at(x, z):
				if remove:
					_remove_floor_piece_at(Vector3(x, 0, z), is_transparent)
			elif !remove:
				_add_floor_piece_at(Vector3(x, 0, z), true, is_transparent)

	for x in range(lesserx.x, greaterx.x + TowerGlobals.TILE_MULTIPLE, TowerGlobals.TILE_MULTIPLE):
		for z in range(lesserz.z, greaterz.z + TowerGlobals.TILE_MULTIPLE, TowerGlobals.TILE_MULTIPLE):
			if !_floor_data_details.has_floor_piece_at(x, z):
				break

			_floor_data_details.add_wall_to_piece_at_edges(x, z)
			_floor_data_details.add_edges_to_surrounding_pieces(x, z)


