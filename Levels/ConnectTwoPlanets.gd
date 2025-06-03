extends Node


func set_planet_coordinates(planet: Planet, coordinates):
	var pc = planet.find_child("PortComponent", true, false) as PortComponent
	pc.coordinates = coordinates


func _ready() -> void:
	var planets =\
		self.get_tree().current_scene.find_children("Planet*", "Planet", true, false)
	
	var i = 1
	for planet in planets:
		set_planet_coordinates(planet, "A" + str(i))
		i += 1

	
