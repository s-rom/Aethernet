extends Camera2D


var _amount_area_ratio
var _base_rect_size


func _ready():
	
	var _base_amount = $CPUParticles2D.amount
	_base_rect_size = $CPUParticles2D.emission_rect_extents as Vector2


		
	var _base_area = _base_rect_size.x * _base_rect_size.y
	_amount_area_ratio = _base_amount / _base_area
	
	print("Original viewport: ", get_viewport_rect())
	print("Original particles amount: ", _base_amount)
	print("Original particles rect: ", _base_rect_size)
	
	get_tree().root.connect("size_changed", _on_window_size_changed)
	
	


func _adjust_particles_to_viewport():
	print("New viewport: ", get_viewport_rect())
	
	$CPUParticles2D.emission_rect_extents = get_viewport_rect().size

	var new_area = get_viewport_rect().get_area()

	var new_amount = _amount_area_ratio * new_area
	print("New amount: ", new_amount)
	$CPUParticles2D.amount = new_amount
	$CPUParticles2D.restart()
	
	

func _on_window_size_changed():
	_adjust_particles_to_viewport()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_item_rect_changed():
	print(self.zoom)

