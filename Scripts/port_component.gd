extends Node

class_name PortComponent

@export var has_ip = false
@export var connected_to: PortComponent = null 
@export var coordinatesLineEdit: LineEdit
@export var coordinates = "" : 
	set(value): 
		coordinates = value
		has_ip = (value != null && value != "")
	get:
		return coordinates

var shipScn = load("res://Ships/ship.tscn")
var _connection: Connection = null


signal ship_arrived(shipData)


func _ready():
	if coordinatesLineEdit:
		coordinatesLineEdit.connect("text_changed", on_coordinates_text_changed)

func on_coordinates_text_changed(new_text: String):
	self.coordinates = new_text
	#print("new coordinates from LineEdit: " + self.coordinates)

func is_linked():
	return connected_to != null
	
func notify_ship_entered(shipData):
	#print("Ship arrived on PortComponent")
	ship_arrived.emit(shipData)
	

func send_ship_to_linked_port(shipData: ShipData):

	var ship: Ship = shipScn.instantiate()
	
	# TODO Cuando se copia shipData se rompe esto
	# ship.self_modulate = shipData.color
	
	var origin = (self.get_parent() as Node2D).global_position
	if not connected_to:
		#print("Trying to send a ship on an unlinked port!")
		return
		
	var destination = (connected_to.get_parent() as Node2D).global_position
	ship.position = origin
	get_tree().root.add_child(ship)
	
	#shipData.originCoordinates = originCoord
	#shipData.destinationCoordinates = dstCoord
	shipData.originPort = self
	shipData.destinationPort = connected_to
	
	ship.set_network_data(shipData)
	ship.set_navigation_goal_based_on_velocity(destination, 200)

func link(port: PortComponent, connection: Connection):
	#print("linked")
	self.connected_to = port
	self._connection = connection
	self._connection.connect("tree_exiting", _on_connection_destroyed)


func _clear():
	#print("connection cleared")
	self.connected_to = null
	self._connection = null

func _on_connection_destroyed():
	#print("Connection was destroyed on " + self.get_parent().name)
	_clear()

