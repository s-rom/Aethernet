extends Button

class_name PlayButton

@export var playTexture: StyleBoxTexture
@export var stopTexture: StyleBoxTexture


const PLAY_MODE = 0
const STOP_MODE = 1

var _mode

var _playTheme = Theme.new()
var _stopTheme = Theme.new()

@export var hoverColor: Color
@export var disabledColor: Color

# Called when the node enters the scene tree for the first time.
func _ready():
	_init_styleboxes()
	set_play_mode()


func _init_styleboxes():
	var _hoverPlay = playTexture.duplicate() as StyleBoxTexture
	var _hoverStop = stopTexture.duplicate() as StyleBoxTexture
	
	var _disabledPlay = playTexture.duplicate() as StyleBoxTexture
	var _disabledStop = stopTexture.duplicate() as StyleBoxTexture
		
	_disabledPlay.modulate_color = disabledColor
	_disabledStop.modulate_color = disabledColor

	_hoverPlay.modulate_color = hoverColor
	_hoverStop.modulate_color = hoverColor

	_playTheme.set_stylebox("normal", "Button", playTexture)
	_stopTheme.set_stylebox("normal", "Button", stopTexture)

	_playTheme.set_stylebox("hover", "Button", _hoverPlay)
	_stopTheme.set_stylebox("hover", "Button", _hoverStop)

	_playTheme.set_stylebox("disabled", "Button", _disabledPlay)
	_stopTheme.set_stylebox("disabled", "Button", _disabledStop)

func is_play_mode():
	return _mode == PLAY_MODE


func set_play_mode():
	_mode = PLAY_MODE
	self.theme = _playTheme

func set_stop_mode():
	_mode = STOP_MODE
	self.theme = _stopTheme


