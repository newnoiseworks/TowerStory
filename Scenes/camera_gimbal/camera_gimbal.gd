extends Spatial

export(float) var camera_gimbal_speed = 0.135
export(float) var inner_gimbal_rotate_speed = 0.0035
export(float) var rotate_speed = 0.035
export(float) var camera_gimbal_floor_change_speed = 0.2
export(float) var camera_zoom_speed = 0.3
export(int) var camera_y_diff_per_floor = 1
export(int) var camera_zoom_tick = 1

const X_AXIS = Vector3(1, 0, 0)
const Y_AXIS = Vector3(0, 1, 0)

var inputter = Input

onready var camera_gimbal_transform = self.get_transform()
onready var target_y: int = self.get_translation().y
onready var y_offset: int = self.get_translation().y
onready var camera = find_node("Camera")
onready var camera_transform = camera.get_transform()
onready var inner_gimbal = find_node("inner_gimbal")
onready var inner_gimbal_transform = inner_gimbal.get_transform()
onready var target_zoom = camera.get_translation().z

# Pass a mock input object for testing
func _set_input(input):
	inputter = input


func change_floor(target_floor):
	target_y = (target_floor - 1 * camera_y_diff_per_floor) + y_offset


func _unhandled_input(event):
	if event.is_action_just_released("zoom_in"):
		target_zoom -= camera_zoom_tick

	if event.is_action_just_released("zoom_out"):
		target_zoom += camera_zoom_tick

	if event is InputEventMouseMotion and event.is_action_pressed("third_button"):
		inner_gimbal.rotate_x(PI * event.relative.y * inner_gimbal_rotate_speed)


func _physics_process(_delta):
	_physics_process_camera()
	_physics_process_camera_gimbal()


func _physics_process_camera():
	var zdiff = abs(abs(camera_transform.origin.z) - abs(target_zoom))

	if (camera_transform.origin.z != target_zoom):
		if (zdiff < camera_zoom_speed):
			camera_transform.origin.z = target_zoom
		else:
			if (camera_transform.origin.z < target_zoom):
				camera_transform.origin += camera.get_transform().basis.z * camera_zoom_speed
			else:
				camera_transform.origin += -camera.get_transform().basis.z * camera_zoom_speed

	camera.set_transform(camera_transform)


func _physics_process_camera_gimbal():
	var ydiff = abs(abs(camera_gimbal_transform.origin.y) - abs(target_y))

	if (camera_gimbal_transform.origin.y != target_y):
		if (ydiff < 0.001):
			camera_gimbal_transform.origin.y = target_y
		else:
			if (camera_gimbal_transform.origin.y < target_y):
				camera_gimbal_transform.origin += self.get_transform().basis.y * camera_gimbal_floor_change_speed 
			else:
				camera_gimbal_transform.origin += -self.get_transform().basis.y * camera_gimbal_floor_change_speed

	if (inputter.is_action_pressed("move_forward")):
		camera_gimbal_transform.origin += -self.get_transform().basis.z * camera_gimbal_speed

	if (inputter.is_action_pressed("move_backward")):
		camera_gimbal_transform.origin += self.get_transform().basis.z * camera_gimbal_speed

	if (inputter.is_action_pressed("move_left")):
		camera_gimbal_transform.origin += -self.get_transform().basis.x * camera_gimbal_speed

	if (inputter.is_action_pressed("move_right")):
		camera_gimbal_transform.origin += self.get_transform().basis.x * camera_gimbal_speed

	if (inputter.is_action_pressed("rotate_left")):
		camera_gimbal_transform = camera_gimbal_transform * Transform(Quat(Y_AXIS, -rotate_speed))

	if (inputter.is_action_pressed("rotate_right")):
		camera_gimbal_transform = camera_gimbal_transform * Transform(Quat(Y_AXIS, rotate_speed))

	self.set_transform(camera_gimbal_transform)


