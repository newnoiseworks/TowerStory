extends Spatial

onready var tiles = find_node("tiles")

func set_transparent():
	for tile in tiles.get_children():
		for x in range(4):
			tile.add_wall_at_edge(x)

		tile.set_transparent()


