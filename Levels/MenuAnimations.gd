extends Node2D

class_name MenuAnimations

var shipScn = preload("res://Ships/ship.tscn")
var rng = RandomNumberGenerator.new()
@export var shipColor: Color = Color.WHITE
@export var seconds_between_spawn = 0.1
@export var initial_ships = 10
@export var tick_quantity = 1.0
@onready var spawn_timer: Timer = $SpawnTimer
@export var min_scale: float = 0.2
@export var max_scale: float = 0.55
@export var min_velocity: float = 100.0
@export var max_velocity: float = 200.0 

var _MAX_SHIPS = 40
var _ship_pool: Array[Ship] = []

func _get_pooled_ship() -> Ship:
	if _ship_pool.size() == 0:
		return null
	
	var ship: Ship = _ship_pool.pop_front()
	ship.visible = true
	return ship

func _return_pooled_ship(ship: Ship) -> void:	
	ship.visible = false
	_ship_pool.push_back(ship)

func _on_spawn_timer_timeout() -> void:
	for i in range(tick_quantity):
		spawnShip()

func _ready():
	
	# Init pool
	var shipsLayer = get_tree().root.find_child("ShipsLayer", true, false)
	for i in range(_MAX_SHIPS):
		var ship = shipScn.instantiate() as Ship
		ship.z_index = -2	
		shipsLayer.add_child(ship)
		ship.visible = false
		_ship_pool.push_back(ship)

		
	for i in initial_ships:
		spawnShip(true)
	
	spawn_timer.wait_time = seconds_between_spawn
	spawn_timer.start()
	


func generate_random_point_on_circumference(angle, radius):
	var point: Vector2
	var _viewport = get_viewport_rect()
	point.x = radius * cos(angle) + _viewport.size.x / 2
	point.y = radius * sin(angle) + _viewport.size.y / 2
	return point
	
func get_radius_from_viewport():
	var viewport = get_viewport_rect() as Rect2
	return sqrt(pow(viewport.size.x / 2, 2) + pow(viewport.size.y / 2, 2))
	
func spawnShip(first_spawn = false):
	
	var radius =  1.5 * get_radius_from_viewport()

	var ship = _get_pooled_ship()
	if not ship:
		return

	var originAngle = rng.randf() * PI * 2
	
	var randomAngleDestination = originAngle + deg_to_rad(70 + rng.randf_range(45, 180))
	
	ship.global_position = generate_random_point_on_circumference(originAngle, radius)
	ship.modulate = shipColor

	var scaleFactor = rng.randf_range(min_scale, max_scale)
	var scale_normalized = (scaleFactor - min_scale) / (max_scale - min_scale)
	var velocity = lerp(min_velocity, max_velocity, scale_normalized)
	
	if (first_spawn):
		velocity = max_velocity * 1.5
		scaleFactor = max_scale
	
	#ship.z_index = RenderingServer.CANVAS_ITEM_Z_MIN
	var goal = generate_random_point_on_circumference(randomAngleDestination, radius * 2)

	ship.scale = Vector2(scaleFactor, scaleFactor)
	ship.set_navigation_goal_based_on_velocity(goal, velocity)
	await ship.goal_reached
	
	_return_pooled_ship(ship)
	
