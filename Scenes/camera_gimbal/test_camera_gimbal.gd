extends GutTest

class Test__physics_process:
	extends GutTest

	class MockInput:
		var _pressed = []

		func press(key):
			_pressed.append(key)

		func release(key):
			_pressed.remove(key)

		func is_action_pressed(a):
			return a in _pressed	

	var double_script
	var _input


	func before_each():
		var prototype_script = load("res://scenes/camera_gimbal/camera_gimbal.gd")
		double_script = prototype_script.new()
		add_child_autofree(double_script)

		_input = MockInput.new()
		double_script._set_input(_input)


	func test__move_forward():
		var init_position_z = double_script.get_translation().z
		_input.press("move_forward")
		gut.simulate(double_script, 200, 1)
		assert_lt(double_script.get_translation().z, init_position_z, "Can move forward")


	func test__move_backward():
		var init_position_z = double_script.get_translation().z
		_input.press("move_backward")
		gut.simulate(double_script, 200, 1)
		assert_gt(double_script.get_translation().z, init_position_z, "Can move backward")


	func test__move_left():
		var init_position_x = double_script.get_translation().x
		_input.press("move_left")
		gut.simulate(double_script, 200, 1)
		assert_lt(double_script.get_translation().x, init_position_x, "Can move left")


	func test__move_right():
		var init_position_x = double_script.get_translation().x
		_input.press("move_right")
		gut.simulate(double_script, 200, 1)
		assert_gt(double_script.get_translation().x, init_position_x, "Can move right")




	func test__rotate_left():
		var init_rotate = double_script.get_rotation_degrees().y
		_input.press("rotate_left")
		gut.simulate(double_script, 200, 1)
		assert_lt(double_script.get_rotation_degrees().y, init_rotate, "Can rotate left")


	func test__rotate_right():
		var init_rotate = double_script.get_rotation_degrees().y
		_input.press("rotate_right")
		gut.simulate(double_script, 200, 1)
		assert_gt(double_script.get_rotation_degrees().y, init_rotate, "Can rotate right")




class Test_change_floor:
	extends GutTest

	var double_script


	func before_each():
		var prototype_script = load("res://scenes/camera_gimbal/camera_gimbal.gd")
		double_script = prototype_script.new()
		add_child_autofree(double_script)


	func test__move_up_a_floor():
		var init_position_y = double_script.get_translation().y

		double_script.change_floor(2)
		gut.simulate(double_script, 200, 1)

		assert_gt(double_script.get_translation().y, init_position_y, "Moves up a floor")


	func test__move_down_a_floor():
		var init_position_y = double_script.get_translation().y

		double_script.change_floor(0)
		gut.simulate(double_script, 200, 1)

		assert_lt(double_script.get_translation().y, init_position_y, "Moves down a floor")


