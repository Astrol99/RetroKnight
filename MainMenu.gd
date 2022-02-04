extends Control


func _ready():
	$VBoxContainer/Start.grab_focus()


func _on_Enter_pressed():
	get_tree().change_scene("res://World.tscn")


func _on_Quit_pressed():
	get_tree().quit()
