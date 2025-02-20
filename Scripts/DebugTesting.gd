extends Node


func _ready():
	var toDelete = ["HelpPanel", "MainButtons"]
	for itemName in toDelete:
		var child = get_tree().root.find_child(itemName, true, false)
		child.free()

	
