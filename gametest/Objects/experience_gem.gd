extends Area2D

@export var experience = 1

var base_green = preload("res://Texturas/Items/Gems/xpGem.png")

var target = null
var speed = -5

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected
@onready var anim = $AnimationPlayer

func _ready():
	if experience < 5:
		sprite.self_modulate = Color8(255,255,255,255)
	elif experience < 10:
		sprite.self_modulate = Color8(255,0,0,255)
	else: 
		sprite.self_modulate = Color8(0,0,0,255)
	anim.play("stand")

func _physics_process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 10*delta

func collect():
	sound.play()
	collision.call_deferred("set", "disabled", true)
	sprite.visible = false
	return experience

func _on_snd_collected_finished():
	queue_free()
