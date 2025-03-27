extends Node


class_name SandboxManager

var _locked = false


func is_locked() -> bool:
	return _locked

func _on_lock_button_toggled(toggled_on: bool) -> void:
	get_tree().call_group("SandboxShowHide", "hide" if toggled_on else "show")
	_locked = toggled_on
