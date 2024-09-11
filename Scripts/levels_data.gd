extends Node

var _levels_data_path = "res://Levels/levels.json"

var levels_data
var level_data_by_name = {}

var current_level = null # level name

# Se ejecuta solo una (no se ejecuta al cambiar de escena)
func _ready():
	_parse_json()
	print("LevelsData singleton ready")


func change_to_level(level_name):
	current_level = level_name
	var level_path = level_data_by_name[level_name]["path"]
	get_tree().change_scene_to_file(level_path)


func get_next_level():
	
	var i = 0
	
	while i < len(levels_data):
		var level = levels_data[i]
		if level["name"] == current_level:
			break
		i = i + 1
	
	if (i + 1) >= len(levels_data):
		return null
	else:
		return levels_data[i + 1]["name"]


func get_current_level_slides():
	for level in levels_data:
		if level["name"] == current_level and "slides" in level:
			return level["slides"]
				
	return null


func set_current_level_completed():
	for level in levels_data:
		if level["name"] == current_level:
			level["completed"] = true


func _parse_json():
	var levelsFile =  FileAccess.open(_levels_data_path, FileAccess.READ) 
	var jsonObj = JSON.new()
	var parseStatus = jsonObj.parse(levelsFile.get_as_text())

	if not parseStatus == OK:
		print("JSON Parse Error: ", jsonObj.get_error_message(), " in data at line ", jsonObj.get_error_line())
		return

	levels_data = jsonObj.data["levels"]
	var base_path = jsonObj.data["base_path"]

	for level in levels_data:
		level["path"] = base_path + level["path"]
	
	for level in levels_data:
		level_data_by_name[level["name"]] = level
	
	print(level_data_by_name)
		

