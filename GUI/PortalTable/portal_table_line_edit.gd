extends LineEdit

class_name PortalTableLineEdit

@onready var _format = RegEx.new()
@onready var _previous_text: String = ""
@export var regular_expression: String  = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	_format.compile(regular_expression)
	self.connect("text_changed", _on_text_changed)
	self.focus_exited.connect(_on_focus_exited)



func _on_focus_exited() -> void:
	if not _format.search(self.text):
		self.text = "";
	
func _on_text_changed(new_text):
	var caret_pos = self.caret_column 
	self.text = new_text.to_upper()
	self.caret_column  = caret_pos
	_previous_text = self.text
