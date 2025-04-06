extends LineEdit

class_name CoordinatesLineEdit

@onready var followTarget: Node2D = null
@onready var _format = RegEx.new()
@onready var _previous_text: String = ""
@onready var camera2D: Camera2D = get_viewport().get_camera_2d()

@onready var original_scale = self.scale

signal coordinates_changed(new_coord)

# Called when the node enters the scene tree for the first time.
func _ready():
	_format.compile("^[a-zA-Z][0-9]{1,2}$")
	self.connect("text_changed", _on_text_changed)
	self.focus_exited.connect(_on_focus_exited)


func reduce_visibility() -> void:
	self.modulate.a = 0.35

func reset_visibility() -> void:
	self.modulate.a = 1.0


func _process(_delta: float):
	if not followTarget:
		return
		
	var screenPos = camera2D.get_screen_transform() * followTarget.global_position
	screenPos -= camera2D.get_screen_center_position() * camera2D.zoom
	self.set_position(screenPos)
	self.scale = original_scale *  camera2D.zoom


func _on_focus_exited() -> void:
	if not _format.search(self.text):
		self.text = "";
	
	if _previous_text != self.text:
		coordinates_changed.emit(self.text)


func _on_text_changed(new_text):
	var caret_pos = self.caret_column 
	self.text = new_text.to_upper()
	self.caret_column  = caret_pos

	if _format.search(self.text) and _previous_text != self.text:
		coordinates_changed.emit(self.text)

	_previous_text = self.text
