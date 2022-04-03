extends CanvasLayer

var stats = PlayerStats
onready var _YOU_DIED = get_node("YOU DIED")
onready var _animation_player = $AnimationPlayer

func _ready():
	_YOU_DIED.modulate.a = 0
	stats.connect("no_health", self, "show_death")
	
func show_death(_value):
	_animation_player.play("show_death")
