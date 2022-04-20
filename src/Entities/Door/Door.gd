extends Area2D

export(String) var location

func _on_Door_body_entered(_body):
	if get_tree().change_scene(location) != OK:
		print("An unexpected error occured when trying to switch to the World scene")
