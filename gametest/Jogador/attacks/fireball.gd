extends Area2D

var level = 1
var healph = 1
var speed = 200
var damage = 5
var knockback_amount = 150
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var anim = $AnimationPlayer
@onready var player = get_tree().get_first_node_in_group("player")
signal remove_from_array(object)

func _ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle() #+ deg_to_rad(135)
	match level:
		1:
			healph = 1 #2 atravessa 1 inimigo e some no próximo
			speed = 200
			damage = 5
			knockback_amount = 150
			attack_size = 1.0 * (1 + player.spell_size)
		2:
			healph = 1 #2 atravessa 1 inimigo e some no próximo
			speed = 200
			damage = 5
			knockback_amount = 150
			attack_size = 1.0 * (1 + player.spell_size)
		3:
			healph = 2 #2 atravessa 1 inimigo e some no próximo
			speed = 200
			damage = 8
			knockback_amount = 150
			attack_size = 1.0 * (1 + player.spell_size)
		4:
			healph = 2 #2 atravessa 1 inimigo e some no próximo
			speed = 200
			damage = 8
			knockback_amount = 150
			attack_size = 1.0 * (1 + player.spell_size)
	anim.play("attackAnim")
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(2,2)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta):
	position += angle*speed*delta

func enemy_hit(charge = 1):
	healph -= charge
	if healph <= 0:
		emit_signal("remove_from_array", self)
		queue_free()

func _on_timer_timeout():
	emit_signal("remove_from_array", self)
	queue_free()
