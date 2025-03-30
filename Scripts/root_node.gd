
extends Node2D

class_name root_script

@export var cameraSpeed = 25.

var connectionScn = preload("res://Connection/connection.tscn")

@export var debugSender: Control = null
var connectionOrigin = null
var currentConnection: Connection = null
var _availablePortalNetworks = []

@export var camera: MainCamera

var _draggingCamera = false
var _lastMousePosition: Vector2
var _mouseMovement: Vector2

@export var MIN_CAMERA_ZOOM = 0.3
@export var MAX_CAMERA_ZOOM = 2.5


signal camera_zoom_changed()



func _ready():
	
	_init_portal_networks()
	
	var levelSpecific = self.find_child("LevelSpecific")
	if levelSpecific:
		levelSpecific.config(self)
	
	if OS.has_feature("web"):
		$DirectionalLight2D.energy = $DirectionalLight2D.energy / 2.0
		for station in self.find_children("*", "Station", true, false):
			var light = station.find_child("PointLight2D", true, false) as PointLight2D
			light.energy = light.energy / 2.0
		
		for portal in self.find_children("*", "Portal", true, false):
			var portalLight = portal.find_child("PointLight2D", true, false) as PointLight2D
			portalLight.energy = portalLight.energy * 0.4

	
	print("CURRENT LEVEL: ", LevelsData.current_level)
	debugSender = find_child("DebugSend")
	
	$CanvasLayer/DebugSend.connect("send_ship", _on_debug_send_send_ship)
	
	var toolbox = $CanvasLayer.find_child("Toolbox", false, true) as Toolbox
	print(toolbox)
	if toolbox:
		toolbox.object_dropped.connect(_on_object_created)
		toolbox.visible = true
	

	var stations_and_portals = get_tree().get_nodes_in_group("port")
	for port_entity in stations_and_portals:
		port_entity.connect("portClicked", _on_station_port_clicked)
	
	var portals = self.find_children("", "Portal")
	for portal in portals:
		assert(portal is Portal)
		portal.connect("portalClicked", _on_portal_click)
	
	
	var planets = self.find_children("Planet*")
	for planet in planets:
		planet.connect("onPlanetClick", _on_planet_click)	




func _init_portal_networks():

	# Base characters
	var char_set = ["Z", "X", "Y", "W", "U", "T", "S"]
	for c in char_set:
		_push_stack_portal_network(c)
	
	# All combinations with base characters 
	for c1 in char_set:
		for c2 in char_set:
			if c1 == c2:
				continue
			_push_stack_portal_network(c1 + c2)	
	
	
	for x in range("A".unicode_at(0), "R".unicode_at(0) + 1):
		for y in char_set:
			_push_stack_portal_network(str(char(x))  + y)
	
	_availablePortalNetworks.reverse()



func _process(delta: float):
	if currentConnection != null:
		currentConnection.remove_point(1)
		currentConnection.add_point(get_global_mouse_position())
	
	if _draggingCamera:
		$Camera2D.position -= _mouseMovement * delta * cameraSpeed
		_mouseMovement = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:

	## Remove the current connection preview
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT
		and currentConnection != null):
			currentConnection.queue_free()
			currentConnection = null 
			print("Cancel connection")
			get_tree().call_group("VisualizationLowPrio", "reset_visibility")
			get_tree().call_group("ClickHighlight", "disable_highlight")
			connectionOrigin = null
	
	if event.is_action_pressed("toggle_fullscreen"):
		var mode = DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	## Camera zoom
	if event.is_action_pressed("zoom_in"):
		var qty = 0.1 * $Camera2D.zoom.length() # quantiy of zoom = 10% of current zoom
		
		var new_zoom = $Camera2D.zoom + Vector2(qty, qty) as Vector2
		
		if new_zoom.length() <= MAX_CAMERA_ZOOM:
			$Camera2D.zoom = new_zoom
		
		camera_zoom_changed.emit()
	
	if event.is_action_pressed("zoom_out"):
		var qty = 0.1 * $Camera2D.zoom.length() # quantiy of zoom = 10% of current zoom
		var new_zoom = $Camera2D.zoom - Vector2(qty, qty)
		if new_zoom.length() >= MIN_CAMERA_ZOOM:
			$Camera2D.zoom = new_zoom
		
		camera_zoom_changed.emit()
	
	if event.is_action_pressed("ui_cancel"):
		debugSender.visible = false
		self.find_child("PortalTable").visible = false
		for portal in self.find_children("", "Portal"):
			assert(portal is Portal)
			portal.set_hightlight(false)
		get_tree().call_group("ClickHighlight", "disable_highlight")
		get_tree().call_group("VisualizationLowPrio", "reset_visibility")
				
	
			

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_drag_camera"):
		_lastMousePosition = get_global_mouse_position()
		_draggingCamera = true

	if event.is_action_released("ui_drag_camera"):
		_draggingCamera = false

	if _draggingCamera:
		if event is InputEventMouseMotion:
			_mouseMovement  = event.relative


