extends PanelContainer


var _current_slide_idx = 0
var _slides = []

func _ready():
	_slides = LevelsData.get_current_level_slides()
	
	print("------------------- current slides -------------- ")
	print(_slides)
	
	
	_current_slide_idx = 0
	
	_set_slide_data()
	
	
func _set_slide_data():
	if not _slides:
		return 
	
	
	var current_slide = _slides[_current_slide_idx]
	var helpSlideVideo = self.find_child("HelpSlideVideo") as HelpSlideVideo
	
	helpSlideVideo.set_slide_idx_text(str(_current_slide_idx + 1) + "/" + str(len(_slides)))
	helpSlideVideo.set_text(current_slide["text"])
	
	if "video" not in current_slide:
		helpSlideVideo.disable_video()
	else:
		helpSlideVideo.set_video(current_slide["video"])

func next_slide():
	
	# Pressed next on last slide
	if _current_slide_idx == len(_slides) - 1:
		self.visible = false
		_current_slide_idx = 0
	else:	
		_current_slide_idx = (_current_slide_idx + 1) % len(_slides)

	_set_slide_data()
	
	
	
	
func previous_slide():
	
	if _current_slide_idx == 0:
		return
	
	_current_slide_idx = (_current_slide_idx - 1) % len(_slides)
	_set_slide_data()

func _process(delta):
	pass


func _on_previous_slide_pressed():
	previous_slide()


func _on_next_slide_pressed():
	next_slide()
