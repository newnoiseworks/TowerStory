extends Node

signal tool_change(user_tool)
signal facade_swap

enum ROTATION {
	ZERO, NINETY, ONEEIGHTY, TWOSEVENTY
}

enum UI_TOOL {
	BASE_TILE,
	REMOVE_TILE,
	SMALL_OFFICE_1x2,
	SMALL_OFFICE_2x2,
}

const TILE_MULTIPLE = 2

var current_building


func get_target_pos():
	# if current_building == null:
		# _set_current_buiding()

	# return current_building.get_target_pos()
	return get_tree().get_root().get_node("building").get_target_pos()


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


func _set_current_buiding():
	# if there are more than one "buildings" and there's switching this will get complex
	current_building = get_parent().find_child("building")


