extends Node2D
class_name Planet

signal onPlanetClick(planet: Sprite2D)
signal shipReceived(planet: Planet, success: bool, shipData)
signal replyReceived(planet: Planet, shipData)

@onready var _portComponent: PortComponent = find_child("PortComponent") as PortComponent


var is_linked: bool:
	get: 
		return _portComponent and _portComponent.is_linked()

var coordinates: String: 
	get: 
		return _portComponent.coordinates

var has_coordinates: bool:
	get:
		return _portComponent and coordinates != ""


func _on_port_component_ship_arrived(shipData: ShipData):
	var myPort = self.find_child("PortComponent")
	
	
	if self.coordinates == shipData.destinationCoordinates:
		$SendShipFeedback.play_success()
	else:
		$SendShipFeedback.play_error()
		shipReceived.emit(self, false, shipData) # emit signal as failure

	if self.coordinates == shipData.destinationCoordinates and not shipData.isReply:
		shipReceived.emit(self, true, shipData)
		var replyShipData: ShipData = ShipData.new()
		replyShipData.originCoordinates = shipData.destinationCoordinates
		replyShipData.destinationCoordinates = shipData.originCoordinates
		replyShipData.isReply = true
		replyShipData.isTestShip = shipData.isTestShip
		myPort.send_ship_to_linked_port(replyShipData)

	elif shipData.isReply:
		replyReceived.emit(self, shipData)
