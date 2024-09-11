extends Node


class_name PortHighlighter

var _highlightTween: Tween
@export var portSprite: Sprite2D
var _originalModulate: Color
@export var highlightColor: Color = Color("f4a972e1")
@export var seconds: float = 0.55
@export var selfModulate: bool = false
@export var _portComponent: PortComponent = null

func _ready():
	
	# Find PortComponent sibling to check linked status
	# If linked, won't highlight
	# Planet element must be setted _portComponent manually!!!
	# Check if _portComponent is setted manually
	if not _portComponent:
		_portComponent = get_parent().find_child("PortComponent") as PortComponent
	
	self.add_to_group("ClickHighlight", true)
	
	if not portSprite and self.get_parent() is Sprite2D:
		portSprite = self.get_parent() as Sprite2D
	
	var attribute = "self_modulate" if selfModulate else "modulate"
	
	if portSprite:
		_originalModulate = portSprite.get(attribute)
	
	_highlightTween = create_tween().set_loops()
	_highlightTween.set_ease(Tween.EASE_IN_OUT)
	_highlightTween.set_trans(Tween.TRANS_QUAD)
	
	_highlightTween.tween_property(portSprite, attribute, highlightColor, seconds)
	_highlightTween.tween_property(portSprite, attribute, _originalModulate, seconds)
	
	_highlightTween.stop()

func set_highlighted():	
	
	# Check for portals and stations 
	# (if the port is linked it won't highlight)
	if _portComponent and _portComponent.is_linked():
		return
	
	if not _highlightTween.is_running():
		_highlightTween.play()
	
func disable_highlight():
	if _highlightTween.is_running():
		_highlightTween.stop()


	var attribute = "self_modulate" if selfModulate else "modulate"
	portSprite.set(attribute, _originalModulate)

	
