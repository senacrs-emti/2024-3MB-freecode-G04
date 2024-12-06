extends Node2D

@export var spawns: Array[Spawn_info] = []

@onready var player = get_tree().get_first_node_in_group("player")

var time = 0

signal changetime(time)
signal boss_presence(boss_present: bool)

func _ready():
	connect("changetime", Callable(player, "change_time"))

func _on_timer_timeout():
	time += 1
	var enemy_spawns = spawns
		
	for i in enemy_spawns:
		if time >= i.time_start and time <= i.time_end:
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				var new_enemy = i.enemy
				var counter = 0
				while counter < i.enemy_num:
					var enemy_spawn = new_enemy.instantiate()
					var is_boss = new_enemy == preload("res://inimigos/boss_css.tscn") or new_enemy == preload("res://inimigos/boss_javascript.tscn") or new_enemy == preload("res://inimigos/finalboss_php.tscn")
					enemy_spawn.is_boss = is_boss
					enemy_spawn.global_position = get_random_position()
					add_child(enemy_spawn)
					if is_boss:
						emit_signal("boss_presence", true)  # Emit signal when boss is spawned
						UpgradeDb.boss_presence = true
						UpgradeDb.boss_health = enemy_spawn.healph
						UpgradeDb.boss_maxhealth = enemy_spawn.healph
					counter += 1
	emit_signal("changetime", time)

func get_random_position():
	var vpr = get_viewport_rect().size * randf_range(1.1, 1.4)
	var top_left = Vector2(player.global_position.x - vpr.x * 2, player.global_position.y - vpr.y * 2)
	var top_right = Vector2(player.global_position.x + vpr.x * 2, player.global_position.y - vpr.y * 2)
	var bottom_left = Vector2(player.global_position.x - vpr.x * 2, player.global_position.y + vpr.y * 2)
	var bottom_right = Vector2(player.global_position.x + vpr.x * 2, player.global_position.y + vpr.y * 2)
	var pos_side = ["up", "down", "right", "left"].pick_random()
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	return Vector2(x_spawn, y_spawn)