extends Sprite2D
class_name Ship

var _shipData: ShipData

signal goal_reached(ship: Ship)

func _ready():
	pass
	

func set_network_data(shipData: ShipData):
	self._shipData = shipData

func set_navigation_goal(goal: Vector2, seconds: float):
	_navigate_to(goal, seconds)

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
	self.scale = Vector2(0.3, 0.3)
	
	tween.tween_property(self, "scale", originalScale, 1)
	tween.tween_property(self, "position", goal, seconds).set_delay(0.5)
	tween.tween_property(self, "scale", Vector2(0.3, 0.3), 1).set_delay(seconds)
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
