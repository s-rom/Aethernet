extends Label

class_name StationInfoLabel


@onready var camera2D: Camera2D = get_viewport().get_camera_2d()

var position_target: Node2D = null:
	set(value):
		position_target = value
		position_target.tree_exited.connect(func(): self.queue_free())
		

var _offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	hide()
	var tween = self.create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 1.0)
	tween.tween_property(self, "scale", Vector2(1, 1), 1.0)

	

### VisualizationLowPrio group methods
func reduce_visibility() -> void:
	self.modulate.a = 0.35

func reset_visibility() -> void:
	self.modulate.a = 1.0

func _process(_delta: float) -> void:
	if not position_target: 
		return
	var screenPos = camera2D.get_screen_transform() * position_target.global_position\
					+ _offset * camera2D.zoom
	screenPos -= camera2D.get_screen_center_position() * camera2D.zoom
	self.set_position(screenPos)
	self.scale = Vector2(0.3, 0.3) *  camera2D.zoom
	
