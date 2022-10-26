extends Spatial

# TODO: double get parent call kind of sucks ass, think about a way around it
# it's trying to access the floor container e.g. "building/floor1/"
onready var floor_container = get_parent().get_parent()
# TODO: single get parent call -- also sucks ass in a similar way, see above
onready var floor_obj = get_parent()
onready var floor_data_details = floor_obj.floor_data_details

var room_data = {}

var _small_office_1x2 = preload("res://scenes/room/office/office_1x2.tscn")
var _small_office_2x2 = preload("res://scenes/room/office/office_2x2.tscn")
var _hover_item: Spatial


func place_hover_item():
	if _hover_item != null:
		_hover_item.set_opaque()
		var origin = floor_container.global_transform.origin + _hover_item.global_transform.origin

		if !_can_place_room_at(origin): return

		if !room_data.has(origin.x): room_data[origin.x] = {}

		room_data[origin.x][origin.z] = {
			"type": "room", # TODO: This should map to the "type" of room -- probably an exported string would do well
			"object": _hover_item
		}

		_hover_item = null


func _ready():
	var _c = TowerGlobals.connect("tool_change", self, "_on_tool_change_pressed")


func _physics_process(_delta):
	if _hover_item != null:
		var origin = floor_container.global_transform.origin
		origin.y = 0

		if _hover_item.global_transform.origin != origin + TowerGlobals.get_target_pos():
			_hover_item.global_transform.origin = origin + TowerGlobals.get_target_pos()
			_hover_item.place_walls_where_needed(floor_obj.floor_data_details)


func _on_tool_change_pressed(user_tool):
	match user_tool:
		TowerGlobals.UI_TOOL.SMALL_OFFICE_1x2:
			_hover_item = _small_office_1x2.instance()
			floor_container.add_child(_hover_item)
			_hover_item.set_transparent()
		TowerGlobals.UI_TOOL.SMALL_OFFICE_2x2:
			_hover_item = _small_office_2x2.instance()
			floor_container.add_child(_hover_item)
			_hover_item.set_transparent()


func _can_place_room_at(pos: Vector3) -> bool:
	for tile in _hover_item.tiles.get_children():
		var tile_origin = tile.transform.origin

		if !floor_data_details.has_floor_piece_at(
			pos.x + tile_origin.x,
			pos.z + tile_origin.z
		):
			return false

	return true


