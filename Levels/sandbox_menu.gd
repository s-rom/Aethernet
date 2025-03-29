extends Node2D


@onready var _sandbox_level_selection: SandboxLevelSelection = $CanvasLayer/SandboxLevelSelection

func _on_panel_level_create() -> void:
	print("Click on create")
	LevelManager.create_custom_level()
	_sandbox_level_selection.update_items()

 
func _load_level(level_path: Variant) -> void:
	SandboxGlobal.current_sandbox_level_path = level_path
	get_tree().change_scene_to_file("res://SandboxMode/SandboxMode.tscn")
		
	#var sandbox_mode_scene: PackedScene = load("res://SandboxMode/SandboxMode.tscn")
	#var sandbox_instance = sandbox_mode_scene.instantiate()
	#var sandbox_manager: SandboxManager = sandbox_instance.find_child("SandboxManager")
	#sandbox_manager.current_file_path = level_path
	#
	#get_tree().current_scene.queue_free()
	#get_tree().root.add_child(sandbox_instance)
	#get_tree().current_scene = sandbox_instance

func _on_panel_level_load(level_path: Variant) -> void:
	call_deferred("_load_level", level_path)
	
func _on_panel_level_rename(level_path: Variant, new_name: Variant) -> void:
	pass # Replace with function body.


func _on_sandbox_level_selection_level_delete(level_path: Variant) -> void:
	print("Trying to delete " + level_path)
	LevelManager.delete_level(level_path)
	_sandbox_level_selection.update_items()
