extends Node

signal tool_change(user_tool)
signal facade_swap

enum UI_TOOL {
	BASE_TILE,
	REMOVE_TILE,
	SMALL_OFFICE_1x2,
	SMALL_OFFICE_2x2,
}

const TILE_MULTIPLE = 2

static func closest_multiple_of(x: int)-> int:
	return _closest_multiple_of_n(
		x,
		TILE_MULTIPLE
	)


static func _closest_multiple_of_n(x: int, n: int)-> int:
	if (x % n == 0):
		return x

	var val: int = x / n

	return val * n
