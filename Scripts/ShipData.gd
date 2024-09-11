extends RefCounted

class_name ShipData 

@export var originCoordinates: String 
@export var destinationCoordinates: String 

@export var mustBeRouted = false

var originPort: PortComponent
var destinationPort: PortComponent
var isReply = false
var color = Color(1, 1, 1)


var isTestShip = false # Used for tutorial levels, do not use in sandbox mode
