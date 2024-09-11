extends HBoxContainer

class_name PortalRule

signal delete_rule(rule: String)

func _ready():
	pass

func set_values(portalRule):
	self.find_child("Label").text = portalRule

func _on_button_pressed():
	delete_rule.emit($MarginContainer/Label.text)
