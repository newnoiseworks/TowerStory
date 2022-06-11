extends Spatial

func add_wall_at_edge(x: int):
	find_node("wall%s" % x).show()

func hide_walls():
	for x in range(4):
		find_node("wall%s" % x).hide()

