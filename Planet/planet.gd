extends Node2D
class_name Planet

signal onPlanetClick(planet: Sprite2D)
signal shipReceived(planet: Planet, success: bool, shipData)
signal replyReceived(planet: Planet, shipData)

var is_linked: bool:
	get: 
		var portComponent = find_child("PortComponent") as PortComponent
		return portComponent and portComponent.is_linked()

var has_coordinates: bool:
	get:
		return coordinates != ""

var coordinates: String: 
	get: 
		return $LineEdit.text
		
func _on_port_component_ship_arrived(shipData: ShipData):
	var myPort = self.find_child("PortComponent")
	var myCoordinates = $LineEdit.text
	
	if myCoordinates == shipData.destinationCoordinates:
		$SendShipFeedback.play_success()
	else:
		$SendShipFeedback.play_error()
		shipReceived.emit(self, false, shipData) # emit signal as failure

	if myCoordinates == shipData.destinationCoordinates and not shipData.isReply:
		shipReceived.emit(self, true, shipData)
		var replyShipData: ShipData = ShipData.new()
		replyShipData.originCoordinates = shipData.destinationCoordinates
		replyShipData.destinationCoordinates = shipData.originCoordinates
		replyShipData.isReply = true
		replyShipData.isTestShip = shipData.isTestShip
		myPort.send_ship_to_linked_port(replyShipData)

	elif shipData.isReply:
		replyReceived.emit(self, shipData)
