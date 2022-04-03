extends CanvasLayer

var stats = PlayerStats
onready var _animation_player = $AnimationPlayer

func _ready():
	for child in get_children():
		if child is Control:
			child.modulate.a = 0
		if child is Button:
			child.disabled = true
		
	stats.connect("no_health", self, "show_death")
	
func show_death(_value):
	_animation_player.play("show_death")

func _on_Try_Again_pressed():
	get_tree().reload_current_scene()
	

func _on_Quit_pressed():
	if OS.has_feature('JavaScript'):
		JavaScript.eval("window.close()")
	get_tree().quit()
