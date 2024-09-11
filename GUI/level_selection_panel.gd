extends PanelContainer

class_name LevelPanel


var _check_texture = preload("res://GUI/Vector/Green/check_square_grey_checkmark.svg")

var level_name:
	get:
		return level_name
	set(new_name):
		level_name = new_name
		$MarginContainer/HBoxContainer/Label.text = new_name

var level_path:
	set(new_path):
		level_path = new_path
		# TODO

#var is_completed: bool:
	#set(status):
		#is_completed = status
	#get:
		#return is_completed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_completed():
	$MarginContainer/HBoxContainer/TextureButton.texture = _check_texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	

func _on_play_button_pressed():
	LevelsData.change_to_level(self.level_name)
