extends Label


const TIMER_LIMIT = 0.1
var timer = 0.0


var total = 0.0
var samples = 0

func _process(delta):
	timer += delta
	var fps = Engine.get_frames_per_second()
	samples += 1
	total += fps
	
	var avg_text = "AVG: " + str(total / samples)
	 	
	
	if samples > 10000:
		samples = 0
		total = 0
	
	
	
	if timer > TIMER_LIMIT:
		timer = 0.0
		self.text = "FPS: " + str(fps) + " " + avg_text
