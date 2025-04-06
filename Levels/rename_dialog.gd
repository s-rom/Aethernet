extends PanelContainer

class_name RenameDialog

@onready var _line_edit = $MarginContainer/VBoxContainer/HBoxContainer2/LineEdit

enum Status {
	CONFIRMED,
	CANCELED
}

func _ready() -> void:
	reset_log()

var file_path: String
var file_name: String:
	set(value):
		_line_edit.text = file_name


signal resolved(status: Status, old_path, new_name: String)


func log_result(text: String):
	$MarginContainer/VBoxContainer/Label.text = text

func reset_log():
	$MarginContainer/VBoxContainer/Label.text = ""

func _on_confirm_delete_pressed() -> void:
	resolved.emit(Status.CONFIRMED, file_path, _line_edit.text)


func _on_cancel_delete_pressed() -> void:
	resolved.emit(Status.CANCELED, file_path, _line_edit.text)
