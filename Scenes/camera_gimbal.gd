extends Spatial

export(float) var camera_speed = 0.135
export(float) var rotate_speed = 0.035

const X_AXIS = Vector3(1, 0, 0)
const Y_AXIS = Vector3(0, 1, 0)

onready var camera_transform = self.get_transform()


func _physics_process(_delta):
	if (Input.is_action_pressed("move_forward")):
		camera_transform.origin += -self.get_transform().basis.z * camera_speed

	if (Input.is_action_pressed("move_backward")):
		camera_transform.origin += self.get_transform().basis.z * camera_speed

	if (Input.is_action_pressed("move_left")):
		camera_transform.origin += -self.get_transform().basis.x * camera_speed

	if (Input.is_action_pressed("move_right")):
		camera_transform.origin += self.get_transform().basis.x * camera_speed

	if (Input.is_action_pressed("move_down")):
		camera_transform.origin += -self.get_transform().basis.y * camera_speed

	if (Input.is_action_pressed("move_up")):
		camera_transform.origin += self.get_transform().basis.y * camera_speed

	if (Input.is_action_pressed("rotate_left")):
		camera_transform = camera_transform * Transform(Quat(Y_AXIS, -rotate_speed))

	if (Input.is_action_pressed("rotate_right")):
		camera_transform = camera_transform * Transform(Quat(Y_AXIS, rotate_speed))

	self.set_transform(camera_transform)
