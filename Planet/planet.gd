extends Node2D
class_name Planet

signal onPlanetClick(planet: Sprite2D)
signal shipReceived(planet: Planet, success: bool, shipData)
signal replyReceived(planet: Planet, shipData)

var portComponent: PortComponent


func _ready() -> void:
	portComponent = self.find_child("PortComponent")
	print("Planet ready")


var is_linked: bool:
	get: 
		return portComponent and portComponent.is_linked()

var coordinates: String: 
	get: 
		return portComponent.coordinates
	set(new_coordinates):
		print("set new coord")
		portComponent.coordinates = new_coordinates
		

var has_coordinates: bool:
	get:
		return portComponent and coordinates != ""

func play_success() -> void:
	$SendShipFeedback.play_success()


func play_error() -> void:
	$SendShipFeedback.play_error()

func save() -> Dictionary:
	var dict = {
		"scene_path": "res://Planet/planet.tscn",
		"x": position.x,
		"y": position.y,
		"rotation": rotation,
		"coordinates": self.coordinates,
		"name": name,
		"port_uids": [self.find_child("PortComponent").uid] 
	}
	return dict

func from_data(data: Dictionary) -> void:
	var myPort = self.find_child("PortComponent")
	myPort.uid = data["port_uids"][0]


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
