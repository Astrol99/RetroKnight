extends CanvasLayer

onready var _animation_player = $AnimationPlayer

func _ready():
	for child in get_children():
		if child is Control:
			child.modulate.a = 0
		if child is Button:
			child.disabled = true

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		#get_tree().paused = true
		_animation_player.play("show_pause")

func _on_Try_Again_pressed():
	if get_tree().reload_current_scene() != OK:
		print("An exception occurred in reloading the current scene")
	

func _on_Quit_pressed():
	if OS.has_feature('JavaScript'):
		JavaScript.eval("window.close()")
	get_tree().quit()
