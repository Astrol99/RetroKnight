extends CanvasLayer

export(String) var text
export(String) var path

onready var label = $Label
onready var animation_player = $AnimationPlayer
onready var color_rect = $ColorRect

func _ready():
	label.text = text
	animation_player.play("cutscene")

func next_scene():
	color_rect.call_deferred("queue_free")
	get_tree().change_scene(path)
