extends Node2D


class_name PortalAnimation

var _sprite: Sprite2D
@export var rotationSpeed: float = 1.0


func _ready():

	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
		
	var originalScale = self.scale
	self.scale = Vector2(0.3, 0.3)
	
	
	tween.tween_property(self, "scale", originalScale, 1)



	var parent = self.get_parent()
	
	if parent is Sprite2D:	
		_sprite = parent
	else:
		print("[ERROR] Parent is not Sprite2D")	

func _process(delta):
	_sprite.rotate(delta * rotationSpeed)
	
