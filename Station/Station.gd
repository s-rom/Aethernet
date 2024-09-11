extends Node2D

class_name Station

signal portClicked(portParent: Node2D, port: PortComponent)

@export var port_by_coordinates = {}
@export var coordinates_by_port = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	for port in self.find_children("Port*"):
		port.connect("portClicked", _on_port_clicked)
	
	for portComponent  in self.find_children("PortComponent"):
		portComponent.connect("ship_arrived", _on_ship_arrived)

	
func _on_ship_arrived(shipData: ShipData):
	var dstCoord = shipData.destinationCoordinates
	var originCoord = shipData.originCoordinates
	var port = shipData.destinationPort
		
	#print(self.name)
	#print("Ship from " + originCoord + " entered the station on " + port.get_parent().name + " . Destination: " + dstCoord)
	_update_port_table(port, originCoord)
	#_debug_print_table()

	if shipData.mustBeRouted:
		
		# Find gateway
		var origin_network = planet_network._extract_network_from_coordinates(originCoord)
		var station_ports = self.find_children("PortComponent")
		
		var direct_portal_found = false
		
		for station_port in station_ports:
			assert(port is PortComponent)
			if station_port.is_linked():
				var other_port = station_port.connected_to
				
				if other_port.owner is Portal and other_port.has_ip:
					var gateway_network = planet_network._extract_network_from_coordinates(other_port.coordinates)
					if gateway_network == origin_network:
						
						print("Found candidate router with a port in ", gateway_network, ")")
						direct_portal_found = true
						
						var newShipData: ShipData = ShipData.new()
						newShipData.mustBeRouted = true
						newShipData.destinationCoordinates = shipData.destinationCoordinates
						newShipData.originCoordinates = shipData.originCoordinates
						newShipData.isReply = shipData.isReply
						newShipData.isTestShip = shipData.isTestShip

						#print("Candidate found: " + next_port.get_parent().name)
						station_port.send_ship_to_linked_port(newShipData)
		
		if not direct_portal_found:
			print("No direct portal is connected to this switch")
			
			# find another switch
			for station_port in station_ports:
				assert(port is PortComponent)
				if station_port.is_linked():
					var other_port = station_port.connected_to
					if other_port.owner is Station:
						var newShipData: ShipData = ShipData.new()
						newShipData.mustBeRouted = true
						newShipData.destinationCoordinates = shipData.destinationCoordinates
						newShipData.originCoordinates = shipData.originCoordinates
						newShipData.isReply = shipData.isReply
						newShipData.isTestShip = shipData.isTestShip

						#print("Candidate found: " + next_port.get_parent().name)
						station_port.send_ship_to_linked_port(newShipData)
		
		return
		
	# Find if destination is in table
	if dstCoord in self.port_by_coordinates:
		
		# No funciona, sospecho que es el _update_port_table
		#print("---> the destination is known")
		var nextPort: PortComponent = port_by_coordinates[dstCoord]
		nextPort.send_ship_to_linked_port(shipData)

	else:
		#print("---> looking for a viable port")
		
		
		
		for next_port in self.find_children("PortComponent"):
			assert(next_port is PortComponent)
			
			if next_port == port:
				continue
			
			if next_port.is_linked():
				
				# Create empty shipData to avoid mixing
				var newShipData: ShipData = ShipData.new()
				newShipData.destinationCoordinates = shipData.destinationCoordinates
				newShipData.originCoordinates = shipData.originCoordinates
				newShipData.isReply = shipData.isReply
				newShipData.isTestShip = shipData.isTestShip

				#print("Candidate found: " + next_port.get_parent().name)
				next_port.send_ship_to_linked_port(newShipData)
		


func _debug_print_table():
	print("--- " + self.name + " ---")
	for coords in port_by_coordinates.keys():
		print(coords + "\t" + port_by_coordinates[coords].get_parent().name)


func _on_port_clicked(portParent, port):
	#print("Clicked on port " + port.name + " from " + portParent.name)
	portClicked.emit(portParent, port)

func clear_port_table():
	self.port_by_coordinates = {}
	self.coordinates_by_port = {}

func _update_port_table(portComponent: PortComponent, endpointCoordinates: String):
	self.port_by_coordinates[endpointCoordinates] = portComponent
	self.coordinates_by_port[portComponent] = endpointCoordinates


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
