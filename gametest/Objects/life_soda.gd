extends Area2D

@export var regen_value = 20

var target = null
var speed = 0

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected
@onready var anim = $AnimationPlayer

func _ready():
	anim.play("stand")

func _physics_process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 10*delta

func collect():
	sound.play()
	collision.call_deferred("set", "disabled", true)
	sprite.visible = false
	return regen_value

func _on_snd_collected_finished():
	queue_free()
