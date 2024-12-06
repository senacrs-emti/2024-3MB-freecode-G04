extends Area2D

var level = 1
var healph = 9999
var speed = 200
var damage = 1
var knockback_amount = 150
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var anim = $AnimationPlayer
@onready var player = get_tree().get_first_node_in_group("player")
@onready var damage_timer = $DamageTimer
signal remove_from_array(object)

func _ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle()
	match level:
		1:
			healph = 9999
			speed = 200
			damage = 1
			knockback_amount = 150
			attack_size = 1.0 * (1 + player.spell_size)
		2:
			healph = 9999
			speed = 200
			damage = 2
			knockback_amount = 150
			attack_size = 1.5 * (1 + player.spell_size)
		3:
			healph = 9999
			speed = 200
			damage = 2
			knockback_amount = 150
			attack_size = 1.5 * (1 + player.spell_size)
		4:
			healph = 9999
			speed = 200
			damage = 4
			knockback_amount = 150
			attack_size = 1.5 * (1 + player.spell_size)
	anim.play("attackAnim")
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(2, 2) * attack_size, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	damage_timer.start()

func _physics_process(delta):
	if speed > 0:
		position += angle * speed * delta

func _on_damage_timer_timeout():
	apply_continuous_damage()

func apply_continuous_damage():
	var overlapping_bodies = get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("enemies"):
			body.take_damage(damage)

func enemy_hit(charge = 1):
	healph -= charge
	speed = 0
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(2.5, 2.5) * attack_size, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	anim.play("standAnim")
	if healph <= 0:
		emit_signal("remove_from_array", self)
		queue_free()

func _on_timer_timeout():
	emit_signal("remove_from_array", self)
	queue_free()
