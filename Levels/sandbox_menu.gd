extends Node2D



@onready var _sandbox_level_selection: SandboxLevelSelection = $CanvasLayer/SandboxLevelSelection

func _on_panel_level_create() -> void:
	print("Click on create")
	LevelManager.create_custom_level()
	_sandbox_level_selection.update_items()


 
func _on_panel_level_load(level_path: Variant) -> void:
	pass # Replace with function body.


func _on_panel_level_rename(level_path: Variant, new_name: Variant) -> void:
	pass # Replace with function body.


func _on_sandbox_level_selection_level_delete(level_path: Variant) -> void:
	print("Trying to delete " + level_path)
	LevelManager.delete_level(level_path)
	_sandbox_level_selection.update_items()
