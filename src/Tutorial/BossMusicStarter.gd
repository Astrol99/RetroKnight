extends Area2D

onready var audio = get_parent().get_node("AudioStreamPlayer")

func _on_BossMusicStarter_body_entered(body):
	var path = "res://assets/music/Tutorial_Boss.mp3"
	var file = File.new()
	if file.file_exists(path):
		file.open(path, file.READ)
		var buffer = file.get_buffer(file.get_len())
		var stream = AudioStreamMP3.new()
		stream.data = buffer
		audio.stream = stream
		audio.play()
