extends Node


func _ready():
	var toDelete = ["GoalPanel", "GoalButton", "PlayButton"]
	for itemName in toDelete:
		var child = get_tree().root.find_child(itemName, true, false)
		if child:
			child.visible = false

	
