extends Node2D


func _ready():
	pass


func _on_Hurtbox_area_entered(area):
	queue_free()
