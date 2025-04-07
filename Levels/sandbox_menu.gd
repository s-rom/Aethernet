extends Node2D


@onready var _sandbox_level_selection: SandboxLevelSelection = $CanvasLayer/SandboxLevelSelection
@onready var _delete_dialog: DeleteDialog = $CanvasLayer/DeleteDialog
@onready var _gui_mask: ColorRect = $CanvasLayer/GUIMask
@onready var _rename_dialog: RenameDialog = $CanvasLayer/RenameDialog


func _ready() -> void:
	$ShipsLayer/Container/PortalMainMenu.play_idle()


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
	


func _on_sandbox_level_selection_level_delete(level_path: Variant) -> void:
	print("Trying to delete " + level_path)


	_gui_mask.visible = true	
	_delete_dialog.file_name = level_path
	_delete_dialog.visible = true
	
	var result = await _delete_dialog.resolved
	
	var status = result[0]
	if status == DeleteDialog.Status.CONFIRMED:
		print("Confirm delete")
		LevelManager.delete_level(level_path)
	else:
		print("Cancel delete")
	
	_gui_mask.visible = false	
	_delete_dialog.visible = false
	_sandbox_level_selection.update_items()


func _on_sandbox_level_selection_level_rename(level_path: Variant) -> void:
	var file_name = (level_path as String).replace(".anet", "")

	_gui_mask.visible = true	
	_rename_dialog.file_path = level_path
	_rename_dialog.file_name = file_name
	_rename_dialog.visible = true



func _on_rename_dialog_resolved(status: RenameDialog.Status, old_path: String, new_name: String) -> void:

	if status == RenameDialog.Status.CONFIRMED:
		var status_dict = LevelManager.rename_file(old_path, new_name)
		
		if status_dict["status"]:
			_gui_mask.visible = false
			_rename_dialog.visible = false
			_sandbox_level_selection.update_items()
		else:
			_rename_dialog.log_result(status_dict["message"])
	
	elif status == RenameDialog.Status.CANCELED:
		_gui_mask.visible = false	
		_rename_dialog.visible = false	


func _on_home_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/MainSceneMenu.tscn")
