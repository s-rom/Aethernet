extends Sprite2D

var _success_texture = preload("res://GUI/Vector/Green/Icon_Check.png")
var _failure_texture = preload("res://GUI/Vector/Green/Icon_X.png")

func _ready():
	pass

func play_success():
	self.texture = _success_texture
	$AnimationPlayer.play("SendSuccess")
	
func play_error():
	self.texture = _failure_texture
	$AnimationPlayer.play("SendFailure")


func _on_animation_player_animation_finished(anim_name):
	# print(anim_name + " ended")
	self.self_modulate.a = 0



