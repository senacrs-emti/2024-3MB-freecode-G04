extends Button

signal click_end()

func _on_mouse_entered():
	pass
	#$snd_hover.play()

func _on_mouse_exited():
	pass
	#$snd_click.play()

func _on_sdn_click_finished():
	emit_signal("click_end")
