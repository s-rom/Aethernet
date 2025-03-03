extends Node2D

@onready var line := $Line2D
@onready var object1 = find_child("Port1")  # Primer objeto (Node2D)
@onready var object2 := find_child("Port2")  # Segundo objeto (Node2D)
var curve := Curve2D.new()

var portalMaterial = load("res://FX_Testing/portal_connection.tres")
var _availablePortalNetworks = []

func _pop_stack_portal_network() -> Variant:
	
	var length = len(_availablePortalNetworks)
	if length == 0:
		return null
		
	var _back = _availablePortalNetworks[-1]
	_availablePortalNetworks.remove_at(length - 1)	
	return _back


func _push_stack_portal_network(network: String) -> void:
	_availablePortalNetworks.push_back(network)

func _ready():
	
	# Base characters
	var char_set = ["Z", "X", "Y", "W", "U", "T", "S"]
	for c in char_set:
		_push_stack_portal_network(c)
	
	# All combinations with base characters 
	for c1 in char_set:
		for c2 in char_set:
			if c1 == c2:
				continue
			_push_stack_portal_network(c1 + c2)	
	
	
	for x in range("A".unicode_at(0), "R".unicode_at(0) + 1):
		for y in char_set:
			_push_stack_portal_network(str(char(x))  + y)
	
	_availablePortalNetworks.reverse()
	
	var network = _pop_stack_portal_network()
	while network != null:
		print(network)
		network = _pop_stack_portal_network()
	

	
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
