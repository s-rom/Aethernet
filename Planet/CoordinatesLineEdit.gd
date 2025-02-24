extends LineEdit

var followTarget: Node2D = null
var _format = RegEx.new()
var _text: String 
@onready var camera2D: Camera2D = get_viewport().get_camera_2d()
# Called when the node enters the scene tree for the first time.
func _ready():
	_format.compile("^[a-zA-Z][0-9]{1,2}$")
	_text = ""
	self.connect("text_changed", _on_text_changed)
	self.focus_exited.connect(_on_focus_exited)

func _process(_delta: float):
	if not followTarget:
		return
		
	var screenPos = camera2D.get_screen_transform() * followTarget.global_position
	screenPos -= camera2D.get_screen_center_position() * camera2D.zoom
	self.set_position(screenPos)
	self.scale = camera2D.zoom


func _on_focus_exited() -> void:
	if not _format.search(self.text):
		self.text = "";

func _on_text_changed(new_text):
	var caret_pos = self.caret_column 
	self.text = new_text.to_upper()
	self.caret_column  = caret_pos
