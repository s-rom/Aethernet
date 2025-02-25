extends Node2D

@onready var line := $Line2D
@onready var object1 = find_child("Port1")  # Primer objeto (Node2D)
@onready var object2 := find_child("Port2")  # Segundo objeto (Node2D)
var curve := Curve2D.new()

var portalMaterial = load("res://FX_Testing/portal_connection.tres")

func _ready():
	line.material = portalMaterial
	update_curve()

func update_curve():

	var P0 = object1.global_position
	var P3 = object2.global_position  

	var direction1 = Vector2.from_angle(object1.rotation - PI) * 200 
	var direction2 = Vector2.from_angle(object2.rotation - PI) * 200 

	var out_handle_P0 = direction1
	var in_handle_P3 = direction2

	curve.clear_points()
	curve.add_point(P0, Vector2.ZERO, out_handle_P0)
	curve.add_point(P3, in_handle_P3, Vector2.ZERO)

	var simplified_points = curve.tessellate(2, 4)
	line.points = simplified_points
