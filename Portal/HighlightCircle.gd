extends Sprite2D

var _highlightTween: Tween
var _originalScale = self.scale


@export var highligted: bool = false : 
	set(value):
		if value:
			self.scale = _originalScale
			_highlightTween.play()
			
		else:
			self.scale = _originalScale
			_highlightTween.stop()
		highligted = value


func _ready():
	_highlightTween = create_tween().set_loops()
	_highlightTween.set_ease(Tween.EASE_IN_OUT)
	_highlightTween.set_trans(Tween.TRANS_QUAD)
	_highlightTween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.5)
	_highlightTween.tween_property(self, "scale", _originalScale, 0.5)



func _process(delta):
	pass
