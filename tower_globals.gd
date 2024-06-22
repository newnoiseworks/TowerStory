extends Node

signal tool_change(user_tool)
signal facade_swap

enum SIDE {
	XUP, ZUP, XDOWN, ZDOWN
}

enum ROTATION {
	ZERO, NINETY, ONEEIGHTY, TWOSEVENTY
}

enum UI_TOOL {
	BASE_TILE,
	REMOVE_TILE,
	SMALL_OFFICE_CORNER,
	SMALL_OFFICE_1x2,
	SMALL_OFFICE_2x2,
	SMALL_OFFICE_2x2x2,
}

const TILE_MULTIPLE = 2

var current_building

func get_rotated_side(side: SIDE, rotation: ROTATION) -> SIDE:
	if rotation == ROTATION.ZERO:
		return side

	return (
		(int(side) + int(rotation)) % ROTATION.size()
	) as SIDE


func get_mouse_target_pos():
	return get_current_building().get_mouse_target_pos()


func get_current_building():
	if current_building == null:
		# if there are more than one "buildings" and there's switching this will get complex
		current_building = get_tree().get_root().get_node("building")

	return current_building


func adjust_position_based_on_room_rotation(
	tile_position: Vector3i,
	room_position: Vector3i,
	rotation: TowerGlobals.ROTATION = TowerGlobals.ROTATION.ZERO
)-> Vector3i:
	var floor_pos_x = room_position.x
	var floor_pos_z = room_position.z

	match rotation:
		TowerGlobals.ROTATION.ZERO:
			floor_pos_x += tile_position.x
			floor_pos_z += tile_position.z
		TowerGlobals.ROTATION.NINETY:
			floor_pos_x += tile_position.z
			floor_pos_z -= tile_position.x
		TowerGlobals.ROTATION.ONEEIGHTY:
			floor_pos_x -= tile_position.x
			floor_pos_z -= tile_position.z
		TowerGlobals.ROTATION.TWOSEVENTY:
			floor_pos_x -= tile_position.z
			floor_pos_z += tile_position.x

	return Vector3i(
		floor_pos_x, tile_position.y, floor_pos_z
	)


func closest_multiple_of(x: int)-> int:
	return _closest_multiple_of_n(
		x,
		TILE_MULTIPLE
	)


func _closest_multiple_of_n(x: int, n: int)-> int:
	if (x % n == 0):
		return x

	var val: int = x / n

	return val * n




