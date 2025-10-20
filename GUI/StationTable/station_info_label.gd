extends Label

class_name StationInfoLabel


@onready var camera2D: Camera2D = get_viewport().get_camera_2d()

var position_target: Node2D = null:
	set(value):
		position_target = value
		position_target.tree_exited.connect(func(): self.queue_free())
		


var _camera_scale_adjustment = Vector2(0.3, 0.3)
var _offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	hide()
	var tween = self.create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", _get_scale_from_camera() * Vector2(1.24, 1.24), 0.25)
	tween.tween_property(self, "scale", _get_scale_from_camera(), 0.25)


	var sandbox_manager: SandboxManager = get_tree().current_scene.find_child("SandboxManager", true, false)
	if sandbox_manager:
		if sandbox_manager.is_showing_station_info():
			call_deferred("show")
		else:
			call_deferred("hide")

### VisualizationLowPrio group methods
func reduce_visibility() -> void:
	self.modulate.a = 0.35

func reset_visibility() -> void:
	self.modulate.a = 1.0

func _get_scale_from_camera() -> Vector2:
	return _camera_scale_adjustment * camera2D.zoom


func _process(_delta: float) -> void:
	if not position_target: 
		return
	var screenPos = camera2D.get_screen_transform() * position_target.global_position\
					+ _offset * camera2D.zoom
	screenPos -= camera2D.get_screen_center_position() * camera2D.zoom
	self.set_position(screenPos)
	self.scale = _get_scale_from_camera()
	
