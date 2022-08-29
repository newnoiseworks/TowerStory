class_name SpecHelper

static func get_empty_tower_data():
	return {}


static func get_simple_tower_data(multiple):
	var tower_data_simple_floor = {}

	tower_data_simple_floor[0] = {}

	tower_data_simple_floor[0][0] = { "type": "floor" }
	tower_data_simple_floor[0][multiple] = { "type": "floor" }
	tower_data_simple_floor[0][multiple * 2] = { "type": "floor" }

	return [tower_data_simple_floor]


static func get_simple_square_tower_data(multiple):
	var tower_data_simple_floor = {}

	tower_data_simple_floor[0] = {}
	tower_data_simple_floor[multiple] = {}
	tower_data_simple_floor[multiple * 2] = {}

	tower_data_simple_floor[0][0] = { "type": "floor" }
	tower_data_simple_floor[0][multiple] = { "type": "floor" }
	tower_data_simple_floor[0][multiple * 2] = { "type": "floor" }

	tower_data_simple_floor[multiple][0] = { "type": "floor" }
	tower_data_simple_floor[multiple][multiple] = { "type": "floor" }
	tower_data_simple_floor[multiple][multiple * 2] = { "type": "floor" }

	tower_data_simple_floor[multiple * 2][0] = { "type": "floor" }
	tower_data_simple_floor[multiple * 2][multiple] = { "type": "floor" }
	tower_data_simple_floor[multiple * 2][multiple * 2] = { "type": "floor" }

	return [tower_data_simple_floor]


