extends LineEdit


var _format = RegEx.new()
var _text: String 

# Called when the node enters the scene tree for the first time.
func _ready():
	_format.compile("^[a-zA-Z][0-9]{1,2}$")
	_text = ""
	self.connect("text_changed", _on_text_changed)



func _on_text_changed(new_text):
	var caret_pos = self.caret_column 
	self.text = new_text.to_upper()
	self.caret_column  = caret_pos
