extends Control

class_name StationPanelTest

var tableScn: PackedScene = load("res://GUI/StationTable/StationTable.tscn") 
@onready var tablesContainer = $TablesContainer as HBoxContainer

func _ready() -> void:
	for child in tablesContainer.get_children():
		child.queue_free()

	

func register_station(station: Station):
	var table = tableScn.instantiate() as StationTable
	tablesContainer.add_child(table)
	table.link_station(station)


var _dragging = false

func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event as InputEventMouse).button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed(): 
				_dragging = true
			if event.is_released():
				_dragging = false
		
	if event is InputEventMouseMotion and _dragging:
		self.position += event.screen_relative
	
	
