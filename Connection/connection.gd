extends Line2D

class_name Connection

@export var portalConnectionScn: PackedScene = null

var can_be_deleted = true
var curve: Curve2D = null

@export var highligted: bool = false : 
	set(value):
		if value:
			_highlight()
		else:
			_unhighlight()
		highligted = value


var _hightlightTween: Tween = null
var _originalWidth = self.width
var _originalColor = self.default_color
var _highlightedWidth = self.width + 0.2 * self.width

func _unhighlight():
	self.default_color = _originalColor
	self.width = _originalWidth

func _highlight():
	self.default_color = Color.RED
	self.width = _originalWidth
	
	_hightlightTween = create_tween()
	#tween.connect("finished", _on_goal_reached)
	#self.rotation = position.angle_to_point(goal) + deg_to_rad(90)
	_hightlightTween.set_ease(Tween.EASE_IN_OUT)
	_hightlightTween.set_trans(Tween.TRANS_QUAD)
	_hightlightTween.tween_property(self, "width", _highlightedWidth, 0.1)
	

func _ready():
	for area2D in self.find_children("*", "Area2D"):
		_connect_to_area_signals(area2D)


func _connect_to_area_signals(area2D: Area2D):
	area2D.connect("input_event", _on_area_2d_input_event)
	area2D.connect("mouse_entered", _on_area_2d_mouse_entered)
	area2D.connect("mouse_exited", _on_area_2d_mouse_exited)



func initColliderShape(startGlobalPos: Vector2):
	var collisionShape = self.find_child("CollisionShape2D") as CollisionShape2D
	
	var rectangleShape = RectangleShape2D.new()
	rectangleShape.size = Vector2(20, 20)

	collisionShape.shape = rectangleShape
	$Area2D.global_position = startGlobalPos



func convert_to_portal_connection(port_a: PortComponent, port_b: PortComponent) -> PortalConnection:
	var newConnection = portalConnectionScn.instantiate() as PortalConnection
	newConnection.points = self.points
	newConnection.curve = self.curve
	newConnection.can_be_deleted = self.can_be_deleted
	newConnection.associate_port(port_a)
	newConnection.associate_port(port_b)
	return newConnection;

func update_shape() -> void: 

	var point_a: Vector2 = self.points[0]
	var point_b: Vector2 = self.points[-1]
	

	var length: float = point_b.distance_to(point_a)
	var new_rotation: float = point_a.angle_to_point(point_b)
	
	var collisionShape = self.find_child("CollisionShape2D") as CollisionShape2D
	collisionShape.shape.size = Vector2(length, self.width)
	var area2D = $Area2D as Area2D
	area2D.rotation = new_rotation
	area2D.position = (point_b + point_a) / 2


	#### To skip a few positions between the endpoint and the line
	
	# var skip_distance: float = 30.0
	# var dir_a_b = Vector2.from_angle(point_a.angle_to_point(point_b)) * skip_distance
	# var dir_b_a = Vector2.from_angle(point_b.angle_to_point(point_a)) * skip_distance

	# self.points[0] += dir_a_b
	# self.points[-1] += dir_b_a


func update_curve(rotation1, rotation2) -> void:

	var direction1 = Vector2.from_angle(rotation1)
	var direction2 = Vector2.from_angle(rotation2)

	var angle_between = direction1.angle_to(direction2)
	var angle_diff = abs((abs(angle_between) - PI))
	if angle_diff < deg_to_rad(20):
		return

	var P0 = points[0]
	var P3 = points[-1]  

	self.curve = Curve2D.new()
	var out_handle_P0 = direction1 * 100 * angle_diff 
	var in_handle_P3 = direction2 * 100  * angle_diff

	curve.add_point(P0, Vector2.ZERO, out_handle_P0)
	curve.add_point(P3, in_handle_P3, Vector2.ZERO)

	var simplified_points = curve.get_baked_points()
	self.points = simplified_points


func delete_connection() -> void:
	self.queue_free()

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT):
		if can_be_deleted:
			delete_connection()

func _on_area_2d_mouse_entered():
	self.highligted = true

func _on_area_2d_mouse_exited():
	self.highligted = false
