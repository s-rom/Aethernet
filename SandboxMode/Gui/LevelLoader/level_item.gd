extends MarginContainer

class_name LevelItem

signal level_item_clicked(level_item)

@onready var label: Label =  $PanelContainer/MarginContainer/Label

var level_path: String

var level_name: String:
	set(value):
		print("Set")
		label.text = value
	get:
		return label.text

var selected: bool = false:
	get():
		return selected
	set(value):
		selected = value
		_update_visuals()

func _update_visuals() -> void:
	if selected:
		print("Change theme variation to selected on " + self.level_name)
		self.modulate = "#696969"
	else:
		self.modulate = "#ffffff"
	

func _on_panel_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var mouse_event = event as InputEventMouse
		if mouse_event.button_mask & MOUSE_BUTTON_LEFT:
			level_item_clicked.emit(self)
