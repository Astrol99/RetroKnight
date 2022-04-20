extends Control

var stats = PlayerStats
onready var _animation_player = $AnimationPlayer

func _ready():		
	stats.connect("no_health", self, "show_death")

func show_death(_value):
	visible = true
	_animation_player.play("show_death")

func _on_Try_Again_pressed():
	if get_tree().reload_current_scene() != OK:
		print("An exception occurred in reloading the current scene")

func _on_Quit_pressed():
	if OS.has_feature('JavaScript'):
		JavaScript.eval("window.close()")
	get_tree().quit()
