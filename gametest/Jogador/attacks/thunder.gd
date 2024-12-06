extends Area2D

var level = 1
var hp = 3
var speed = 500.0
var damage = 10
var knockback_amount = 100
var paths = hp
var attack_size = 1.0
var attack_speed = 5.0

var target = Vector2.ZERO
var target_array = []

var angle = Vector2.ZERO
var reset_pos = Vector2.ZERO

var spr_jav_reg = preload("res://Texturas/Items/Weapons/lightningAttack.png")
var spr_jav_atk = preload("res://Texturas/Items/Weapons/lightningAttack.png")

@onready var anim = $AnimationPlayer
@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var attackTimer = get_node("%AttackTimer")
@onready var changeDirectionTimer = get_node("%ChangeDirection")
@onready var snd_attack = $snd_attack

signal remove_from_array(object)

func _ready():
	update_thunder()
	global_position = player.global_position  # Inicia o ataque na posição do jogador
	add_paths()

func update_thunder():
	level = player.thunder_level
	match level:
		1:
			hp = 3
			speed = 500.0
			damage = 10
			knockback_amount = 100
			paths = hp
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1-player.spell_cooldown)
		2:
			hp = 6
			speed = 500.0
			damage = 10
			knockback_amount = 100
			paths = hp
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1-player.spell_cooldown)
		3:
			hp = 6
			speed = 500.0
			damage = 12
			knockback_amount = 100
			paths = hp
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1-player.spell_cooldown)
		4:
			hp = 6
			speed = 500.0
			damage = 15
			knockback_amount = 120
			paths = hp
			attack_size = 1.5 * (1 + player.spell_size)
			attack_speed = 5.0 * (1-player.spell_cooldown)
	anim.play("attackAnim")
	scale = Vector2(2.0,2.0) * attack_size
	attackTimer.wait_time = 1

func _physics_process(delta):
	if target_array.size() > 0:
		position += angle * speed * delta
	else:
		var player_angle = global_position.direction_to(reset_pos)
		var distance_dif = global_position - player.global_position
		var return_speed = 20
		if abs(distance_dif.x) > 500 or abs(distance_dif.y) > 500:
			return_speed = 100
		position += player_angle*return_speed*delta
		rotation = global_position.direction_to(player.global_position).angle()

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array",self)
		queue_free()

func add_paths():
	emit_signal("remove_from_array", self)
	target_array.clear()
	var counter = 0
	while counter < paths:
		var new_path = player.get_random_target()
		target_array.append(new_path)
		counter += 1
	enable_attack(true)
	target = target_array[0]
	process_path()

func process_path():
	angle = global_position.direction_to(target)
	changeDirectionTimer.start()
	var tween = create_tween()
	var new_rotation_degrees = angle.angle()
	tween.tween_property(self,"rotation",new_rotation_degrees,0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func enable_attack(atk = true):
	if atk:
		collision.call_deferred("set","disabled",false)
		anim.play("standAnim")
	else:
		collision.call_deferred("set","disabled",true)
		anim.play("RESET")

func _on_attack_timer_timeout():
	add_paths()

func _on_change_direction_timeout():
	if target_array.size() > 0:
		target_array.remove_at(0)
		if target_array.size() > 0:
			target = target_array[0]
			process_path()
			emit_signal("remove_from_array", self)
		else:
			attackTimer.start()
			enable_attack(false)
	else:
		attackTimer.start()
		enable_attack(false)

func _on_reset_pos_timer_timeout():
	var choose_direction = randi() % 4
	reset_pos = player.global_position
	match choose_direction:
		0:
			reset_pos.x += 50
		1:
			reset_pos.x -= 50
		2:
			reset_pos.y += 50
		3:
			reset_pos.y -= 50
