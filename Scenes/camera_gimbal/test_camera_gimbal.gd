extends GutTest

class Test__physics_process:
	extends GutTest

	var camera_instance
	var _input

	func before_each():
		var prototype_script = load("res://scenes/camera_gimbal/camera_gimbal.tscn")
		camera_instance = prototype_script.instantiate()
		add_child_autofree(camera_instance)

		_input = MockInput.new()
		camera_instance._set_input(_input)


	func test__move_forward():
		var init_position_z = camera_instance.get_position().z
		_input.press("move_forward")
		gut.simulate(camera_instance, 200, 1)
		assert_lt(camera_instance.get_position().z, init_position_z, "Can move forward")


	func test__move_backward():
		var init_position_z = camera_instance.get_position().z
		_input.press("move_backward")
		gut.simulate(camera_instance, 200, 1)
		assert_gt(camera_instance.get_position().z, init_position_z, "Can move backward")


	func test__move_left():
		var init_position_x = camera_instance.get_position().x
		_input.press("move_left")
		gut.simulate(camera_instance, 200, 1)
		assert_lt(camera_instance.get_position().x, init_position_x, "Can move left")


	func test__move_right():
		var init_position_x = camera_instance.get_position().x
		_input.press("move_right")
		gut.simulate(camera_instance, 200, 1)
		assert_gt(camera_instance.get_position().x, init_position_x, "Can move right")


	func test__rotate_left():
		var init_rotate = camera_instance.get_rotation_degrees().y
		_input.press("rotate_left")
		gut.simulate(camera_instance, 200, 1)
		assert_lt(camera_instance.get_rotation_degrees().y, init_rotate, "Can rotate left")


	func test__rotate_right():
		var init_rotate = camera_instance.get_rotation_degrees().y
		_input.press("rotate_right")
		gut.simulate(camera_instance, 200, 1)
		assert_gt(camera_instance.get_rotation_degrees().y, init_rotate, "Can rotate right")




class Test_change_floor:
	extends GutTest

	var camera_instance


	func before_each():
		var prototype_script = load("res://scenes/camera_gimbal/camera_gimbal.tscn")
		camera_instance = prototype_script.instantiate()
		add_child_autofree(camera_instance)


	func test__move_up_a_floor():
		var init_position_y = camera_instance.get_position().y

		camera_instance.change_floor(2)
		gut.simulate(camera_instance, 200, 1)

		assert_gt(camera_instance.get_position().y, init_position_y, "Moves up a floor")


	func test__move_down_a_floor():
		var init_position_y = camera_instance.get_position().y

		camera_instance.change_floor(0)
		gut.simulate(camera_instance, 200, 1)

		assert_lt(camera_instance.get_position().y, init_position_y, "Moves down a floor")


class Test__unhandled_input:
	extends GutTest

	var camera_instance
	var input

	func before_each():
		var prototype_script = load("res://scenes/camera_gimbal/camera_gimbal.tscn")
		camera_instance = prototype_script.instantiate()
		add_child_autofree(camera_instance)
		input = MockInput.new()
		camera_instance._set_input(input)


	func test__zoom_in():
		var camera = camera_instance.find_child("Camera3D")
		var init_position_z = camera.get_position().z

		input.release("zoom_in")
		camera_instance._unhandled_input(input)
		gut.simulate(camera_instance, 200, 10)

		assert_lt(camera.get_position().z, init_position_z)


	func test__zoom_out():
		var camera = camera_instance.camera
		var init_position_z = camera.get_position().z

		input.release("zoom_out")
		camera_instance._unhandled_input(input)
		gut.simulate(camera_instance, 200, 10)

		assert_gt(camera.get_position().z, init_position_z)

