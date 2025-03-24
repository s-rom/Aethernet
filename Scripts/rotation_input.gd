extends Node2D


@onready var _rotationInputControlScn = load("res://GUI/Sandbox/TransformInput.tscn")

var _buttons_instance = null

signal rotated()
signal start_moving()
signal stop_moving()

func _ready() -> void:
	_create_texture_rect()
	pass

func _create_texture_rect() -> void:
	var canvasLayer = get_tree().current_scene.find_child("CanvasLayer", true, false)
	if canvasLayer:
		_buttons_instance = _rotationInputControlScn.instantiate() as TransformInput

		canvasLayer.add_child(_buttons_instance)
		
		_buttons_instance.position_target = self.get_parent()
		_buttons_instance.follow_target = self
		_buttons_instance.rotation_target = self.get_parent()
		_buttons_instance.rotated.connect(func(): rotated.emit())
		_buttons_instance.start_moving.connect(func(): start_moving.emit())
		_buttons_instance.stop_moving.connect(func(): stop_moving.emit())

func _exit_tree():
	if _buttons_instance:
		_buttons_instance.queue_free()
