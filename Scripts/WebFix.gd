extends Node

class_name WebFix

func _ready():
	if OS.has_feature("web"):
		var directional = get_tree().root.find_child("DirectionalLight2D", true, false)
		directional.energy = directional.energy / 2.0
		
		for station in get_tree().root.find_children("*", "Station", true, false):
			var light = station.find_child("PointLight2D", true, false) as PointLight2D
			light.energy = light.energy / 2.0
		
		for portal in get_tree().root.find_children("*", "Portal", true, false):
			var portalLight = portal.find_child("PointLight2D", true, false) as PointLight2D
			portalLight.energy = portalLight.energy * 0.4
