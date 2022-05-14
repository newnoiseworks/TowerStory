extends Spatial

const MULTIPLE = 2

var tower_data = [ # top level tower
	{ # first indent level first story -- towers should always be ascending, no floating floors
		0: { # first story x (tile)
			0: { # first story z (tile)
				"type": "floor"
			}
		}
	}
]

onready var mouse_select: Spatial = find_node("mouse_select")
onready var floor_piece_packed = preload("res://Scenes/bottomFloorPiece.tscn")
onready var floor_data = tower_data[0]


func _ready():
	for x in floor_data:
		for z in floor_data[x]:
			_add_floor_piece_at(global_transform.origin + Vector3(x, 0, z), true)


func _on_floor_input_event(_camera, event, position, _normal, _shape_idx):
	if event is InputEventMouseMotion:
		var mouse_position = position
		mouse_position.y = mouse_select.global_transform.origin.y

		var adjustment = mouse_position - mouse_select.global_transform.origin

		adjustment.x = _closest_multiple_of(int(adjustment.x))
		adjustment.z = _closest_multiple_of(int(adjustment.z))

		if adjustment != Vector3.ZERO:
			mouse_select.translate_object_local(adjustment)

	elif event is InputEventMouseButton and Input.is_action_pressed("ui_accept"):
		var global_target = mouse_select.global_transform.origin

		global_target.y = 0

		_add_floor_piece_at(global_target)


func _add_floor_piece_at(global_target: Vector3, startup: bool = false):
	var target = global_transform.origin + global_target

	var x = int(target.x)
	var z = int(target.z)

	if !startup and !_can_add_floor_piece_at(x, z): 
		return

	if !floor_data.has(x): floor_data[x] = {}

	floor_data[x][z] = { "type": "floor" }

	var floor_piece = floor_piece_packed.instance()

	add_child(floor_piece)

	floor_piece.global_transform.origin = target


func _can_add_floor_piece_at(x: int, z: int)-> bool:
	if floor_data.has(x) and floor_data[x].has(z):
		print_debug("Can't place a tile where one already exists")
		return false

	if ((
		floor_data.has(x) and (floor_data[x].has(z-MULTIPLE) or floor_data[x].has(z+MULTIPLE))
	) or (
		floor_data.has(x-MULTIPLE) and floor_data[x-MULTIPLE].has(z)
	) or (
		floor_data.has(x+MULTIPLE) and floor_data[x+MULTIPLE].has(z)
	)):
		return true

	return false


func _closest_multiple_of(x: int)-> int:
	return _closest_multiple_of_n(x, MULTIPLE)


func _closest_multiple_of_n(x: int, n: int)-> int:
	if (x % n == 0):
		return x

	var val: int = x / n

	return val * n
