extends PanelContainer

class_name DeleteDialog

var _text_template = "¿Quieres borrar {file_name}?\n\nEsta acción no puede deshacerse"
var _file_name: String

enum Status
{
	CONFIRMED,
	CANCELED
}

signal resolved(status: Status, file_name: String)

var file_name: String: 
	set(value):
		$MarginContainer/VBoxContainer/Label.text = _text_template.format(
			{"file_name": value}
		)
		_file_name = value
	get:
		return _file_name


func _on_confirm_delete_pressed() -> void:
	resolved.emit(Status.CONFIRMED, file_name)
	

func _on_cancel_delete_pressed() -> void:
	resolved.emit(Status.CANCELED, file_name)
