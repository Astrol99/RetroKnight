extends Node

export var max_health = 1 setget set_max_health
var health = max_health setget set_health

signal no_health(value)
signal health_increased(value)
signal health_decreased(value)
signal max_health_changed(value)

func _ready():
	self.health = max_health

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed")

func set_health(value):
	var old_health = health
	health = value
	
	if health <= 0:
		emit_signal("no_health", value)
	elif health < old_health:
		emit_signal("health_decreased", value)
	elif health > old_health:
		emit_signal("health_increased", value)
