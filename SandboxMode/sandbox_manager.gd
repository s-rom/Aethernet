extends Node


class_name SandboxManager

var _locked = false
var _networks = {}
@export var network: planet_network
@export var root_scene: root_script

func _ready() -> void:
	get_tree().current_scene.find_child("HelpPanel", true, false).visible = false
	call_deferred("_load_level")
	
func is_locked() -> bool:
	return _locked

func _on_lock_button_toggled(toggled_on: bool) -> void:
	get_tree().call_group("SandboxShowHide", "hide" if toggled_on else "show")
	_locked = toggled_on


func _load_level():
	var _scenes = {}
	
	var level_data = LevelManager.load_save_file(SandboxGlobal.current_sandbox_level_path)
	for node_data: Dictionary in level_data:
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
		
			
		for key in node_data.keys():
			if key == "x" or key == "y" or key == "scene_path":
				continue
			node.set(key, node_data[key])
		
		node.from_data(node_data)
		
		
		var buttons = node.find_child("SpawnInputButtons")
		if buttons:
			buttons.show_buttons()


func _save_to_file():
	var nodes = get_tree().get_nodes_in_group("Persist")
	
	var nodes_data = []
	for node in nodes:
		if node.has_method("save"):
			var node_data = node.call("save")
			nodes_data.append(node_data)
	
	LevelManager.write_save_file(nodes_data, SandboxGlobal.current_sandbox_level_path)
	



func _create_network(net: String) -> void:
	network = planet_network.new()
	network.set_process(true)
	get_tree().current_scene.add_child(network)
	network.owner = get_tree().current_scene
	print("Created network " + net + " ", network)

func _on_toolbox_object_dropped(object: Variant) -> void:
	if object is not Planet:
		return
		
	var planet = object as Planet
	planet.portComponent.network_changed.connect(_on_network_changed)
	

func _on_network_changed(planet, old_net, new_net):
	print("Planet " + planet.name + " changed net from " + old_net + " to " + new_net)


func _on_save_button_pressed() -> void:
	_save_to_file()
