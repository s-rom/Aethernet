extends Node2D

class_name planet_network

static var _networkPattern = RegEx.new()
var _planets
#var _rng = RandomNumberGenerator.new()

@export var set_network_tooltip = "A"

func _ready():
	_planets = self.find_children("Planet*", "Planet", false, true)
	_compilePattern()
	
	for planet in _planets:
		var sprite = planet.find_child("PlanetSprite") as Sprite2D
		var highlighter = planet.find_child("PortHighlighter") as PortHighlighter
		
		
		highlighter._originalModulate = ColorsNet.getColor(self.set_network_tooltip)
		sprite.self_modulate = ColorsNet.getColor(self.set_network_tooltip)
		
		var portComponent = planet.find_child("PortComponent") as PortComponent
		var lineEdit = portComponent.coordinatesLineEdit as LineEdit
		if lineEdit:
			lineEdit.placeholder_text = set_network_tooltip + "?"

static func _compilePattern():
	if not _networkPattern:
		_networkPattern = RegEx.new()
		
	if _networkPattern.get_pattern().is_empty():
		_networkPattern.compile("^([A-Z]+)[0-9]+$")



func number_of_planets():
	var planets = self.find_children("Planet*", "Planet")
	if !planets:
		return 0
	else:
		return len(planets)
	
func get_random_planet():
	return _get_random_planet(_planets)	

func _get_random_planet(planets):
	return (planets as Array[Planet]).pick_random()
	

func get_two_random_unique_planets():
	var planetsArray = (_planets as Array[Planet])
	var planet1 = _get_random_planet(_planets)
	
	var planetsCopy = planetsArray.duplicate(false)
	planetsCopy.erase(planet1)
	
	var planet2 = _get_random_planet(planetsCopy)
	
	
	print(_planets)
	return [planet1, planet2]


# Checks if all their planet children are linked by a path
func check_all_connected():
	for planet in _planets:
		assert(planet is Planet)
		
		if not planet.is_linked: 
			return false
	
	return true

static func _extract_network_from_coordinates(coordinates):
	_compilePattern()
	var result = _networkPattern.search(coordinates)
	if result:
		var network = result.get_string(1)
		return network

static func same_network(coordA: String, coordB: String) -> bool:
	return _extract_network_from_coordinates(coordA) == _extract_network_from_coordinates(coordB)


# Checks if all their planet children belong to the same network
func check_same_network():	
	
	var last_network = null
	for planet in _planets:
		assert(planet is Planet)
		if not planet.has_coordinates:
			return false
		
		var network = planet_network._extract_network_from_coordinates(planet.coordinates)
		if last_network == null:
			last_network = network
		elif last_network != network:
			return false

	return last_network == self.set_network_tooltip

			
			
			
			
			
			
			
			
			
			
			
			
			
	
	
