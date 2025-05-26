extends Node


class_name SandboxManager

var planets = 0
var portals = 0
var stations = 0
var port_component_uid = 0


var _locked = false
@export var root_scene: root_script

func _ready() -> void:
	get_tree().current_scene.find_child("HelpPanel", true, false).visible = false
	call_deferred("_load_level")
	
func is_locked() -> bool:
	return _locked

func _on_lock_button_toggled(toggled_on: bool) -> void:
	get_tree().call_group("SandboxShowHide", "hide" if toggled_on else "show")
	_locked = toggled_on
#
@export var status_logger: StatusLog
#
#func _process(_delta: float) -> void:
	#if Input.is_action_pressed("right_click"):
		#status_logger.log_error("Mensaje de error largo")
	#
	#if Input.is_action_pressed("ui_cancel"):
		#status_logger.log_info("Mensaje de información largo")
			#


func _save_connections() -> Array[Dictionary]:
	var connections_data: Array[Dictionary] = []
	
	var connections = get_tree().current_scene.find_children("", "Connection", true, false)
	for connection: Connection in connections:

		var pc_start = connection.start.find_child("PortComponent")
		var pc_end = connection.end.find_child("PortComponent")

		var data = {
			"start_uid": pc_start.uid,
			"end_uid": pc_end.uid
		}

		connections_data.append(data)
	
	return connections_data




# var ports = get_tree().current_scene.find_children("PortComponent", true, false)
	
func _load_connection(connection_data, scene_port_components) -> void:
	var start_uid = connection_data["start_uid"]
	var end_uid = connection_data["end_uid"]

	var start_port: PortComponent = null
	var end_port: PortComponent = null

	for port: PortComponent in scene_port_components:
		if port.uid == start_uid:
			start_port = port
		elif port.uid == end_uid:
			end_port = port


	if start_port == null:
		push_error("Port with uid " + str(start_uid) + " not found")
		return

	if end_port == null:
		push_error("Port with uid " + str(end_uid) + " not found")
		return		 

	root_scene.create_connection(start_port.get_parent(),\
								 end_port.get_parent())			



func _load_level():
	
	var _scenes = {}
	
	var connection_data = []

	var level_data = LevelManager.load_save_file(SandboxGlobal.current_sandbox_level_path)
	for node_data: Dictionary in level_data:

		# Load connections
		if "start_uid" in node_data:
			connection_data.append(node_data)

		# Not a station/planet/portal
		if not node_data.has('scene_path'):
			continue

		var scene = node_data['scene_path']
		if not _scenes.has(scene):
			_scenes[scene] = load(scene)
			
		var node: Node2D = _scenes[scene].instantiate()
		root_scene.add_child(node)
		node.owner = root_scene
		root_scene.register_node(node)
		
		
		node.position.x = node_data["x"]
		node.position.y = node_data["y"]
		node.rotation = node_data["rotation"]
		
		if node_data.has("port_uids"):
			var max_uid = node_data["port_uids"].max()
			if port_component_uid < max_uid:
				port_component_uid = max_uid
			
			port_component_uid += 1
			
		for key in node_data.keys():
			if key == "x" or key == "y" or key == "scene_path":
				continue

			if key in node:
				node.set(key, node_data[key])
		
		node.from_data(node_data)

		# This helps to automatically assign new portal coordinates
		# For example, if x1-x2 is already in file, x won't be selected next
		if node is Portal:
			for p in range(3):
				var key = "port_"+str(p)
				if key not in node_data:
					continue
				var port_coord = node_data[key]
				var port_net = planet_network._extract_network_from_coordinates(port_coord)
				if not port_net.is_empty():
					root_scene.remove_available_network(port_net)
		
		var buttons = node.find_child("SpawnInputButtons")
		if buttons:
			buttons.show_buttons()

	var ports = get_tree().current_scene.find_children("", "PortComponent", true, false)
	for connection in connection_data:
		_load_connection(connection, ports)



func _save_to_file():
	var nodes = get_tree().get_nodes_in_group("Persist")
	
	var nodes_data = []
	for node in nodes:
		if node.has_method("save"):
			var node_data = node.call("save")
			nodes_data.append(node_data)
	

	nodes_data.append_array(_save_connections())
	LevelManager.write_save_file(nodes_data, SandboxGlobal.current_sandbox_level_path)
	

func _on_toolbox_object_dropped(object: Variant) -> void:
	
	if object is Planet:
		planets += 1
		object.name = "Planet"+str(planets)
	
	if object is Portal:
		portals += 1
		object.name = "Portal"+str(portals)
	
	if object is Station:
		stations += 1
		object.name = "Station"+str(stations)
	
	if object is Planet:
		var planet = object as Planet
		planet.portComponent.network_changed.connect(_on_network_changed)
	

	for port: PortComponent in object.find_children("", "PortComponent", true):
		port.uid = port_component_uid
		port_component_uid += 1

func _on_network_changed(planet, old_net, new_net):
	print("Planet " + planet.name + " changed net from " + old_net + " to " + new_net)


func _on_save_button_pressed() -> void:
	_save_to_file()
	status_logger.log_info("¡Guardado con éxito!")
	

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_to_file()
