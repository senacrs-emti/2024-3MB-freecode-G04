extends CharacterBody2D

@export var movement_speed = 60.0
@export var healph = 10
@export var knockback_recovery = 3.5
@export var enemy_damage = 1
@export var experience = 1
@export var is_boss = false  # New variable to identify if the enemy is a boss

var knockback = Vector2.ZERO

@onready var sprite = $Sprite2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var hitBox = $HitBox
@onready var anim = $AnimationPlayer
@onready var critic = get_node("res://Jogador/jogador.tscn")

var death_anim = preload("res://inimigos/explosion.tscn")
var exp_gem = preload("res://Objects/experience_gem.tscn")
var regen_health = preload("res://Objects/life_soda.tscn")

signal remove_from_array(object)

func _ready():
	hitBox.damage = enemy_damage
	if is_boss:
		print("A boss has spawned!")  # Print a message when a boss spawns

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed
	velocity += knockback
	move_and_slide()
	anim.play("walk")
	
	if direction.x > 0:
		sprite.flip_h = true
	elif direction.x < 0:
		sprite.flip_h = false

func death():
	emit_signal("remove_from_array", self)
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale * 2
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)
	var rand = RandomNumberGenerator.new().randi_range(1,50)
	if rand == 1:
		var new_regen = regen_health.instantiate()
		new_regen.global_position = global_position
		loot_base.call_deferred("add_child", new_regen)
	queue_free()

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	var rand = RandomNumberGenerator.new().randi_range(0,10)
	if rand <= UpgradeDb.critic_chance:
		healph -= damage * 2
	else:
		healph -= damage
	knockback = angle * knockback_amount
	if healph <= 0:
		death()
	if is_boss == true:
		UpgradeDb.boss_health = healph
