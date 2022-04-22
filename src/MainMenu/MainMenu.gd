extends Control

onready var _parallax_background = $ParallaxBackground

func _ready():
	randomize()
	$VBoxContainer/Start.grab_focus()

func _process(delta):
	_parallax_background.scroll_offset.x -= 10 * delta

func _on_Enter_pressed():
	"""
	if get_tree().change_scene("res://src/Tutorial/Tutorial.tscn") != OK:
		print("An unexpected error occured when trying to switch to the World scene")
	"""
	# Remove the current level
	var root = get_node("/root")
	var MainMenu = root.get_node("MainMenu")
	root.remove_child(MainMenu)
	MainMenu.call_deferred("queue_free")

	# Add the next level
	var next_level_resource = load("res://src/UI/CutScene/Cutscene.tscn")
	var next_level = next_level_resource.instance()
	next_level.text = "A sudden dark atmosphere looms across the beautiful village of Arcadia. What was once a land of tranquility and solidarity with its natural environment has now been submerged into that of one’s nightmares. But apace with the darkness emerges a new light. The RetroKnight lurks nearby, sensing a hazard hidden in the depths of the mysterious Cave of Tutoris."
	next_level.path = "res://src/Tutorial/Tutorial.tscn"
	root.add_child(next_level)

func _on_Quit_pressed():
	if OS.has_feature('JavaScript'):
		JavaScript.eval("window.close()")
	get_tree().quit()
