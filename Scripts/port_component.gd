extends Node

class_name PortComponent

@export var has_ip = false
@export var connected_to: PortComponent = null 
@export var coordinatesLineEdit: CoordinatesLineEdit
@export var coordinates = "" : 
	set(value): 
		coordinates = value
		has_ip = (value != null && value != "")
	get:
		return coordinates

var shipScn = load("res://Ships/ship.tscn")
var lineEditScn = load("res://Portal/PortalLineEdit.tscn")
var _connection: Connection = null
var isPortal = false
var isPlanet = false

signal ship_arrived(shipData)
signal network_changed(owner, old_net, new_net)

@onready var camera2D = get_viewport().get_camera_2d()

func _ready():
	
	isPortal = self.owner is Portal
	isPlanet = self.owner is Planet

	var canvasLayer = get_tree().root.find_child("CanvasLayer", true, false)
	if canvasLayer and (isPortal or isPlanet):
		coordinatesLineEdit = lineEditScn.instantiate()
		canvasLayer.add_child(coordinatesLineEdit)

		var lineEditPositionNode = self.get_parent().find_child("LineEditPosition", false, false)
		if lineEditPositionNode:
			coordinatesLineEdit.followTarget = lineEditPositionNode
		else:
			coordinatesLineEdit.followTarget = self.get_parent()

	if coordinatesLineEdit:
		coordinatesLineEdit.connect("coordinates_changed", on_coordinates_text_changed)

func on_coordinates_text_changed(new_text: String):

	var old_net = planet_network._extract_network_from_coordinates(coordinates)
	var new_net = planet_network._extract_network_from_coordinates(new_text)

	if old_net != new_net:
		network_changed.emit(self.owner, old_net, new_net)


	print("New coordinates: " + new_text)
	self.coordinates = new_text


func is_linked():
	return connected_to != null
	
func notify_ship_entered(shipData):
	#print("Ship arrived on PortComponent")
	ship_arrived.emit(shipData)
	

func send_ship_to_linked_port(shipData: ShipData):

	var ship: Ship = shipScn.instantiate()
	
	# TODO Cuando se copia shipData se rompe esto
	# ship.self_modulate = shipData.color
	
	if not connected_to:
		#print("Trying to send a ship on an unlinked port!")
		return
		
	var origin = (self.get_parent() as Node2D).global_position
	var destination = (connected_to.get_parent() as Node2D).global_position
	ship.position = origin
	get_tree().current_scene.add_child(ship)
	
	#shipData.originCoordinates = originCoord
	#shipData.destinationCoordinates = dstCoord
	shipData.originPort = self
	shipData.destinationPort = connected_to
	
	ship.set_network_data(shipData)

	if _connection and _connection is PortalConnection:

		var reversed = false
		var dest_point = self.connected_to.get_parent().global_position 
		var curve_points = _connection.curve.get_baked_points()
		if dest_point == curve_points[0]:
			reversed = true
			ship.position = destination

		ship.set_navigation_curve(_connection.curve, 1.0, reversed)
	else:
		ship.set_navigation_goal_based_on_velocity(destination, 200)

func link(port: PortComponent, connection: Connection):
	#print("linked")
	self.connected_to = port
	self._connection = connection
	self._connection.connect("tree_exiting", _on_connection_destroyed)

func hide_line_edit() -> void:
	if coordinatesLineEdit:
		coordinatesLineEdit.visible = false
		
func show_line_edit() -> void:
	if coordinatesLineEdit:
		coordinatesLineEdit.visible = true

func _exit_tree() -> void:
	if coordinatesLineEdit:
		coordinatesLineEdit.queue_free()
		
	if _connection:
		_connection.queue_free()

func _unlink():
	#print("connection cleared")
	self.connected_to = null
	self._connection = null

func _on_connection_destroyed():
	#print("Connection was destroyed on " + self.get_parent().name)
	_unlink()
