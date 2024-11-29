extends Control

var level = "res://main.tscn"

func _ready():
	pass

func _on_btn_play_pressed():
	var _level = get_tree().change_scene_to_file(level)


func _on_btn_exit_pressed():
	get_tree().quit()
