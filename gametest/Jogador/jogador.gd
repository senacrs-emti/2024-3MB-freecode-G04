extends CharacterBody2D

var movement_speed = 160.0
var healph = 100
var maxhealph = 100
var time = 0

var experience = 0
var experience_level = 1
var collected_experience = 0

@onready var anim = $AnimationPlayer

var fireBall = preload("res://Jogador/attacks/fireball.tscn")
var ice_spear = preload("res://Jogador/attacks/ice.tscn")
var tornado = preload("res://Jogador/attacks/tornado.tscn")
var thunder = preload("res://Jogador/attacks/thunder.tscn") 
var veneno = preload("res://Jogador/attacks/poison.tscn")

@onready var fireBallTimer = get_node("Attack/FireBallTimer")
@onready var fireBallAttackTimer = get_node("Attack/FireBallTimer/FireBallAttackTimer")

@onready var IceTimer = get_node("%IceTimer")
@onready var IceAttackTimer = get_node("%IceAttackTimer")

@onready var TornadoTimer = get_node("%TornadoTimer")
@onready var TornadoAttackTimer = get_node("%TornadoAttackTimer")

@onready var VenenoTimer = get_node("%VenenoTimer")
@onready var VenenoAttackTimer = get_node("%VenenoAttackTimer")

@onready var thunderBase = get_node("%thunderBase")
@onready var thunderTimer = get_node("%ThunderTimer")
@onready var thunderAttackTimer = get_node("%ThunderAttackTimer")

var last_movement = Vector2.UP
var collected_upgrades = []
var upgrade_options = []
var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0

var fireball_ammo = 0
var fireball_baseammo = 0
var fireball_attackspeed = 1.5
var fireball_level = 0

var ice_ammo = 0
var ice_baseammo = 0
var ice_attackspeed = 1.5
var ice_level = 0

var thunder_ammo = 0
var thunder_baseammo = 0
var thunder_attackspeed = 10
var thunder_level = 0

var tornado_ammo = 0
var tornado_baseammo = 0
var tornado_attackspeed = 3
var tornado_level = 0

var veneno_ammo = 0
var veneno_baseammo = 0
var veneno_attackspeed = 1.5
var veneno_level = 0

var enemy_close = []

@onready var sprite = $Sprite2D

#GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var itemOptions = preload("res://Utilidade/item_option.tscn")
@onready var sndLevelUp = get_node("%snd_levelup")
@onready var healthBar = get_node("%HealthBar")
@onready var healthBarBoss = get_node("%HealthBarBoss")
@onready var lblBoss = get_node("%lbl_Boss")
@onready var lblTimer = get_node("%lblTimer")
@onready var collectedWeapons = get_node("%CollectedWeapons")
@onready var collectedUpgrades = get_node("%CollectedUpgrades")
@onready var itemContainer = preload("res://Jogador/GUI/item_container.tscn")
@onready var bossScene = get_node("%BossScene")
@onready var bossImg = get_node("%BossImg")
@onready var deathPanel = get_node("%DeathPanel")
@onready var lblResult = get_node("%lbl_Result")
@onready var sndVictory = get_node("%snd_victory")
@onready var sndLose = get_node("%snd_lose")
@onready var victoryPanel = get_node("%VictoryPanel")
@onready var paperVictory = get_node("%paperTexture")
@onready var bookVictory = get_node("%bookTexture")
@onready var backgroundVictory = get_node("%background")

func _ready():
	upgrade_character("fireball1")
	attack()
	set_bar(experience, calculate_experiencecap())
	_on_hurt_box_hurt(0,0,0)

func _physics_process(delta):
	movement()

func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov,y_mov)
	if mov.x > 0:
		sprite.flip_h = false
	elif mov.x < 0:
		sprite.flip_h = true
	if mov.y > 0:
		sprite.region_rect = Rect2(512,0,32,31)
		anim.play("walkFront")
	elif mov.y < 0:
		sprite.region_rect = Rect2(0,0,32,31)
		anim.play("walkBack")
	velocity = mov.normalized()*movement_speed
	move_and_slide()

func attack():
	if fireball_level > 0:
		fireBallTimer.wait_time = fireball_attackspeed * (1-spell_cooldown)
		if fireBallTimer.is_stopped():
			fireBallTimer.start()
	if tornado_level > 0:
		TornadoTimer.wait_time = tornado_attackspeed * (1-spell_cooldown)
		if TornadoTimer.is_stopped():
			TornadoTimer.start()
	if thunder_level > 0:
		thunderTimer.wait_time = thunder_attackspeed * (1-spell_cooldown)
		if thunderTimer.is_stopped():
			thunderTimer.start()
	if ice_level > 0:
		IceTimer.wait_time = ice_attackspeed * (1-spell_cooldown)
		if IceTimer.is_stopped():
			IceTimer.start()
	if veneno_level > 0:
		VenenoTimer.wait_time = veneno_attackspeed * (1-spell_cooldown)
		if VenenoTimer.is_stopped():
			VenenoTimer.start()

