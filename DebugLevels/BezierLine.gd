extends Node2D

@onready var line := $Line2D
@onready var object1 = find_child("Port1")  # Primer objeto (Node2D)
@onready var object2 := find_child("Port2")  # Segundo objeto (Node2D)
var curve := Curve2D.new()

var portalMaterial = load("res://FX_Testing/portal_connection.tres")

func _ready():
	line.material = portalMaterial
	update_curve()


func _process(delta: float) -> void:
	
	if Input.is_key_pressed(KEY_A):
		(object1 as Node2D).global_rotation += (PI * delta)
		queue_redraw()
		
	if Input.is_key_pressed(KEY_D):
		(object2 as Node2D).global_rotation += (PI * delta)
		queue_redraw()
	
	
	var dir1 = Vector2.from_angle(object1.global_rotation - PI)
	var dir2 = Vector2.from_angle(object2.global_rotation - PI)

	update_curve()
	print(rad_to_deg(dir1.angle_to(dir2)), dir1.angle_to(dir2))


func _draw() -> void:
	var pos1 = object1.global_position
	var rot1 = object1.global_rotation
	
	var pos2 = object2.global_position
	var rot2 = object2.global_rotation
	
	var dir1 = Vector2.from_angle(rot1 - PI) * 100
	var dir2 = Vector2.from_angle(rot2 - PI) * 100
	
	draw_line(pos1, dir1 + pos1, Color.RED)
	draw_line(pos2, dir2 + pos2, Color.YELLOW)
	



func update_curve():

	var P0 = object1.global_position
	var P3 = object2.global_position  

	var direction1 = Vector2.from_angle(object1.rotation - PI)
	var direction2 = Vector2.from_angle(object2.rotation - PI)


	var angle_between = direction1.angle_to(direction2)

	if abs((abs(angle_between) - PI)) < deg_to_rad(20):
		print("Recta")


	var out_handle_P0 = direction1  * 200 
	var in_handle_P3 = direction2  * 200 

	curve.clear_points()
	curve.add_point(P0, Vector2.ZERO, out_handle_P0)
	curve.add_point(P3, in_handle_P3, Vector2.ZERO)

	var simplified_points = curve.get_baked_points() # curve.tessellate(2, 4)
	line.points = simplified_points
