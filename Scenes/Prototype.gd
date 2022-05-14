extends Spatial

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


func _ready():
	for x in tower_data[0]: # NOTE: 0 should later be controlled by the scene, this should a "floor" scene 
		for z in tower_data[0][x]:
			_add_floor_piece_at(global_transform.origin + Vector3(x, 0, z), true)


func _on_floor_input_event(_camera, event, position, _normal, _shape_idx):
	if event is InputEventMouseMotion:
		var mouse_position = position
		mouse_position.y = mouse_select.global_transform.origin.y

		var adjustment = mouse_position - mouse_select.global_transform.origin

		adjustment.x = _closest_multiple_of_two(int(adjustment.x))
		adjustment.z = _closest_multiple_of_two(int(adjustment.z))

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

	if !startup and tower_data[0].has(x) and tower_data[0][x].has(z):
		return;

	if !tower_data[0].has(x): tower_data[0][x] = {}

	tower_data[0][x][z] = { "type": "floor" }

	var floor_piece = floor_piece_packed.instance()

	add_child(floor_piece)

	floor_piece.global_transform.origin = target


func _closest_multiple_of_two(x: int):
	if (x % 2 == 0):
		return x

	return x - 1
