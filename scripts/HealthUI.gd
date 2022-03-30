extends Control

var health = 5 setget set_health
var max_health = 5 setget set_max_health

onready var health_bar = $HealthBar

func set_health(value):
	health = clamp(value, 0, max_health)
	health_bar.value = health

func set_max_health(value):
	max_health = max(value, 1)
	self.health = min(health, max_health)
	health_bar.max_value = max_health

func _ready():
	self.max_health = PlayerStats.max_health
	self.health = PlayerStats.health
	if PlayerStats.connect("health_changed", self, "set_health") != OK:
		print("An error occurred when connecting health_changed signal to set_health function")
	if PlayerStats.connect("max_health_changed", self, "set_max_health") != OK:
		print("An error occurred when connecting max_health_changed signal to set_max_health function")
