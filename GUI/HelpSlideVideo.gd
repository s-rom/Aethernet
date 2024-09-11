extends VBoxContainer

class_name HelpSlideVideo

var _video_player
var _video_player_parent
var _label

# Called when the node enters the scene tree for the first time.
func _ready():
	_video_player = self.find_child("VideoPlayer") as VideoStreamPlayer
	_video_player_parent = _video_player.get_parent().get_parent() as Control
	_label = self.find_child("RichTextLabel") as RichTextLabel	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_slide_idx_text(text):
	var label = self.find_child("SlideIdx")
	label.text = text

func set_text(text):
	var rich_label = (self.find_child("RichTextLabel") as RichTextLabel)
	rich_label.text = "[fill]" + text + "[/fill]"


func disable_video():
	_video_player_parent.visible = false
	_label.size_flags_vertical = SIZE_EXPAND_FILL

func set_video(video_file):
	_label.size_flags_vertical = SIZE_SHRINK_CENTER
	_video_player_parent.visible = true
	
	var stream = VideoStreamTheora.new()
	stream.file = video_file
	
	_video_player.stream = stream
	_video_player.loop = true
	_video_player.play()
	
