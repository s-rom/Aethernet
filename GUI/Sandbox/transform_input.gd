extends Control

class_name TransformInput

signal rotated()
signal start_moving()
signal stop_moving()

@onready var camera2D: Camera2D = get_viewport().get_camera_2d()

var position_target: Node2D = null
var rotation_target: Node2D = null
var follow_target: Node2D = null

var _rotating = false
var _moving = false

func _ready() -> void:
	pass



func _process(delta: float) -> void:
	if not follow_target:
		return
	
	var screenPos = camera2D.get_screen_transform() * follow_target.global_position
	screenPos -= camera2D.get_screen_center_position() * camera2D.zoom
	self.set_position(screenPos)
	self.scale = camera2D.zoom
		


func _on_move_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		_moving = true
		start_moving.emit()
	
	if event is InputEventMouseButton and event.is_released():
		_moving = false
		stop_moving.emit()


	if event is InputEventMouseMotion and _moving:
		position_target.global_position += event.screen_relative
		rotated.emit()


func _on_rotate_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		_rotating = true
	
	if event is InputEventMouseButton and event.is_released():
		_rotating = false
	
	if event is InputEventMouseMotion and _rotating:
		rotation_target.rotate(event.screen_relative.x * 0.005)
		rotated.emit()