func _on_portal_click(portal: Portal):

	var portalGUI = self.find_child("PortalTable")
	portalGUI.visible = true
	portalGUI.linkPortal(portal)
	
	# print("Click on " + portal.name)
	portal.set_hightlight(true)
	
	var portals = self.find_children("", "Portal")
	for otherPortal in portals:
		assert(portal is Portal)
		
		if otherPortal == portal:
			continue
		
		otherPortal.set_hightlight(false)



func remove_available_network(network: String) -> void:
	var idx = _availablePortalNetworks.find(network)
	if idx == -1:
		return
	_availablePortalNetworks.remove_at(idx)
	

func _pop_stack_portal_network() -> Variant:	
	var length = len(_availablePortalNetworks)
	if length == 0:
		return null
		
	var _back = _availablePortalNetworks[-1]
	_availablePortalNetworks.remove_at(length - 1)	
	return _back

func _push_stack_portal_network(network: String) -> void:
	_availablePortalNetworks.push_back(network)

# both endpoints are the immediate parent of a PortComponent (Sprite2D)
func create_connection(endpoint1, endpoint2, deletable = true, manual = false):
	var new_connection = connectionScn.instantiate()
	
	new_connection.can_be_deleted = deletable
	new_connection.clear_points()
	new_connection.add_point(endpoint1.global_position)
	new_connection.initColliderShape(endpoint2.global_position)
	new_connection.add_point(endpoint2.global_position)
	
	var portA = endpoint1.find_child("PortComponent") as PortComponent
	var portB = endpoint2.find_child("PortComponent") as PortComponent
	
	var parentA = portA.owner
	var parentB = portB.owner
	new_connection.start = endpoint1 
	new_connection.end = endpoint2
	
	if parentA is Portal and parentB is Portal:
		_set_portal_ports_coordinates(portA, portB)
		new_connection.update_curve()
		new_connection = new_connection.convert_to_portal_connection(portA, portB)


		# Only in case this connection is created manually
		# Remove current connection
		if manual and currentConnection != null: 
			currentConnection.queue_free()
			currentConnection = null



	portA.link(portB, new_connection)
	portB.link(portA, new_connection)
	new_connection.update_shape()
	#self.add_child.call_deferred(new_connection)
	self.add_child(new_connection)
	

func _set_portal_ports_coordinates(portA: PortComponent, portB: PortComponent):
	if portA.has_ip and portB.has_ip and planet_network.same_network(portA.coordinates, portB.coordinates):
		return	
	
	var nextPortalNetwork = _pop_stack_portal_network()
	if nextPortalNetwork == null:
		print("[ERROR] No portal networks available")
	else:
		portA.coordinatesLineEdit.text = nextPortalNetwork + "1"
		portB.coordinatesLineEdit.text = nextPortalNetwork + "2"
		portA.coordinates = nextPortalNetwork + "1"
		portB.coordinates = nextPortalNetwork + "2"

