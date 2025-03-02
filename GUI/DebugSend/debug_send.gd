extends PanelContainer

signal send_ship(from: String, to: String)


func set_origin(origin):
	find_child("Origin").text = origin

func _on_button_pressed():
	var origin = find_child("Origin").text
	var dst = find_child("Destination").text
	send_ship.emit(origin, dst)
