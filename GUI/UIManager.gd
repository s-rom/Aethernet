extends CanvasLayer

class_name UIManager

var _goalGuiItemScn = preload("res://GUI/GoalGuiItem.tscn")
var sendGUI: Control
@export var goalPanel: Control
@export var helpPanel: Control
@export var goalCompleted: Control

var _playButton: PlayButton
var _goalTracker: GoalTracker

signal playButtonPressed()
signal stopButtonPressed()

func _ready():

	#var editorGoalItems = self.find_children("*", "GoalGuiItem", true, false)
	#for item in editorGoalItems:
		#item.queue_free()
		
	sendGUI = $DebugSend
	_playButton = $MainButtons/AspectRatioContainer/PlayButton

	for child in self.get_children():
		if child is PanelContainer:
			child.visible = false	
	
	$HelpPanel.visible = true

	_goalTracker = get_tree().root.find_child("GoalTracker", true, false)	
	if _goalTracker:
		_goalTracker.connect("goalCompleted", _on_goal_completed)
		_goalTracker.connect("subGoalCompleted", _on_subgoal_completed)
		#_goalTracker.connect("testingStarted", _on_testing_started)
		#_goalTracker.connect("testingEnded", _on_testing_ended)
		

func _hide_line_edits():
	var lineEdits = get_tree().root.find_children("*", "LineEdit", true, false)
	for lineEdit in lineEdits:
		lineEdit.visible = false
	

func _show_line_edits():
	var lineEdits = get_tree().root.find_children("*", "LineEdit", true, false)
	for lineEdit in lineEdits:
		lineEdit.visible = true


func _on_subgoal_completed(subgoal, status):
	if not status:
		print("Some subgoal failed")
		_show_line_edits()
		_playButton.set_play_mode()

func add_goal_item(text, subgoal):
	var goalItem = _goalGuiItemScn.instantiate() as GoalGuiItem
	goalItem.set_uncompleted()
	goalItem.set_goal(text, subgoal)
	$GoalPanel/MarginContainer/VBoxContainer.add_child(goalItem)
	

func _on_goal_completed():
	for child in self.get_children():
		if child is PanelContainer:
			child.visible = false	
	
	
	$GoalPanel.visible = true
	await get_tree().create_timer(1).timeout
	
	sendGUI.visible = false
	helpPanel.visible = false
	goalCompleted.visible = true
	_playButton.disabled = true
	_playButton.focus_mode = Control.FOCUS_NONE


func _on_play_button_pressed():
	

	
	if _playButton.is_play_mode():
		_hide_line_edits()
		
		_playButton.set_stop_mode()
		playButtonPressed.emit()
		goalPanel.visible = true

	
	else:
		stopButtonPressed.emit()
		_show_line_edits()
		
		##BORRAR##
		goalPanel.visible = false
		##########
		
		_playButton.set_play_mode()




func _on_goal_button_pressed():
	goalPanel.visible = not goalPanel.visible


func _on_help_button_pressed():
	helpPanel.visible = not helpPanel.visible


func _on_home_button_pressed():
	get_tree().change_scene_to_file("res://Levels/MainSceneMenu.tscn")


func _on_redo_button_pressed():
	LevelsData.change_to_level(LevelsData.current_level)


func _on_next_level_button_pressed():
	LevelsData.change_to_level(LevelsData.get_next_level())
