extends Node


class_name SandboxManager

var _locked = false


func is_locked() -> bool:
	return _locked

func _on_lock_button_toggled(toggled_on: bool) -> void:
	get_tree().call_group("SandboxShowHide", "hide" if toggled_on else "show")
	_locked = toggled_on


func _on_toolbox_object_dropped(object: Variant) -> void:
	if object is not Planet:
		return
		
	var planet = object as Planet
	planet.portComponent.network_changed.connect(_on_network_changed)
	

func _on_network_changed(planet, old_net, new_net):
	print("Planet " + planet.name + " changed net from " + old_net + " to " + new_net)
