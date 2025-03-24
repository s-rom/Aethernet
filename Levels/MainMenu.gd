extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Main menu ready")





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_levels_button_pressed():
	get_tree().change_scene_to_file("res://Levels/LevelSelectionMenu.tscn")


func _on_debug_test() -> void:
	get_tree().change_scene_to_file("res://DebugLevels/2025_debug.tscn")


func _on_sandbox_button_pressed() -> void:
	get_tree().change_scene_to_file("res://SandboxMode/SandboxMode.tscn")
