extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var input = Vector2()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	input.x = 0
	input.y = 0
	
	if Input.is_key_pressed(KEY_W):
		input.y = -1;
	
	if Input.is_key_pressed(KEY_S):
		input.y = 1;

	if Input.is_key_pressed(KEY_A):
		input.x = -1;
	
	if Input.is_key_pressed(KEY_D):
		input.x = 1;

	input = input.normalized()

var vel = 500;
var dir = 1;

func _physics_process(delta):
	input *= delta * vel;
	position += input;
	rotation += delta;

