extends Line2D

class_name Connection

var can_be_deleted = true

@export var highligted: bool = false : 
	set(value):
		if value:
			self.default_color = Color.RED
			self.width = _originalWidth
			
				
			_hightlightTween = create_tween()
			#tween.connect("finished", _on_goal_reached)
			#self.rotation = position.angle_to_point(goal) + deg_to_rad(90)
			_hightlightTween.set_ease(Tween.EASE_IN_OUT)
			_hightlightTween.set_trans(Tween.TRANS_QUAD)
			_hightlightTween.tween_property(self, "width", _highlightedWidth, 0.1)
			
		else:
			self.default_color = _originalColor
			self.width = _originalWidth
		highligted = value


var _hightlightTween: Tween = null
var _originalWidth = self.width
var _originalColor = self.default_color
var _highlightedWidth = self.width + 0.2 * self.width

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func change_to_portal_connection():
	self.default_color = Color.WHITE
	self.self_modulate = Color("cfa6e1")
	self.texture = null
	self.width = 16.0
	self._originalWidth = 16.0
	self._highlightedWidth = width * .2 + width
	self._originalColor = self.self_modulate

func initColliderShape(startGlobalPos: Vector2):
	var collisionShape = self.find_child("CollisionShape2D") as CollisionShape2D
	var rectangleShape = RectangleShape2D.new()
	rectangleShape.size = Vector2(20, 20)
	collisionShape.shape = rectangleShape

	var area2D = $Area2D as Area2D
	area2D.global_position = startGlobalPos


func updateShape():

	var length: float = self.points[1].distance_to(self.points[0])
	var rotation: float = self.points[0].angle_to_point(self.points[1])
	
	var collisionShape = self.find_child("CollisionShape2D") as CollisionShape2D
	collisionShape.shape.size = Vector2(length, 20)
	
	var area2D = $Area2D as Area2D
	area2D.rotation = rotation
	area2D.position = (points[1] + points[0]) / 2



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT):
		if can_be_deleted:
			self.queue_free()



func _on_area_2d_mouse_entered():
	self.highligted = true




func _on_area_2d_mouse_exited():
	self.highligted = false
