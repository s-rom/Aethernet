extends Connection

class_name PortalConnection


@export var particles_distance: float = 10.0

var _animationDelete = "PortalConnection_Delete"
var _animationCreate = "PortalConnection_Create"
var _animationSend = "PortalConnection_SendShip"

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
