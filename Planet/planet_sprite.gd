
extends Node2D

class_name root_script

var cameraSpeed = 25.

var connectionScn = preload("res://Connection/connection.tscn")


@export var debugSender: Control = null
var connectionOrigin = null
var currentConnection: Connection = null

var _draggingCamera = false
var _lastMousePosition: Vector2
var _mouseMovement: Vector2

@export var MIN_CAMERA_ZOOM = 0.3
@export var MAX_CAMERA_ZOOM = 2.5



var _availablePortalNetworks = PackedStringArray([
	"Z", "Y", "X", "W", "V", "U", "T", "S", "R", "ZY", "ZX", "ZW", "ZV", "ZU", "ZT",
	"ZS", "ZR", "YX", "YW", "YV", "YU", "YT", "YS", "YR", "XW", "XV", "XU", "XT", "XS", "XR",
	"VU", "VT", "VS", "VR", "TS", "TR", "SR"
])

signal camera_zoom_changed()


func _ready():
	
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

func _process(_delta: float):
	if currentConnection != null:
		currentConnection.remove_point(1)
		currentConnection.add_point(get_global_mouse_position())
		
	

func _input(event):
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT
		and currentConnection != null):
			currentConnection.queue_free()
			currentConnection = null 
			connectionOrigin = null
			get_tree().call_group("ClickHighlight", "disable_highlight")
	
	if event.is_action_pressed("toggle_fullscreen"):
		var mode = DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
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
				
	if event.is_action_pressed("ui_drag_camera"):
		#print("Start moving camera")
		_lastMousePosition = get_global_mouse_position()
		_draggingCamera = true

	if event.is_action_released("ui_drag_camera"):
		#print("Stop moving camera")
		_draggingCamera = false

	if _draggingCamera:
		if event is InputEventMouseMotion:
			_mouseMovement  = event.relative
			
func _physics_process(delta):
	if _draggingCamera:
		$Camera2D.position -= _mouseMovement * delta * cameraSpeed
		_mouseMovement = Vector2.ZERO


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



func _pop_portal_connection_network():
	var _front = _availablePortalNetworks[0]
	_availablePortalNetworks.remove_at(0)
	return _front


# endpoint1 and 2 is the immediate parent of a PortComponent (Sprite2D)
func create_connection(endpoint1, endpoint2, deletable = true):
	var new_connection = connectionScn.instantiate()
	self.add_child(new_connection)
	
	new_connection.can_be_deleted = deletable
	new_connection.clear_points()
	new_connection.add_point(endpoint1.global_position)
	new_connection.initColliderShape(endpoint2.global_position)
	new_connection.add_point(endpoint2.global_position)
	new_connection.updateShape()
	
	var portA = endpoint1.find_child("PortComponent") as PortComponent
	var portB = endpoint2.find_child("PortComponent") as PortComponent
	
	portA.link(portB, new_connection)
	portB.link(portA, new_connection)
	
	var parentA = portA.owner
	var parentB = portB.owner
	
	if parentA is Portal and parentB is Portal:
		var nextPortalNetwork = _pop_portal_connection_network()

		portA.coordinatesLineEdit.text = nextPortalNetwork + "1"
		portB.coordinatesLineEdit.text = nextPortalNetwork + "2"
		portA.coordinates = nextPortalNetwork + "1"
		portB.coordinates = nextPortalNetwork + "2"
			
		# print("coord portA: " + portA.coordinates)
		# print("coord portB: " + portB.coordinates)
		new_connection.change_to_portal_connection()
		

	
	
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
		
		# Remove mouse point
		currentConnection.remove_point(1)
		# Add second connector point
		currentConnection.add_point(connector.global_position)
		
		var portA = connector.find_child("PortComponent") as PortComponent
		var portB = connectionOrigin.find_child("PortComponent") as PortComponent
		

		portA.link(portB, currentConnection)
		portB.link(portA, currentConnection)

		var parentA = portA.owner
		var parentB = portB.owner

		# print("Create a connection between " + parentA.name + " and " + parentB.name)
		
		if parentA is Portal and parentB is Portal:
			var nextPortalNetwork = _pop_portal_connection_network()
			
			# --- Conflictivo
			portA.coordinatesLineEdit.text = nextPortalNetwork + "1"
			portB.coordinatesLineEdit.text = nextPortalNetwork + "2"
			portA.coordinates = nextPortalNetwork + "1"
			portB.coordinates = nextPortalNetwork + "2"
			
			# --- 
			
			# print("coord portA: " + portA.coordinates)
			# print("coord portB: " + portB.coordinates)
			currentConnection.change_to_portal_connection()



		currentConnection.updateShape()
		currentConnection = null
		return
		
	# Create a new connection
	if currentConnection == null:
		#print("Creating connection")
		
		get_tree().call_group("ClickHighlight", "set_highlighted")
		
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

func _on_station_port_clicked(portParent, port):
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
	
	var originPort = origin_planet.find_child("PortComponent")
	var destinationPort = destination_planet.find_child("PortComponent")
	
	print(originPort)
	print(destinationPort)
	
	
	var origin_network = planet_network._extract_network_from_coordinates(from)
	var destination_network = planet_network._extract_network_from_coordinates(to)
	
	var color = ColorsNet.getColor(origin_network)
	
	
	var shipData = ShipData.new()
	shipData.color = color
	
	shipData.mustBeRouted = (origin_network != destination_network)
	
	if shipData.mustBeRouted:
		print("SHIP MUST BE ROUTED")
	
	shipData.originCoordinates = from
	shipData.destinationCoordinates = to
	originPort.send_ship_to_linked_port(shipData)


func _on_debug_send_send_ship(from, to):
	send_ship(from, to)

