extends Spatial

export(float) var camera_speed = 0.135
export(float) var rotate_speed = 0.035
export(float) var camera_floor_change_speed = 0.2

const X_AXIS = Vector3(1, 0, 0)
const Y_AXIS = Vector3(0, 1, 0)

var inputter = Input

onready var camera_transform = self.get_transform()
onready var camera_y_diff_per_floor = 1
onready var target_y: int = self.get_translation().y
onready var y_offset: int = self.get_translation().y

# Pass a mock input object for testing
func _set_input(input):
	inputter = input


func change_floor(target_floor):
	target_y = (target_floor - 1 * camera_y_diff_per_floor) + y_offset


func _physics_process(_delta):
	var ydiff = abs(abs(camera_transform.origin.y) - abs(target_y))

	if (camera_transform.origin.y != target_y):
		if (ydiff < 0.001):
			camera_transform.origin.y = target_y
		else:
			if (camera_transform.origin.y < target_y):
				camera_transform.origin += self.get_transform().basis.y * camera_floor_change_speed 
			else:
				camera_transform.origin += -self.get_transform().basis.y * camera_floor_change_speed

	if (inputter.is_action_pressed("move_forward")):
		camera_transform.origin += -self.get_transform().basis.z * camera_speed

	if (inputter.is_action_pressed("move_backward")):
		camera_transform.origin += self.get_transform().basis.z * camera_speed

	if (inputter.is_action_pressed("move_left")):
		camera_transform.origin += -self.get_transform().basis.x * camera_speed

	if (inputter.is_action_pressed("move_right")):
		camera_transform.origin += self.get_transform().basis.x * camera_speed

	if (inputter.is_action_pressed("rotate_left")):
		camera_transform = camera_transform * Transform(Quat(Y_AXIS, -rotate_speed))

	if (inputter.is_action_pressed("rotate_right")):
		camera_transform = camera_transform * Transform(Quat(Y_AXIS, rotate_speed))

	self.set_transform(camera_transform)
