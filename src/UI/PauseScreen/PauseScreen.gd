extends Control

var is_paused = false setget set_is_paused

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		self.is_paused = !is_paused

func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused

func _on_Reload_pressed():
	get_tree().paused = false
	if get_tree().reload_current_scene() != OK:
		print("An exception occurred in reloading the current scene")

func _on_Quit_pressed():
	if OS.has_feature('JavaScript'):
		JavaScript.eval("window.close()")
	get_tree().quit()
