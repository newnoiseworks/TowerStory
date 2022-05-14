extends Spatial

var towerDataExampleStructure = [ # top level tower
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

var mouseSelect: Spatial


func _ready():
	mouseSelect = find_node("mouseSelect")
	pass # Replace with function body.


func _on_Floor_input_event(_camera, event, position, _normal, _shape_idx):
	if event is InputEventMouseMotion:
		var mouse_position = position
		mouse_position.y = mouseSelect.global_transform.origin.y

		var target = mouse_position - mouseSelect.global_transform.origin

		target.x = _closest_multiple_of_two(int(target.x))
		target.z = _closest_multiple_of_two(int(target.z))

		if target != Vector3.ZERO:
			print(target)
			mouseSelect.translate_object_local(target)


func _closest_multiple_of_two(x: int):
	if (x % 2 == 0):
		return x

	return x - 1
