extends Control

var level = "res://main.tscn"
@onready var btn_Ler = get_node("%btn_Ler")
@onready var paper = get_node("%paperTexture")
@onready var book = get_node("%bookTexture")
@onready var anim = $AnimationPlayer

func _ready():
	var tween = book.create_tween()
	tween.tween_property(book, "modulate", Color8(255,255,255,255),3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	anim.play("btnStand")

func _on_btn_ler_pressed():
	paper.visible = true
	btn_Ler.visible = false
	var tween = paper.create_tween()
	tween.tween_property(paper, "modulate", Color8(255,255,255,255),2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()


func _on_btn_jogar_pressed():
	var _level = get_tree().change_scene_to_file(level)
