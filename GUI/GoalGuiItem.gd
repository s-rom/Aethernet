extends PanelContainer
class_name GoalGuiItem

var check_icon = preload("res://GUI/Vector/Green/check_square_grey_checkmark.svg")
var cross_icon = preload("res://GUI/Vector/Red/check_square_grey_cross.svg")
var empty_icon = preload("res://GUI/Vector/Blue/check_square_grey.svg")

@export var subgoalName: String = ""

func _ready():
	set_uncompleted()
	var goalTracker = get_tree().root.find_child("GoalTracker", true, false)
	
	if not goalTracker:
		print("Goal Tracker not found!")
		return

	goalTracker.connect("subGoalCompleted", _on_subgoal_completed)

func _on_subgoal_completed(subgoal, status):
	if subgoal == subgoalName:
		if status:
			set_completed()
		else:
			set_failed()

func set_goal(goal_text, subgoalName):
	$VBoxContainer/Label.text = goal_text
	self.subgoalName = subgoalName
	
func set_completed():
	$VBoxContainer/TextureRect.texture = check_icon

func set_uncompleted():
	$VBoxContainer/TextureRect.texture = empty_icon
	
func set_failed():
	$VBoxContainer/TextureRect.texture = cross_icon
