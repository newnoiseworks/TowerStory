extends GutTest

class Test__physics_process:
	extends GutTest
	var double_script
	var _input


	class MockInput:
		var _pressed = []

		func press(key):
			_pressed.append(key)

		func release(key):
			_pressed.remove(key)

		func is_action_pressed(a):
			return a in _pressed	


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
