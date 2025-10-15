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
