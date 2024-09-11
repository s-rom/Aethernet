extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _draw():
	draw_dashed_line(Vector2(0., 50.), Vector2(400.0, 0.0), Color.AQUAMARINE, -2, 2, false)
