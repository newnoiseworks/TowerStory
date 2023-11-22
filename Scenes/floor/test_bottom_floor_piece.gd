extends GutTest

class Test_set_transparent:
	extends GutTest

	var test_piece
	var input

	func before_each():
		var prototype_script = load("res://scenes/floor/bottom_floor_piece.tscn")
		test_piece = prototype_script.instantiate()
		add_child_autofree(test_piece)


	func test_set_transparent():
		assert_null(test_piece.find_child("Cube_003").material_override, "material_override is set to null on the cube itself to begin")

		test_piece.set_transparent()

		assert_eq(test_piece.find_child("Cube_003").material_override, test_piece.transparent_material, "material_override is set to transparent after set_transparent is called")
		assert_eq(test_piece.get_node("wall1/Cube_003").material_override, test_piece.transparent_material, "material_override is set to transparent after set_transparent is called on the walls")


	func test_set_opaque():
		test_set_transparent()

		test_piece.set_opaque()

		assert_null(test_piece.find_child("Cube_003").material_override, "material_override is set to null after set_opaque is called")
		assert_null(test_piece.get_node("wall1/Cube_003").material_override, "material_override is set to null after set_opaque is called on the walls")


	func test_add_wall_at_edge():
		test_piece.add_wall_at_edge(2)

		assert_true(test_piece.find_child("wall2").is_visible(), "wall set to visible after add_wall_at_edge is called")


	func test_hide_walls():
		test_add_wall_at_edge()

		test_piece.hide_walls()

		assert_false(test_piece.find_child("wall2").is_visible(), "wall set to invisible after hide_walls is called")
