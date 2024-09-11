extends Sprite2D


signal portClicked(portParent: Node2D, port: PortComponent)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _input(event):
	if (event is InputEventMouse and event.is_pressed() and
	 	self.get_rect().has_point(to_local(get_global_mouse_position())) and 
		event.button_index == MOUSE_BUTTON_LEFT):
		#print("Click on "+name)
		portClicked.emit(self, $PortComponent)
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
