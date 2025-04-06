extends Control


class_name SandboxLevelSelection

@onready var levels_container = $VBoxContainer/ScrollContainer/GridContainer

var level_item_scene: PackedScene = load("res://SandboxMode/Gui/LevelLoader/LevelItem.tscn")

var _selected_level: LevelItem = null


signal level_delete(level_path)
signal level_create()
signal level_load(level_path)
signal level_rename(level_path)


func _ready() -> void:
	update_items()


func update_items():
	_selected_level = null
	
	for node in levels_container.get_children(true):
		node.queue_free()
		levels_container.remove_child(node)
		
	for path in LevelManager.get_custom_level_paths():
		var level_item = level_item_scene.instantiate() as LevelItem
		levels_container.add_child(level_item)		
		level_item.level_name = path.split(".")[0]
		level_item.level_path = path
		level_item.level_item_clicked.connect(_on_level_item_clicked)



func _on_level_item_clicked(level_item: LevelItem) -> void:
	
	print("Click on " + level_item.level_name)
	
	if _selected_level:
		_selected_level.selected = false
	
	_selected_level = level_item
	level_item.selected = true


func clear_levels() -> void:
	for child in levels_container.get_children(true):
		levels_container.remove_child(child)


func _on_new_pressed() -> void:
	level_create.emit()
	
		
func _on_rename_pressed() -> void:
	if not _selected_level:
		return
	
	level_rename.emit(_selected_level.level_path)
	print("rename pressed")


func _on_delete_pressed() -> void:
	if not _selected_level:
		return
	
	print("Click on delete " + _selected_level.level_path)
	level_delete.emit(_selected_level.level_path)


func _on_load_pressed() -> void:
	if not _selected_level:
		return
	
	level_load.emit(_selected_level.level_path)
