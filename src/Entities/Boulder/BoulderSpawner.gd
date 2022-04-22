extends Area2D

onready var boulder = load("res://src/Entities/Boulder/Boulder.tscn")
onready var collision_shape = $CollisionShape2D

func _on_BoulderSpawner_body_entered(_body):
	var boulder_instance = boulder.instance()
	boulder_instance.position.y -= 325
	call_deferred("add_child", boulder_instance)
	collision_shape.set_deferred("disabled", true)
	
