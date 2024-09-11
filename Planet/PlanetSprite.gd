extends Sprite2D


signal onPlanetClick(planet: Sprite2D)

var rotationSpeed = deg_to_rad(RandomNumberGenerator.new().randf_range(5, 10))

# Called when the node enters the scene tree for the first time.
func _ready():
	var rotationSign = RandomNumberGenerator.new().randi_range(0, 1)
	
	var s = RandomNumberGenerator.new().randf_range(0.7, 1.2)
	self.scale = Vector2(s, s)
	rotationSign = 1 if rotationSign == 1 else -1
	rotationSpeed *= rotationSign



func _input(event):
	if (event is InputEventMouse and event.is_pressed() and
	 	self.get_rect().has_point(to_local(get_global_mouse_position())) and 
		event.button_index == MOUSE_BUTTON_LEFT):
		#print("Click on "+name)
		(self.get_parent() as Planet).onPlanetClick.emit(self.get_parent())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	self.rotate(rotationSpeed * delta)
