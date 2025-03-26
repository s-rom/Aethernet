extends PanelContainer

class_name Toolbox


var _buttons = []


var _dragging = false
var _dragging_scene = null
var _dragging_object: Node2D = null

var _camera: Camera2D 

signal object_dropped(object)

func _ready() -> void:
	_buttons = self.find_children("ButtonTexture", "ObjectButton", true, false)
	for button: ObjectButton in _buttons:
		button.object_clicked.connect(_on_object_clicked)
		#button.object_start_dragging.connect(_on_object_start_dragging)
		
		var main_scene = get_tree().current_scene
		if "camera" in main_scene:
			_camera = main_scene.camera

	print("Camera: ", _camera) 
	
func _process(_delta: float) -> void:
	if _dragging and _dragging_object:
				
		var mouse_position = null 
		if _camera:
			mouse_position = _camera.get_global_mouse_position()
		else:
			mouse_position = get_global_mouse_position()	
		(_dragging_object as Node2D).global_position = mouse_position

func _on_object_clicked(scene: PackedScene):
	_dragging = true
	_dragging_scene = scene
	
	# Spawn object
	var main_scene = get_tree().current_scene
	_dragging_object = _dragging_scene.instantiate()
	main_scene.add_child(_dragging_object)
	_dragging_object.owner = main_scene
	for pc: PortComponent in\
				_dragging_object.find_children("*", "PortComponent", true, false):
				pc.hide_line_edit()
	_dragging_object.scale = 0.5 * _dragging_object.scale
	

func _input(event: InputEvent) -> void:

	if _dragging and event is InputEventMouseButton and event.is_released():
		if get_global_rect().has_point(get_viewport().get_mouse_position()):
				print("Cancel drop")
				_dragging_object.queue_free()
				_dragging = false
				_dragging_scene = null
				_dragging_object = null
		else:
			print("Drop")
			object_dropped.emit(_dragging_object)
			_dragging = false
			_dragging_scene = null
			_dragging_object.scale = 2 * _dragging_object.scale
			_dragging_object.find_child("SpawnInputButtons").show_buttons()
			for pc: PortComponent in\
				_dragging_object.find_children("*", "PortComponent", true, false):
				pc.show_line_edit()
			_dragging_object = null
