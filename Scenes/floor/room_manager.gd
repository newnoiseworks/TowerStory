extends Node3D

# TODO: double get parent call kind of sucks ass, think about a way around it
# it's trying to access the floor container e.g. "building/floor1/"
@onready var floor_container = get_parent().get_parent()
# TODO: single get parent call -- also sucks ass in a similar way, see above
@onready var floor_obj = get_parent()
@onready var floor_data_details = floor_obj.floor_data_details

var room_data = {}

var _small_office_1x2 = preload("res://scenes/room/office/office_1x2.tscn")
var _small_office_2x2 = preload("res://scenes/room/office/office_2x2.tscn")
var _hover_item: Node3D
var _hover_item_rotation = TowerGlobals.ROTATION.ZERO


func place_hover_item():
	if _hover_item != null:
		var origin = floor_container.global_transform.origin + _hover_item.global_transform.origin

		if !_can_place_room_at(origin): return

		_hover_item.set_opaque()

		if !room_data.has(origin.x): room_data[origin.x] = {}

		room_data[origin.x][origin.z] = {
			"type": "room", # TODO: This should map to the "type" of room -- probably an exported string would do well
			"object": _hover_item,
			"rotation": _hover_item_rotation
		}

		_hover_item = null
		_hover_item_rotation = TowerGlobals.ROTATION.ZERO


func _ready():
	TowerGlobals.tool_change.connect(_on_tool_change_pressed)


func _input(event):
	if _hover_item != null:
		if event.is_action_released("rotate_room_right"):
			_rotate_hover_item()
		elif event.is_action_released("rotate_room_left"):
			_rotate_hover_item(true)


func _physics_process(_delta):
	if _hover_item != null:
		var origin = floor_container.global_transform.origin
		origin.y = 0

		if _hover_item.global_transform.origin != origin + TowerGlobals.get_mouse_target_pos():
			_hover_item.global_transform.origin = origin + TowerGlobals.get_mouse_target_pos()
			_hover_item.place_walls_where_needed(floor_obj.floor_data_details, _hover_item_rotation)


func _on_tool_change_pressed(user_tool):
	match user_tool:
		TowerGlobals.UI_TOOL.SMALL_OFFICE_1x2:
			_hover_item = _small_office_1x2.instantiate()
			floor_container.add_child(_hover_item)
			_hover_item.set_transparent()
		TowerGlobals.UI_TOOL.SMALL_OFFICE_2x2:
			_hover_item = _small_office_2x2.instantiate()
			floor_container.add_child(_hover_item)
			_hover_item.set_transparent()


func _can_place_room_at(pos: Vector3) -> bool:
	for tile in _hover_item.tiles.get_children():
		var tile_origin = tile.transform.origin

		var floor_pos = TowerGlobals.adjust_position_based_on_room_rotation(
			tile_origin,
			pos,
			_hover_item_rotation
		)

		if !floor_data_details.has_floor_piece_at(floor_pos.x, floor_pos.z):
			return false

	return true


func _rotate_hover_item(left: bool = false):
	if left:
		_hover_item_rotation = (_hover_item_rotation - 1) as TowerGlobals.ROTATION
	else:
		_hover_item_rotation = (_hover_item_rotation + 1) as TowerGlobals.ROTATION

	if _hover_item_rotation > TowerGlobals.ROTATION.TWOSEVENTY:
		_hover_item_rotation = TowerGlobals.ROTATION.ZERO
	elif _hover_item_rotation < TowerGlobals.ROTATION.ZERO:
		_hover_item_rotation = TowerGlobals.ROTATION.TWOSEVENTY

	print_debug(TowerGlobals.ROTATION.keys()[_hover_item_rotation])

	_hover_item.set_rotation_degrees(Vector3(0, _hover_item_rotation * 90, 0))
	_hover_item.place_walls_where_needed(floor_data_details, _hover_item_rotation)


