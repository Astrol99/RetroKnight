extends CanvasLayer

export(String) var text

onready var label = $Label
onready var animation_player = $AnimationPlayer

func _ready():
	label.text = text
	animation_player.play("cutscene")

func done():
	queue_free()

