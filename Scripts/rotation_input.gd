extends Node2D


@onready var _rotationInputControlScn = load("res://GUI/Sandbox/TransformInput.tscn")


signal rotated()
signal start_moving()
signal stop_moving()

func _ready() -> void:
	_create_texture_rect()
	pass

func _create_texture_rect() -> void:
	var canvasLayer = get_tree().current_scene.find_child("CanvasLayer", true, false)
	if canvasLayer:
		var rot_input = _rotationInputControlScn.instantiate() as TransformInput

		canvasLayer.add_child(rot_input)
		
		rot_input.position_target = self.get_parent()
		rot_input.follow_target = self
		rot_input.rotation_target = self.get_parent()
		rot_input.rotated.connect(func(): rotated.emit())
		rot_input.start_moving.connect(func(): start_moving.emit())
		rot_input.stop_moving.connect(func(): stop_moving.emit())
