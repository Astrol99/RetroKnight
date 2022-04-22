extends Node2D

func _on_Cutscene_tree_exited():
	get_tree().change_scene("res://src/MainMenu/MainMenu.tscn")
