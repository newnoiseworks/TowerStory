extends Spatial

# TODO: double get parent call kind of sucks ass, think about a way around it
# it's trying to access the floor container e.g. "building/floor1/"
onready var floor_container = get_parent().get_parent()

var _small_office_1x2 = preload("res://scenes/room/office/office_1x2.tscn")
var _hover_item: Spatial


func place_hover_item():
	if _hover_item != null:
		_hover_item.set_opaque()
		_hover_item = null


func _ready():
	var _c = TowerGlobals.connect("tool_change", self, "_on_tool_change_pressed")


func _physics_process(_delta):
	if _hover_item != null:
		var origin = floor_container.global_transform.origin
		origin.y = 0
		_hover_item.global_transform.origin = origin + TowerGlobals.get_target_pos()


func _on_tool_change_pressed(user_tool):
	match user_tool:
		TowerGlobals.UI_TOOL.SMALL_OFFICE_1x2:
			_hover_item = _small_office_1x2.instance()
			floor_container.add_child(_hover_item)
			_hover_item.set_transparent()
		TowerGlobals.UI_TOOL.SMALL_OFFICE_2x2:
			pass


