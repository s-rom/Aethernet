extends PanelContainer

signal send_ship(from: String, to: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_origin(origin):
	find_child("Origin").text = origin

func _on_button_pressed():
	var origin = find_child("Origin").text
	var dst = find_child("Destination").text
	send_ship.emit(origin, dst)
