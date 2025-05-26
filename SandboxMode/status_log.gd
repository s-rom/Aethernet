extends PanelContainer


class_name StatusLog

@export var info_color: Color
@export var error_color: Color
@export var full_duration = 6
@export var fade_out_duration = 2.5
@export var _label: Label


var _tween: Tween

func _start_tween() -> void:
	self.visible = true
	
	if _tween and _tween.is_running():
		_tween.stop()
		
	self.modulate.a = 1.0
	_tween = get_tree().create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, full_duration - fade_out_duration)
	_tween.tween_property(self, "modulate:a", 0.0, fade_out_duration)


func _ready() -> void:
	_label.text = ""
	
func log_info(message: String):
	_label.text = message
	_label.add_theme_color_override("font_color", info_color) 
	_start_tween()	

func log_error(message: String):
	_label.text = message
	_label.add_theme_color_override("font_color", error_color) 
	_start_tween()	
