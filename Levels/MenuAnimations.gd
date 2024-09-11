extends Node2D

class_name MenuAnimations

var shipScn = preload("res://Ships/ship.tscn")
var rng = RandomNumberGenerator.new()
@export var shipColor: Color = Color.WHITE
var radius = 1200.0

func _enter_tree():
	var to_remove = get_tree().root.find_children("LineEdit", "", true, false)
	for node in to_remove:
		node.queue_free()
		
	var portal = get_tree().root.find_child("Portal", true, false)
	if portal:
		var circle = portal.find_child("HighlightCircle", true, false)
		if circle:
			circle.queue_free()
			print("Remove hightlight circle on portal")

func _ready():
	
	for i in 6:
		spawnShip()
	
	while true:
		await get_tree().create_timer(0.75).timeout
		spawnShip()
	


func generate_random_point_on_circumference(angle):
	var point: Vector2
	var _viewport = get_viewport_rect()
	point.x = radius * cos(angle) + _viewport.size.x / 2
	point.y = radius * sin(angle) + _viewport.size.y / 2
	return point
	
func get_radius_from_viewport():
	var viewport = get_viewport_rect() as Rect2
	return sqrt(pow(viewport.size.x / 2, 2) + pow(viewport.size.y / 2, 2))
	
func spawnShip():
	
	radius = get_radius_from_viewport()

	var ship = shipScn.instantiate() as Ship
	ship.modulate = shipColor
	ship.z_index = -2

	var originAngle = rng.randf() * PI * 2
	
	var randomAngleDestination = originAngle + deg_to_rad(70 + rng.randf_range(45, 180))
	
	ship.global_position = generate_random_point_on_circumference(originAngle)
	
	var scaleFactor = rng.randf_range(0.2, 0.55)
	var velocity = rng.randf_range(100.0, 225.0)
	
	var goal = generate_random_point_on_circumference(randomAngleDestination) * 3

	ship.scale = Vector2(scaleFactor, scaleFactor)
	
	var shipsLayer = get_tree().root.find_child("ShipsLayer", true, false)
	shipsLayer.add_child(ship)
	ship.set_navigation_goal_based_on_velocity(goal, velocity)
	await ship.goal_reached
	ship.z_index = RenderingServer.CANVAS_ITEM_Z_MIN
	ship.queue_free()

	# compute goal position	
	#ship.global_position.x = rng.

func _process(delta):
	pass
