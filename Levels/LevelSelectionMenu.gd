extends Node2D


var _level_selection_panel_scene = preload("res://GUI/level_selection_panel.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Level selection ready")
	
	var completed_levels = 0
	var total_levels = len(LevelsData.levels_data)
	
	
	
	for level in LevelsData.levels_data:
		var levelPanel = _level_selection_panel_scene.instantiate() as LevelPanel
		levelPanel.level_path = level["path"]
		levelPanel.level_name = level["name"]
		
		if "completed" in level and level["completed"]:
			levelPanel.set_completed()
			completed_levels += 1
	
		var container = self.find_child("LevelsContainer", true)		
		container.add_child(levelPanel)


	var progress = int((float(completed_levels) / float(total_levels)) * 100.0)

	var progressBar = self.find_child("ProgressBar")
	progressBar.value = progress
	
	var starsLabel = self.find_child("StarsLabel")
	starsLabel.text = "x " + str(completed_levels)
	



func _on_home_button_pressed():
	get_tree().change_scene_to_file("res://Levels/MainSceneMenu.tscn")
