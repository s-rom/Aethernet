extends Node2D


@onready var _rotationInputControlScn = load("res://GUI/Sandbox/TransformInput.tscn")

var _buttons_instance = null
var _dragging = false

func _ready() -> void:
	_create_texture_rect()
	

#$SpawnInputButtons.connect("rotated", _update_all_connections)
#$SpawnInputButtons.connect("start_moving", func(): _dragging = true)
#$SpawnInputButtons.connect("stop_moving", func(): _dragging = false)


func _process(_delta: float):
	if _dragging:
		_update_all_connections()



func _update_all_connections() -> void:
	var ports = owner.find_children("PortComponent*", "PortComponent", true, false)
	for port: PortComponent in ports:
		var connection = port._connection
		if connection: # and connection is PortalConnection:
			if connection is PortalConnection:
				connection.update_curve()	
			else:
				connection.update_shape()

func _create_texture_rect() -> void:
	var canvasLayer = get_tree().current_scene.find_child("CanvasLayer", true, false)
	if canvasLayer:
		_buttons_instance = _rotationInputControlScn.instantiate() as TransformInput

		canvasLayer.add_child(_buttons_instance)
		
		_buttons_instance.position_target = self.get_parent()
		_buttons_instance.input_position = self
		_buttons_instance.rotation_target = self.get_parent()
		
		_buttons_instance.rotated.connect(func(): _update_all_connections())
		_buttons_instance.start_moving.connect(func(): _dragging = true)
		_buttons_instance.stop_moving.connect(func(): _dragging = false)
		_buttons_instance.deleted.connect(func(): self.owner.queue_free())

func _exit_tree():
	if _buttons_instance:
		_buttons_instance.queue_free()
