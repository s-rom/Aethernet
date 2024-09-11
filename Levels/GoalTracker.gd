extends Node


class_name GoalTracker

var _planetStatus = {}

const SUBGOAL_CONNECTED: String = "planets_connected"
const SUBGOAL_COORD: String = "planets_coord"
const SUBGOAL_INTRA: String = "intranet"
const SUBGOAL_INTER: String = "internet"

# Used for level completition
signal goalCompleted()

# Used for individual subgoals in the goal GUI list
signal subGoalCompleted(subGoal, status)

signal testingStarted()
signal testingEnded()

var should_cancel = false


func _ready():
	
	var canvasLayer = get_tree().root.find_child("InLevelGui", true, false)	
	if !canvasLayer:
		canvasLayer = get_tree().root.find_child("CanvasLayer", true, false)
	
	

	
	canvasLayer.connect("playButtonPressed", _on_play_button_pressed)
	canvasLayer.connect("stopButtonPressed", _on_stop_button_pressed)
		
	canvasLayer.add_goal_item("Conecta todos los planetas mediante rutas", SUBGOAL_CONNECTED)
	canvasLayer.add_goal_item("Asigna una coordenada a cada planeta", SUBGOAL_COORD)
	canvasLayer.add_goal_item("Consigue comunicación entre planetas de la misma red", SUBGOAL_INTRA)
	
	
	var portals = get_tree().root.find_children("", "Portal", true, false)
	if len(portals) > 0:
		canvasLayer.add_goal_item("Consigue comunicación entre distintas redes", SUBGOAL_INTER)



func send_test_ship(origin: Planet, destination: Planet):
	var originPort = origin.find_child("PortComponent")
	var destinationPort = destination.find_child("PortComponent")

	var originNet = planet_network._extract_network_from_coordinates(origin.coordinates)
	var destNet = planet_network._extract_network_from_coordinates(destination.coordinates)

	var shipData = ShipData.new()
	shipData.isTestShip = true
	#shipData.isReply = true
	shipData.mustBeRouted = (originNet != destNet)
	shipData.originCoordinates = origin.coordinates
	shipData.destinationCoordinates = destination.coordinates
	
	# just in case...
	if not originPort.is_linked():
		return
		
	var otherPort = originPort.connected_to
	
	if shipData.mustBeRouted and !(otherPort.owner is Station or otherPort.owner is Portal):
		print("Trying to send a ship to another network without a station or router")
		return false
	
	
	originPort.send_ship_to_linked_port(shipData)
	
	var result = await origin.replyReceived
	
	var replyShipData = result[1] as ShipData
	
	if (replyShipData.destinationCoordinates == origin.coordinates and 
		replyShipData.originCoordinates == destination.coordinates):
			return true
	else:
		print("Something weird happening on testing :C")
		return false
	


func _test_network_config(network):
	assert(network is planet_network)
	
	var all_connected  = network.check_all_connected()
	print("Connection status: ", all_connected)
	
	if not all_connected:
		subGoalCompleted.emit(SUBGOAL_CONNECTED, false)
		return false
	else:
		subGoalCompleted.emit(SUBGOAL_CONNECTED, true)
	
	var same_network = network.check_same_network()
	print("Same network: ", same_network)

	if not same_network:
		subGoalCompleted.emit(SUBGOAL_COORD, false)
		return false
	
	return true

func _test_network(network):
	var randomPlanets = network.get_two_random_unique_planets()		
	var status = await send_test_ship(randomPlanets[0], randomPlanets[1])
	return status

func _test_two_networks(network1, network2):
	var planet1 = network1.get_random_planet()
	var planet2 = network2.get_random_planet()
	var status = await send_test_ship(planet1, planet2)
	return status

func cancel_testing():
	should_cancel = true

func _test_goals():
	Engine.time_scale = 2
	print("PLAY BUTTON")
	var networks = get_tree().root.find_children("", "planet_network", true, false)
	
	
	for network in networks:
		var status = _test_network_config(network)
		if not status:
			return false
	
	
	if should_cancel:
		return false
		
	subGoalCompleted.emit(SUBGOAL_CONNECTED, true)
	await get_tree().create_timer(0.5).timeout
	subGoalCompleted.emit(SUBGOAL_COORD, true)
	
	
	
	 #Test send between individual networks
	for network in networks:
		if should_cancel:
			return false
		
		if network.number_of_planets() < 2:
			continue
		
		print("----> Testing network ", network.name)
		var networkStatus = await _test_network(network)
		print(network.name, " status: ", networkStatus)
		
		if not networkStatus:
			return false
	
	subGoalCompleted.emit(self.SUBGOAL_INTRA, true)


	var portals = get_tree().root.find_children("", "Portal", true, false)
	if len(portals) > 0:
		var networkCount = len(networks)
		for idx in range(networkCount):
			for idx2 in range(idx + 1, networkCount):
				if should_cancel:
					return false
				
				print("----> Testing networks: ", idx, " and ", idx2)
				var status = await _test_two_networks(networks[idx], networks[idx2])	
				if not status:
					return
	
	
	subGoalCompleted.emit(self.SUBGOAL_INTER, true)

	await get_tree().create_timer(1.0).timeout

	
	goalCompleted.emit()
	LevelsData.set_current_level_completed()
	return true

func _on_play_button_pressed():
	
	testingStarted.emit()
	
	for station in get_tree().root.find_children("*", "Station", true, false):
		assert(station is Station)
		station.clear_port_table()
	
	print("[GOAL TRACKER] play button pressed, start testing")
	should_cancel = false
	var status = await _test_goals()
	
	should_cancel = false
	if not status:
		print("[GOAL TRACKER] Testing failed")
	
	testingEnded.emit()
	


func _on_stop_button_pressed():
	
	print("[GOAL TRACKER] should stop testing!")
	
	var ships = get_tree().root.find_children("*", "Ship", true, false)
	for ship in ships:
		ship.queue_free()
		
	should_cancel = true
	testingEnded.emit()

func _exit_tree():
	print("Tree exited")
	Engine.time_scale = 1
