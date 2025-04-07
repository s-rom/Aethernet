extends Node2D

class_name PortalMainMenu

@onready var _animator = $Energy/AnimationPlayer
var ANIM_MAIN_MENU = "Portal_MainMenu"
var ANIM_IDLE = "RESET"
var ANIM_SHUTDOWN = "Portal_Shutdown"


func _ready() -> void:
	_animator.animation_set_next(ANIM_MAIN_MENU, ANIM_IDLE)
	_animator.play(ANIM_SHUTDOWN)
	_animator.stop(false)

# Just to reuse Portal animation player
func hide_all_line_edits():
	pass

func show_all_line_edits():
	pass
	
	
func play_idle():
	_animator.play(ANIM_IDLE)

func play_main_menu_animation():
	_animator.play(ANIM_MAIN_MENU, -1, 1.25)
