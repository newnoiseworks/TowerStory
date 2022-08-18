extends Spatial

var transparent_material: ShaderMaterial = load("res://transparent_shader_material.tres")
var is_transparent = false

onready var ceiling = find_node("ceiling")

func set_transparent():
	is_transparent = true
	var cube: MeshInstance = find_node("Cube003")
	cube.material_override = transparent_material

	for x in range(4):
		find_node("wall%s" % x).find_node("Cube003").material_override = transparent_material


func set_opaque():
	is_transparent = false
	var cube: MeshInstance = find_node("Cube003")
	cube.material_override = null

	for x in range(4):
		find_node("wall%s" % x).find_node("Cube003").material_override = null


func add_wall_at_edge(x: int):
	find_node("wall%s" % x).show()


func hide_walls():
	for x in range(4):
		find_node("wall%s" % x).hide()


