extends Connection

class_name PortalConnection


@export var particles_distance: float = 10.0

var _animationDelete = "PortalConnection_Delete"

func _ready() -> void:
	super()
	
	var point1 = points[0]
	var point2 = points[1]

	$Particles1.position = point1 + particles_distance * point1.direction_to(point2)
	$Particles2.position = point2 + particles_distance * point2.direction_to(point1)

	$Particles1.rotation = point1.angle_to_point(point2)
	$Particles2.rotation = point2.angle_to_point(point1)



func delete_connection() -> void:
	$AnimationPlayer.play(_animationDelete)
	await $AnimationPlayer.animation_finished
	self.queue_free()



# func _process(delta: float) -> void:
# 	pass
