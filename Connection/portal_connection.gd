class_name PortalConnection extends Connection


@export var particles_distance: float = 10.0

var _animationDelete = "PortalConnection_Delete"
var _animationCreate = "PortalConnection_Create"
var _animationSend = "PortalConnection_SendShip"
var _animationReset = "RESET"
var _animationHighlight = "PortalConnection_Highlight"

var _port_components = []

var _deleting = false
var _creating = false

func _ready() -> void:
	super()
	
	var point1_start = points[0]
	var point1_end = points[1]

	var point2_start = points[-1]
	var point2_end = points[-2]

	$Particles1.position = point1_start + particles_distance * point1_start.direction_to(point1_end)
	$Particles2.position = point2_start + particles_distance * point2_start.direction_to(point1_end)

	$Particles1.rotation = point1_start.angle_to_point(point1_end)
	$Particles2.rotation = point2_start.angle_to_point(point2_end)

	$AnimationPlayer.animation_set_next(_animationSend, _animationReset)

	$AnimationPlayer.play(_animationCreate)
	_creating = true
	await $AnimationPlayer.animation_finished
	_creating = false


func associate_port(port: PortComponent) -> void:
	self._port_components.append(port)

func update_shape() -> void:	

	# hack fix to create update the shape of straight PortalConnection
	if self.curve == null:
		self.curve = Curve2D.new()
		self.curve.add_point(self.points[0], Vector2.ZERO, Vector2.ZERO)
		self.curve.add_point(self.points[-1], Vector2.ZERO, Vector2.ZERO)
		
	var simplified_curve = self.curve.duplicate() as Curve2D
	var simplified_points = simplified_curve.tessellate(1, 4)
	var points_count = len(simplified_points)

	for point_idx in range(points_count - 1):

		var point_a: Vector2 = simplified_points[point_idx]
		var point_b: Vector2 =  simplified_points[point_idx + 1]
		
		var length: float = point_a.distance_to(point_b)
		var new_rotation: float = point_a.angle_to_point(point_b)
		
		var collisionShape = CollisionShape2D.new()
		collisionShape.shape = RectangleShape2D.new()
		collisionShape.shape.size = Vector2(length, self.width)
		
		var area2D = Area2D.new()
		area2D.add_child(collisionShape)
		
		area2D.rotation = new_rotation
		area2D.position = (point_b + point_a) / 2

		self.add_child(area2D)
		_connect_to_area_signals(area2D)

	



func _highlight() -> void:
	if _deleting:
		return

	if $AnimationPlayer.is_playing():
		return

	$AnimationPlayer.play(_animationHighlight)

func _unhighlight() -> void:		
	if _deleting or _creating:
		return
		
	$AnimationPlayer.stop()
	$AnimationPlayer.play(_animationReset)

func play_send_animation() -> void:
	$AnimationPlayer.queue(_animationSend)


func delete_connection() -> void:
	if _creating: 
		return

	_deleting = true
	$AnimationPlayer.play(_animationDelete)
	await $AnimationPlayer.animation_finished
	self.queue_free()


# func _enter_tree() -> void:
# 	$AnimationPlayer.play(_animationCreate)
