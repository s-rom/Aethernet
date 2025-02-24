extends Connection

class_name PortalConnection


@export var particles_distance: float = 10.0

var _animationDelete = "PortalConnection_Delete"
var _animationCreate = "PortalConnection_Create"
var _animationSend = "PortalConnection_SendShip"

func _ready() -> void:
	super()
	
	var point1 = points[0]
	var point2 = points[1]

	$Particles1.position = point1 + particles_distance * point1.direction_to(point2)
	$Particles2.position = point2 + particles_distance * point2.direction_to(point1)

	$Particles1.rotation = point1.angle_to_point(point2)
	$Particles2.rotation = point2.angle_to_point(point1)


func play_send_animation() -> void:
	$AnimationPlayer.play(_animationSend)


func delete_connection() -> void:
	$AnimationPlayer.play(_animationDelete)
	await $AnimationPlayer.animation_finished
	self.queue_free()


func _enter_tree() -> void:
	$AnimationPlayer.play(_animationCreate)


# func _process(delta: float) -> void:
# 	pass
