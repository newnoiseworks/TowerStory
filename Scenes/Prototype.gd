extends Spatial

var tower_data = [ # top level tower
	[ # first indent level first story -- towers should always be ascending, no floating floors
		{
			22: { # first story x (tile)
				33: { # first story y (tile)
					"type": "floor"
				}
			}
		}
	]
]

var mouse_select: Spatial


func _ready():
	mouse_select = find_node("mouse_select")
	pass # Replace with function body.


func _on_floor_input_event(_camera, event, position, _normal, _shape_idx):
	if event is InputEventMouseMotion:
		var mouse_position = position
		mouse_position.y = mouse_select.global_transform.origin.y

		var adjustment = mouse_position - mouse_select.global_transform.origin

		adjustment.x = _closest_multiple_of_two(int(adjustment.x))
		adjustment.z = _closest_multiple_of_two(int(adjustment.z))

		if adjustment != Vector3.ZERO:
			mouse_select.translate_object_local(adjustment)


func _closest_multiple_of_two(x: int):
	if (x % 2 == 0):
		return x

	return x - 1
