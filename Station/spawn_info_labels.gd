extends Node2D


@onready var _infoLabelScn: PackedScene = load("res://GUI/StationTable/StationInfoLabel.tscn")


var _label: StationInfoLabel = null

func _ready() -> void:
	_create_labels()


func _create_labels():
	var canvasLayer = get_tree().current_scene.find_child("CanvasLayer", true, false)
	if canvasLayer:
		_label = _infoLabelScn.instantiate() as StationInfoLabel

		canvasLayer.add_child(_label)
		canvasLayer.move_child(_label, 0)
	
		_update_text()
		_label.position_target = self

func _update_text():
	var name = self.get_parent().name.left(1) +  self.get_parent().name.right(1)
	_label.text = name


func _process(delta: float) -> void:
	if not _label:
		return
	_update_text()
