extends GutTest

var SpecHelper = preload("res://utils/test/spec_helper.gd")

class Test_get_rotated_side:
	extends GutTest
	var script_double

	func before_each():
		var prototype_script = load("res://tower_globals.gd")
		script_double = prototype_script.new()


	func after_each():
		script_double.free()


	func test_adjusting_for_side_xup():
		assert_eq(
			TowerGlobals.SIDE.XUP,
			script_double.get_rotated_side(
				TowerGlobals.SIDE.XUP,
				TowerGlobals.ROTATION.ZERO
			)
		)

		assert_eq(
			TowerGlobals.SIDE.ZUP,
			script_double.get_rotated_side(
				TowerGlobals.SIDE.XUP,
				TowerGlobals.ROTATION.NINETY
			)
		)

		assert_eq(
			TowerGlobals.SIDE.XDOWN,
			script_double.get_rotated_side(
				TowerGlobals.SIDE.XUP,
				TowerGlobals.ROTATION.ONEEIGHTY
			)
		)

		assert_eq(
			TowerGlobals.SIDE.ZDOWN,
			script_double.get_rotated_side(
				TowerGlobals.SIDE.XUP,
				TowerGlobals.ROTATION.TWOSEVENTY
			)
		)


	func test_adjusting_for_side_zup():
		assert_eq(
			TowerGlobals.SIDE.ZUP,
			script_double.get_rotated_side(
				TowerGlobals.SIDE.ZUP,
				TowerGlobals.ROTATION.ZERO
			)
		)

		assert_eq(
			TowerGlobals.SIDE.XDOWN,
			script_double.get_rotated_side(
				TowerGlobals.SIDE.ZUP,
				TowerGlobals.ROTATION.NINETY
			)
		)

		assert_eq(
			TowerGlobals.SIDE.ZDOWN,
			script_double.get_rotated_side(
				TowerGlobals.SIDE.ZUP,
				TowerGlobals.ROTATION.ONEEIGHTY
			)
		)

		assert_eq(
			TowerGlobals.SIDE.XUP,
			script_double.get_rotated_side(
				TowerGlobals.SIDE.ZUP,
				TowerGlobals.ROTATION.TWOSEVENTY
			)
		)


