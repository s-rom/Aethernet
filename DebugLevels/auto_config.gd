extends Node

@export var sprites: Array[Sprite2D] =  []

func _ready():
	var networks = get_tree().root.find_children("planet_network*", "", true, false)
	for network: planet_network in networks:
		var planets = network.find_children("Planet", "", true, false)
		
		var i = 2
		for planet: Planet in planets:
			planet.coordinates = network.set_network_tooltip + str(i)
			var port_component = planet.find_child("PortComponent", true, false) as PortComponent
			port_component.coordinatesLineEdit.text = planet.coordinates
			
			i += 1


	var rootscript = get_tree().root.get_node("/root/2025Debug") as root_script
	
	
	
	var port = 0
	while port < len(sprites) - 1:
		var port1 = sprites[port]
		var port2 = sprites[port + 1]
		rootscript.create_connection.call_deferred(port1, port2, true)
		port += 2
	
	var portal1 = get_tree().root.find_child("Portal", true, false) as Portal
	var portal2 = get_tree().root.find_child("Portal2", true, false) as Portal
	var portal3 = get_tree().root.find_child("Portal3", true, false) as Portal
	
	portal2.add_rule("C", "Y2")
	portal3.add_rule("B", "Y1")

	var pc = portal2.find_child("Port1", true, false).find_child("PortComponent", true, false) as PortComponent
	pc.coordinates = "B1"
	pc.coordinatesLineEdit.text = "B1"
	
