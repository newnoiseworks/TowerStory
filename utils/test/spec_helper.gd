class_name SpecHelper

static func get_empty_tower_data():
	return {}


static func get_simple_tower_floor(multiple):
	var tower_data_simple_floor = {}

	tower_data_simple_floor[0] = {}
	tower_data_simple_floor[0][0] = {}

	tower_data_simple_floor[0][0][0] = { "type": "floor" }
	tower_data_simple_floor[0][0][multiple] = { "type": "floor" }
	tower_data_simple_floor[0][0][multiple * 2] = { "type": "floor" }

	return tower_data_simple_floor


static func get_simple_square_tower_floor(multiple):
	var tower_data_simple_floor = {}

	tower_data_simple_floor[0] = {}

	for x in range(3):
		tower_data_simple_floor[0][multiple * x] = {}
		
		for z in range(3):
			tower_data_simple_floor[0][multiple * x][multiple * z] = { "type": "floor" }

	return tower_data_simple_floor


