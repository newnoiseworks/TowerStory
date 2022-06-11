extends Spatial

onready var first_floor = find_node("floor")

func _ready():
	first_floor.draw_floor()
