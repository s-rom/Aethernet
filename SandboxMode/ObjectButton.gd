extends TextureRect

class_name ObjectButton

@export var object_scene: PackedScene
@export var clone_scene: PackedScene


signal object_clicked(world_object: PackedScene, clone_object: PackedScene)

func _ready() -> void:
	pass



func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			object_clicked.emit(object_scene, clone_scene)
