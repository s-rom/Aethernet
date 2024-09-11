extends Node2D


var _shipScn =  load("res://Ships/ship.tscn")
var _ship = null

func _test_spawn_ship(from: Vector2):
	var ship = _shipScn.instantiate()
	ship.position = from
	add_child(ship)
	_ship = ship


func _ready():
	_test_spawn_ship(Vector2(300.0, 150.))

func _process(delta):
	var mousePos = get_global_mouse_position()
	var rot = _ship.position.angle_to_point(mousePos)
	_ship.rotation = rot + deg_to_rad(90)
	
	pass