func _on_hurt_box_hurt(damage, _angle, _knockback):
	healph -= clamp(damage-armor, 1.0, 999.00)
	healthBar.max_value = maxhealph
	healthBar.value = healph
	if healph <= 0:
		death()


func _on_fire_ball_timer_timeout():
	fireball_ammo += fireball_baseammo + additional_attacks
	fireBallAttackTimer.start()


func _on_fire_ball_attack_timer_timeout():
	if fireball_ammo > 0:
		var fireball_attack = fireBall.instantiate()
		fireball_attack.position = position
		fireball_attack.target = get_random_target()
		fireball_attack.level = fireball_level
		add_child(fireball_attack)
		fireball_ammo -= 1
		if fireball_ammo > 0:
			fireBallAttackTimer.start()
		else:
			fireBallAttackTimer.stop()

func _on_ice_timer_timeout():
	ice_ammo += ice_baseammo + additional_attacks
	IceAttackTimer.start()

func _on_ice_attack_timer_timeout():
	if ice_ammo > 0:
		var ice_attack = ice_spear.instantiate()
		ice_attack.position = position
		ice_attack.target = get_random_target()
		ice_attack.level = ice_level
		add_child(ice_attack)
		ice_ammo -= 1
		if ice_ammo > 0:
			IceAttackTimer.start()
		else:
			IceAttackTimer.stop()
	
func _on_veneno_timer_timeout():
	veneno_ammo += veneno_baseammo + additional_attacks
	VenenoAttackTimer.start()

func _on_veneno_attack_timer_timeout():
	if veneno_ammo > 0:
		var veneno_attack = veneno.instantiate()
		veneno_attack.position = position
		veneno_attack.target = get_random_target()
		veneno_attack.level = veneno_level
		add_child(veneno_attack)
		veneno_ammo -= 1
		if veneno_ammo > 0:
			VenenoAttackTimer.start()
		else:
			VenenoAttackTimer.stop()

func _on_tornado_timer_timeout():
	tornado_ammo += tornado_baseammo + additional_attacks
	TornadoAttackTimer.start()

func _on_tornado_attack_timer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			TornadoAttackTimer.start()
		else:
			TornadoAttackTimer.stop()

func _on_thunder_timer_timeout():
	thunder_ammo += thunder_baseammo + additional_attacks
	thunderAttackTimer.start()

func _on_thunder_attack_timer_timeout():
	spawn_thunder()

func spawn_thunder():
	var thunder_spawn = thunder.instantiate()
	thunder_spawn.global_position = global_position
	thunder_spawn.level = thunder_level
	thunderBase.add_child(thunder_spawn)
	thunder_ammo -= 1
	if thunder_ammo > 0:
		thunderAttackTimer.start()
	else:
		thunderAttackTimer.stop()

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP


func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)


func _on_grab_area_area_entered(area):
	if area.is_in_group("loot") or area.is_in_group("loot_health"):
		area.target = self

func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)
	if area.is_in_group("loot_health"):
		var regen_health = area.collect()
		healph += 20
		if healph > maxhealph:
			healph = maxhealph
		healthBar.value = healph

func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required:
		collected_experience -= exp_required-experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experiencecap()
		levelup()
	else: 
		experience += collected_experience
		collected_experience = 0
	set_bar(experience, exp_required)

func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 6:
		exp_cap = experience_level+5
	elif experience_level < 16:
		exp_cap + 95 * (experience_level-19)*8
	else:
		exp_cap = 255 + (experience_level-39)*10
	return exp_cap

func set_bar(set_value = 1, set_max_value = maxhealph):
	expBar.value = set_value
	expBar.max_value = set_max_value

