extends Sprite2D
class_name Ship

var _shipData: ShipData
var _path2D: Path2D

signal goal_reached(ship: Ship)

func _ready():
	pass
	

func set_network_data(shipData: ShipData):
	self._shipData = shipData

func set_navigation_goal(goal: Vector2, seconds: float):
	_navigate_to(goal, seconds)




func set_navigation_curve(curve: Curve2D, seconds: float, reversed: bool = false):
	# Arreglar rotation de la nave
	# Cambiar animacion
	# Activar animacion de envio en la conexion
	# Determinar el sentido de la curva	
	
	var path = Path2D.new()
	path.curve = curve
	_path2D = path
	
	var path_follow = PathFollow2D.new()
	path.add_child(path_follow)
	
	get_tree().current_scene.add_child(path)
	self.reparent(path_follow)
	
	self.rotation_degrees = 90
	var progress_ratio_end = 1.0
	path_follow.loop = false
	
	if reversed:
		path_follow.progress_ratio = 1.0
		self.rotation_degrees *= -1
		progress_ratio_end = 0.0


	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	self.modulate.a = 0.1
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(path_follow, "progress_ratio",\
		progress_ratio_end, seconds).set_delay(0.1)
	tween.tween_property(self, "modulate:a", 0.1, 0.3).set_delay(seconds)
	tween.connect("finished", _on_goal_reached)
	

func set_navigation_goal_based_on_velocity(goal: Vector2, velocity: float):
	#print(self.global_position.distance_to(goal))
	var seconds = self.global_position.distance_to(goal) / velocity
	#print("Navigation will take ", seconds, "s")
	_navigate_to(goal, seconds)


func _navigate_to(goal: Vector2, seconds: float):
	self.rotation = self.global_position.angle_to_point(goal)  + deg_to_rad(90)
	
	var tween = create_tween()
	tween.set_parallel(true)
	self.rotation = position.angle_to_point(goal) + deg_to_rad(90)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	
	var originalScale = self.scale
	var reducedScale = Vector2(0.1, 0.1)
	self.scale = reducedScale
	
	tween.tween_property(self, "scale", originalScale, 1)
	tween.tween_property(self, "position", goal, seconds).set_delay(0.3)
	tween.tween_property(self, "scale", reducedScale, 1).set_delay(seconds)
	tween.tween_property(self, "modulate:a", 0.1, 0.5).set_delay(seconds)
	tween.connect("finished", _on_goal_reached)


func _on_goal_reached():
	goal_reached.emit(self)
	#print("[SHIP] Goal reached " + self.name)
	
	if not _shipData:
		return
	
	self._shipData.destinationPort.notify_ship_entered(
		_shipData
	)

	queue_free()
	
	if _path2D:
		_path2D.queue_free()
		_path2D = null 
