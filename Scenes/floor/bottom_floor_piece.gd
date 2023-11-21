extends Node3D

var transparent_material: ShaderMaterial = load("res://transparent_shader_material.tres")
var is_transparent = false

@onready var ceiling = find_child("ceiling")

func set_transparent():
	is_transparent = true
	var cube: MeshInstance3D = find_child("Cube_003")
	cube.set_material_override(transparent_material)

	for x in range(4):
		find_child("wall%s" % x).find_child("Cube_003").set_material_override(transparent_material)


func set_opaque():
	is_transparent = false
	var cube: MeshInstance3D = find_child("Cube_003")
	cube.material_override = null

	for x in range(4):
		find_child("wall%s" % x).find_child("Cube_003").material_override = null


func add_wall_at_edge(x: int):
	var wall = find_child("wall%s" % x)

	if wall != null:
		wall.show()


func hide_wall_at_edge(x: int):
	var wall = find_child("wall%s" % x)

	if wall != null:
		wall.hide()


func hide_walls():
	for x in range(4):
		hide_wall_at_edge(x)


