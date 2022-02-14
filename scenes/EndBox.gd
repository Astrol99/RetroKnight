extends Area2D

var damage = 100

func _on_EndBox_body_entered(body):
	get_tree().quit()
