extends Control

onready var _parallax_background = $ParallaxBackground

func _ready():
	$VBoxContainer/Start.grab_focus()

func _process(delta):
	_parallax_background.scroll_offset.x -= 10 * delta


func _on_Enter_pressed():
	get_tree().change_scene("res://scenes/Tutorial.tscn")

func _on_Quit_pressed():
	get_tree().quit()
