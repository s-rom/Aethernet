extends Node2D

class_name Portal

signal portClicked(portParent: Node2D, port: PortComponent)
signal portalClicked(portal: Portal)

# key: target_network (String)
# value: next_hop (String)
var _rules = {}


const ANIMATION_IDLE = "Idle"
const ANIMATION_SEND = "send_ship"


var base_energy = 0.6

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var anim = $MagicEffect/AnimationPlayer
	anim.play(ANIMATION_IDLE)
	
	for port in self.find_children("Port*"):
		port.connect("portClicked", _on_port_clicked)
	
	for portComponent  in self.find_children("PortComponent"):
		portComponent.connect("ship_arrived", _on_ship_arrived)
		
	set_hightlight(false)


func add_rule(targetNetwork, nextHop):
	_rules[targetNetwork] = nextHop

func delete_rule_from_string(ruleString: String):
	# _rules.erase(targetNetwork)
	var targetNetwork = ruleString.split(' ')[0]
	print("First token: " + targetNetwork)
	_rules.erase(targetNetwork)


func get_rules_string():
	var rulesStrings = PackedStringArray()
	
	for targetNetwork in _rules.keys():
		var next_hop = _rules[targetNetwork]
		var ruleString = targetNetwork + " via " + next_hop

		rulesStrings.append(ruleString)
	
	return rulesStrings

func set_hightlight(state):
	var circle: Sprite2D = self.find_child("Circle")
	var highlightCircle: Sprite2D = self.find_child("HighlightCircle")
	
	
	if highlightCircle:
		circle.visible = not state  # visible when not highlighted
		highlightCircle.visible = state
		highlightCircle.highligted = state

	

func _input(event):
	var circleSprite: Sprite2D = self.find_child("Circle")
	
	if (event is InputEventMouse and event.is_pressed() and
	 	circleSprite.get_rect().has_point(to_local(get_global_mouse_position())) and 
		event.button_index == MOUSE_BUTTON_LEFT):
		
		set_hightlight(true)
		portalClicked.emit(self)
		
		for port in self.find_children("", "PortComponent"):
			print(port.coordinates + ", " + str(port.is_linked()))


func _on_port_clicked(portParent, port):
	# print("Clicked on port " + port.name + " from " + portParent.name)
	portClicked.emit(portParent, port)
	
	
func _on_ship_arrived(shipData: ShipData):
	# print("Ship arrived on " + self.name)
	
	
	var portalPorts = self.find_children("", "PortComponent")
	var targetNetwork = planet_network._extract_network_from_coordinates(shipData.destinationCoordinates)
	
	
	# REMOVE ROUTING FLAG
	shipData.mustBeRouted = false
	
	print("Ship arrived on portal (from ", shipData.originCoordinates, " to ", shipData.destinationCoordinates, ")")

	var foundDirectConnection = false

	for port in portalPorts:
		
		var portNetwork = planet_network._extract_network_from_coordinates(port.coordinates)
		assert(port is PortComponent)
		
		if port == shipData.destinationPort:
			continue
		
		# Find trivial port (port with same network as destination)
		if port.has_ip and targetNetwork == portNetwork:
			port.send_ship_to_linked_port(shipData)
			$MagicEffect/AnimationPlayer.stop()
			$MagicEffect/AnimationPlayer.play(ANIMATION_SEND, -1, 2.0)
			var tween = get_tree().create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_QUAD)
			tween.tween_property($PointLight2D, "energy", base_energy * 1.2, 0.6)
			tween.tween_property($PointLight2D, "energy", base_energy, 0.3)
			
			$MagicEffect/AnimationPlayer.queue(ANIMATION_IDLE)
			foundDirectConnection = true
			return 
			
	if foundDirectConnection:
		return
	
	# Read rules table
	for ruleNetwork in _rules.keys():
		if ruleNetwork == targetNetwork:
			print("[PORTAL] Found candidate rule: " + ruleNetwork + " via " + _rules[ruleNetwork])
			
			var nextHop = _rules[ruleNetwork]
			var nextHopNetwork = nextHop[0]
			
			var ports = self.find_children("", "PortComponent")
			for port in ports:
				assert(port is PortComponent)
				
				# print("--- PORT: " + port.coordinates + " ---")
				if not port.has_ip or not port.is_linked():
					continue
				
				# Port is linked and has ip
				var portNetwork = port.coordinates[0]

				# print("* Port candidate: " + port.coordinates)

				if nextHopNetwork == portNetwork:
					# print(" * sending on " + port.coordinates)

					port.send_ship_to_linked_port(shipData)
					$MagicEffect/AnimationPlayer.stop()
					$MagicEffect/AnimationPlayer.play(ANIMATION_SEND, -1, 2.0)
					var tween = get_tree().create_tween()
					tween.set_ease(Tween.EASE_IN_OUT)
					tween.set_trans(Tween.TRANS_QUAD)
					tween.tween_property($PointLight2D, "energy", base_energy * 1.2, 0.6)
					tween.tween_property($PointLight2D, "energy", base_energy, 0.3)

					$MagicEffect/AnimationPlayer.queue(ANIMATION_IDLE)
					return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