func levelup():
	#sndLevelUp.play()
	lblLevel.text = str("Level: ",experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel,"position",Vector2(220,50),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	get_tree().paused = true

func upgrade_character(upgrade):
	match upgrade:
		"fireball1":
			fireball_level = 1
			fireball_baseammo += 1
		"fireball2":
			fireball_level = 2
			fireball_baseammo += 1
		"fireball3":
			fireball_level = 3
		"fireball4":
			fireball_level = 4
			fireball_baseammo += 2
		"ice1":
			ice_level = 1
			ice_baseammo += 1
		"ice2":
			ice_level = 2
			ice_baseammo += 1
		"ice3":
			ice_level = 3
			ice_baseammo += 1
		"ice4":
			ice_level = 4
		"sand1":
			tornado_level = 1
			tornado_baseammo += 1
		"sand2":
			tornado_level = 2
			tornado_baseammo += 1
		"sand3":
			tornado_level = 3
		"sand4":
			tornado_level = 4
			tornado_baseammo += 1
		"thunder1":
			thunder_level = 1
			thunder_baseammo += 1
		"thunder2":
			thunder_level = 2
		"thunder3":
			thunder_level = 3
			thunder_baseammo += 1
		"thunder4":
			thunder_level = 4
		"poison1":
			veneno_level = 1
			veneno_baseammo += 1
		"poison2":
			veneno_level = 2
		"poison3":
			veneno_level = 3
			veneno_baseammo += 2
		"poison4":
			veneno_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			movement_speed += 20.0
		"Cooldown1","Cooldown2","Cooldown3","Cooldown4":
			spell_cooldown += 0.02
		"AttackSize1","AttackSize2","AttackSize3","AttackSize4":
			spell_size += 0.05
		"MaxHealth1","MaxHealth2","MaxHealth3","MaxHealth4":
			maxhealph += 15
			healthBar.max_value = maxhealph
		"Critic1","Critic2","Critic3","Critic4":
			UpgradeDb.critic_chance += 1
		"food":
			healph += 20
			if healph > maxhealph:
				healph = maxhealph
			healthBar.value = healph
			maxhealph = clamp(healph,0,maxhealph)
	adjust_gui_collection(upgrade)
	attack()
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(800,50)
	get_tree().paused = false
	calculate_experience(0)

func get_random_item():
	var dblist = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades:
			pass
		elif i in upgrade_options:
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item":
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0:
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					to_add = false
			if to_add:
				dblist.append(i)
		else:
			dblist.append(i)
	if dblist.size() > 0:
		var randomitem = dblist.pick_random()
		upgrade_options.append(randomitem)
		return randomitem
	else:
		return null

func change_time(argtime = 0):
	victory()
	boss_health()
	time = argtime
	var get_m = int(time/60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str(0,get_m)
	if get_s < 10:
		get_s = str(0,get_s)
	lblTimer.text = str(get_m,":",get_s)
	if time <= 1:
		healthBarBoss.visible = false
		UpgradeDb.boss_presence = false
	if time == 359:
		bossImg.visible = true
		bossScene.visible = true
		get_tree().paused = true
		var tween2 = bossScene.create_tween()
		tween2.tween_property(bossScene,"self_modulate",Color8(0,0,0,255),2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween2.play()
		await get_tree().create_timer(2).timeout
		var tween = bossImg.create_tween()
		tween.tween_property(bossImg,"self_modulate",Color8(255,255,255,255),2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.play()
		await get_tree().create_timer(5).timeout
		get_tree().paused = false
		bossImg.visible = false
		bossScene.visible = false

func adjust_gui_collection(upgrade):
	var get_upgraded_displayname = UpgradeDb.UPGRADES[upgrade]["display"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if get_type != "item":
		var get_collected_displaynames = []
		for i in collected_upgrades:
			get_collected_displaynames.append(UpgradeDb.UPGRADES[i]["display"])
		if not get_upgraded_displayname in get_collected_displaynames:
			var new_item = itemContainer.instantiate()
			new_item.upgrade = upgrade
			match get_type:
				"weapon":
					collectedWeapons.add_child(new_item)
				"upgrade":
					collectedUpgrades.add_child(new_item)

func death():
	deathPanel.visible = true
	get_tree().paused = true
	anim.play("dead")
	await get_tree().create_timer(5).timeout
	var tween = deathPanel.create_tween()
	tween.tween_property(deathPanel,"modulate",Color8(255,255,255,255),5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	lblResult.text = "QUE BAGULHO EM..."
	sndLose.play()

func victory():
	if time > 360 and UpgradeDb.finalboss_presence == false:
		victoryPanel.visible = true
		get_tree().paused = true
		var tween = backgroundVictory.create_tween()
		tween.tween_property(backgroundVictory,"self_modulate",Color8(0,0,0,255),3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.play()
		await get_tree().create_timer(1).timeout
		var tween2 = bookVictory.create_tween()
		tween2.tween_property(bookVictory,"self_modulate",Color8(255,255,255,255),2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween2.play()
		await get_tree().create_timer(1).timeout
		var tween3 = paperVictory.create_tween()
		tween3.tween_property(paperVictory,"modulate",Color8(255,255,255,255),1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween3.play()
		sndVictory.play()

func _on_btn_menu_victory_pressed():
	get_tree().paused = false
	var _level = get_tree().change_scene_to_file("res://MenuScreen/menu.tscn")

func _on_btn_menu_pressed():
	get_tree().paused = false
	var _level = get_tree().change_scene_to_file("res://MenuScreen/menu.tscn")

func boss_health():
	healthBarBoss.visible = true
	var tween = healthBarBoss.create_tween()
	if UpgradeDb.boss_presence == true and UpgradeDb.boss_health > 0:
		if UpgradeDb.boss_maxhealth == 300:
			lblBoss.text = "CSS"
		elif UpgradeDb.boss_maxhealth == 600:
			lblBoss.text = "JavaScript"
		elif UpgradeDb.boss_maxhealth == 1000:
			lblBoss.text = "PHP"
		tween.tween_property(healthBarBoss,"position",Vector2(256,300),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
		tween.play
		healthBarBoss.max_value = UpgradeDb.boss_maxhealth
		healthBarBoss.value = UpgradeDb.boss_health
	else:
		tween.tween_property(healthBarBoss,"position",Vector2(256,400),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.play
