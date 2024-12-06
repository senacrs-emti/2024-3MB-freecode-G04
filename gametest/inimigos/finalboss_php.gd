extends CharacterBody2D

@export var movement_speed = 200.0
@export var basemovement_speed = 200.0
@export var healph = 500
@export var enemy_damage = 1
@export var is_boss = true  # New variable to identify if the enemy is a boss

@onready var sprite = $Sprite2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var hitBox = $HitBox
@onready var hurtBox = $HurtBox
@onready var anim = $AnimationPlayer
@onready var critic = get_node("res://Jogador/jogador.tscn")
@onready var stomp_area = $StompArea

var death_anim = preload("res://inimigos/explosion.tscn")

signal remove_from_array(object)

var stomping = false

func _ready():
	hitBox.damage = enemy_damage
	if is_boss:
		print("Final boss has spawned!")  # Print a message when a boss spawns
	stomp_area.connect("body_entered", Callable(self, "_on_stomp_area_body_entered"))
	UpgradeDb.finalboss_presence = true

func _physics_process(_delta):
	if not stomping:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * movement_speed
		move_and_slide()
		anim.play("walk")

func death():
	UpgradeDb.finalboss_presence = false
	emit_signal("remove_from_array", self)
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale * 2
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	queue_free()

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	var rand = RandomNumberGenerator.new().randi_range(0,10)
	if rand <= UpgradeDb.critic_chance:
		healph -= damage * 2
	else:
		healph -= damage
	if healph <= 0:
		death()
	else: 
		if is_boss != true and UpgradeDb.iceLevel < 4:
			set_speed(0.0)
			await get_tree().create_timer(UpgradeDb.stunIce).timeout
			set_speed(basemovement_speed)
		else:
			set_speed(0.0)
			await get_tree().create_timer(UpgradeDb.stunIce).timeout
			set_speed(basemovement_speed)
	if is_boss == true:
		UpgradeDb.boss_health = healph

func set_speed(value: float): 
	movement_speed = value

func stomp_player():
	var hitDisable = hitBox.collision
	var hurtDisable = hurtBox.collision
	stomping = true
	anim.play("stomp")
	await get_tree().create_timer(3).timeout
	hitDisable.disabled = false
	hurtDisable.disabled = false
	await get_tree().create_timer(5.0).timeout
	anim.play("getUp")
	hitDisable.disabled = true
	hurtDisable.disabled = true
	await get_tree().create_timer(3.0).timeout
	stomping = false

func _on_stomp_area_body_entered(body):
	if body == player:
		stomp_player()
