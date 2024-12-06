extends Area2D

var level = 1
var hp = 1
var speed = 100
var damage = 5
var knockback_amount = 100
var attack_size = 1.0
var stun = 2

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var anim = $AnimationPlayer
@onready var player = get_tree().get_first_node_in_group("player")
signal remove_from_array(object)

func _ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)
	match level:
		1:
			hp = 1
			speed = 100
			damage = 3
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
			stun = 2
			UpgradeDb.stunIce = stun
		2:
			hp = 1
			speed = 100
			damage = 3
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
			stun = 3
			UpgradeDb.stunIce = stun
		3:
			hp = 2
			speed = 200
			damage = 3
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
			stun = 3
			UpgradeDb.stunIce = stun
		4:
			hp = 2
			speed = 100
			damage = 3
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
			stun = 4
			UpgradeDb.stunIce = stun
	anim.play("attackAnim")
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1.5,1.5)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta):
	position += angle*speed*delta

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array",self)
		queue_free()

func _on_timer_timeout():
	emit_signal("remove_from_array",self)
	queue_free()

func _on_body_entered(body):
	if body.has_method("set_speed"): 
		emit_signal("enemy_hit_signal", body)
