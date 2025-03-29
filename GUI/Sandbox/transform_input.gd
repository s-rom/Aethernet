extends Control

class_name TransformInput

signal rotated()
signal start_moving()
signal stop_moving()
signal deleted()

@onready var camera2D: Camera2D = get_viewport().get_camera_2d()

var position_target: Node2D = null
var rotation_target: Node2D = null
var input_position: Node2D = null:
	set(value):
		input_position = value
		_offset = input_position.position
	
var _offset: Vector2 = Vector2.ZERO

var _rotating = false
var _moving = false

func _ready() -> void:
	var sandbox_manager: SandboxManager = get_tree().current_scene.find_child("SandboxManager", true, false)
	if sandbox_manager:
		print("Sandbox manager found: is_locked = " + str(sandbox_manager.is_locked()))
		if sandbox_manager.is_locked():
			call_deferred("hide")


### VisualizationLowPrio group methods
func reduce_visibility() -> void:
	self.modulate.a = 0.35

func reset_visibility() -> void:
	self.modulate.a = 1.0

func _process(_delta: float) -> void:
	if not input_position:
		return

	var screenPos = camera2D.get_screen_transform() * position_target.global_position\
					+ _offset * camera2D.zoom
	screenPos -= camera2D.get_screen_center_position() * camera2D.zoom
	self.set_position(screenPos)
	self.scale = Vector2(0.3, 0.3) *  camera2D.zoom
	
		


func _on_move_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed()\
		and event.button_index == MOUSE_BUTTON_LEFT:
		_moving = true
		start_moving.emit()
	
	if event is InputEventMouseButton and event.is_released()\
		and event.button_index == MOUSE_BUTTON_LEFT:
		_moving = false
		stop_moving.emit()


	if event is InputEventMouseMotion and _moving:
		position_target.global_position += event.screen_relative
		rotated.emit()


func _on_rotate_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed()\
		and event.button_index == MOUSE_BUTTON_LEFT:
		_rotating = true
	
	if event is InputEventMouseButton and event.is_released()\
		and event.button_index == MOUSE_BUTTON_LEFT:
		_rotating = false
	
	if event is InputEventMouseMotion and _rotating:
		rotation_target.rotate(event.screen_relative.x * 0.005)
		rotated.emit()


func _on_delete_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed()\
		and event.button_index == MOUSE_BUTTON_LEFT:
		deleted.emit()