func _on_connector_click(connector: Node2D):
	
	# print("Click on ", connector, typeof(connector))
	
	var port = connector.find_child("PortComponent") as PortComponent
	if port.is_linked():
		print("[ERROR] Port is already linked")
		return

	if currentConnection != null and connectionOrigin != null and connector == connectionOrigin:
		print("[ERROR] Cannot connect to the same object") 
		return
	
		
	if currentConnection != null:
		get_tree().call_group("ClickHighlight", "disable_highlight")
		get_tree().call_group("VisualizationLowPrio", "reset_visibility")


		# Remove mouse point
		currentConnection.remove_point(1)
		# Add second connector point
		currentConnection.add_point(connector.global_position)
		create_connection(connector, connectionOrigin, true, true)
		if currentConnection:
			currentConnection.queue_free()
			currentConnection = null
		return
		
	# Create a new connection
	if currentConnection == null:		
		get_tree().call_group("ClickHighlight", "set_highlighted")
		get_tree().call_group("VisualizationLowPrio", "reduce_visibility")
		
		
		connectionOrigin = connector
		currentConnection = connectionScn.instantiate()
		currentConnection.clear_points()
		currentConnection.add_point(connector.global_position)
		currentConnection.add_point(get_global_mouse_position())
		currentConnection.initColliderShape(connector.global_position)
		
		# Create connection collider		
		self.add_child(currentConnection)


func _on_planet_click(planet: Planet):
	# print("Click on " + planet.name)
	
	if planet.is_linked and planet.has_coordinates:
		debugSender.visible = true
	
	# Check if planet is connected and has coordinates
	# Then, display the send GUI element and
	# set the origin as this planet
	var portComp = planet.find_child("PortComponent")
	assert(portComp is PortComponent)
	if portComp and portComp.is_linked() and planet.has_coordinates:
		$CanvasLayer/DebugSend.set_origin(planet.coordinates)
	
	
	_on_connector_click(planet)

func _on_station_port_clicked(portParent, _port):
	_on_connector_click(portParent)



func send_ship(from, to):
	var planets_nodes = find_children("*", "Planet", true, false)
	print(planets_nodes)
	
	
	var origin_planet: Planet = null
	var destination_planet: Planet = null
	
	print("Debug send: from ", from, " to ", to)
	
	# Find planet that matches coordinates
	for planet_node in planets_nodes:
		assert(planet_node is Planet)
				
		if not planet_node.has_coordinates:
			continue
	
		var coordinates = planet_node.coordinates
	
		print("[DEBUG SEND] Planet coordinates: ", coordinates)
		
		if coordinates == from: 
			print("[DEBUG SEND] Found origin ", coordinates)
			origin_planet = planet_node 
		
		if coordinates == to:
			print("[DEBUG SEND] Found destination ", coordinates)
			destination_planet = planet_node
			
	if !origin_planet:
		print("[ERROR] Origin not found")
		return
	
	if !destination_planet:
		print("[ERROR] Destination not found")
		return
	
	var originPort = origin_planet.find_child("PortComponent") as PortComponent
	var destinationPort = destination_planet.find_child("PortComponent") as PortComponent
	
	print(originPort)
	print(destinationPort)
	
	
	var origin_network = planet_network._extract_network_from_coordinates(from)
	var destination_network = planet_network._extract_network_from_coordinates(to)
	
	var color = ColorsNet.getColor(origin_network)
	var shipData = ShipData.new()
	shipData.color = color
	
	shipData.mustBeRouted = (origin_network != destination_network)
	
	var otherPort = originPort.connected_to 
	if shipData.mustBeRouted and !(otherPort.owner is Station or otherPort.owner is Portal):
		print("Trying to send a ship to another network without a station or router")
		origin_planet.play_error()
		return
	
	shipData.originCoordinates = from
	shipData.destinationCoordinates = to
	originPort.send_ship_to_linked_port(shipData)


func add_portal(object: Portal):
	object.connect("portalClicked", _on_portal_click)
	object.connect("portClicked", _on_station_port_clicked)
	camera.register_portal(object)

func add_planet(object: Planet):
	object.connect("onPlanetClick", _on_planet_click)	
	
func add_station(object: Station):
	object.connect("portClicked", _on_station_port_clicked)

func register_node(object):
	if object is Portal:
		add_portal(object)
	elif object is Planet:
		add_planet(object)
	elif object is Station:
		add_station(object)	


func _on_object_created(object):
	register_node(object)


func _on_debug_send_send_ship(from, to):
	send_ship(from, to)
