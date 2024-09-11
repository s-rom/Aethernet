extends Node

var _colorsMap = {}

@export var colorsData: PackedColorArray

func _ready():
	
	_colorsMap["A"] = colorsData[0]
	_colorsMap["B"] = colorsData[1]
	_colorsMap["C"] = colorsData[2]
	_colorsMap["D"] = colorsData[3]
	

func getColor(networkId):
	if networkId in _colorsMap:
		return _colorsMap[networkId]
	
	else:
		return self.get_meta("defaultColor")
