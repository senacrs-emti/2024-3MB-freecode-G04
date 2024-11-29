extends CharacterBody2D #12:30

var movement_speed = 160.0
var healph = 100
var maxhealph = 100
var time = 0

var experience = 0
var experience_level = 1
var collected_experience = 0

@onready var anim = $AnimationPlayer

var fireBall = preload("res://Jogador/attacks/fireball.tscn")
@onready var fireBallTimer = get_node("Attack/FireBallTimer")
@onready var fireBallAttackTimer = get_node("Attack/FireBallTimer/FireBallAttackTimer")

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

@onready var deathPanel = get_node("%DeathPanel")
@onready var lblResult = get_node("%lbl_Result")
@onready var sndVictory = get_node("%snd_victory")
@onready var sndLose = get_node("%snd_lose")

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
	if experience_level < 20:
		exp_cap = experience_level+5
	elif experience_level < 40:
		exp_cap + 95 * (experience_level-19)*8
	else:
		exp_cap = 255 + (experience_level-39)*12
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
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			movement_speed += 20.0
		"Cooldown1","Cooldown2","Cooldown3","Cooldown4":
			spell_cooldown += 0.1
		"AttackSize1","AttackSize2","AttackSize3","AttackSize4":
			spell_size += 0.15
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
	#adjust_gui_collection(upgrade)
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
	boss_health()
	time = argtime
	var get_m = int(time/60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str(0,get_m)
	if get_s < 10:
		get_s = str(0,get_s)
	lblTimer.text = str(get_m,":",get_s)

#func adjust_gui_collection(upgrade):
#	var get_upgraded_displayname = UpgradeDb.UPGRADES[upgrade]["display"]
#	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
#	if get_type != "item":
#		var get_collected_displaynames = []
#		for i in collected_upgrades:
#			get_collected_displaynames.append(UpgradeDb.UPGRADES[i]["display"])
#		if not get_upgraded_displayname in get_collected_displaynames:
#			var new_item = itemContainer.instantiate()
#			new_item.upgrade = upgrade
#			match get_type:
#				"weapon":
#					collectedWeapons.add_child(new_item)
#				"upgrade":
#					collectedUpgrades.add_child(new_item)

func death():
	deathPanel.visible = true
	get_tree().paused = true
	var tween = deathPanel.create_tween()
	tween.tween_property(deathPanel,"modulate",Color8(255,255,255,255),5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	if time >= 600:
		lblResult.text = "SINTA-SE CODADO"
		sndVictory.play()
	else:
		lblResult.text = "QUE BAGULHO EM..."
		sndLose.play()

func _on_btn_menu_pressed():
	get_tree().paused = false
	var _level = get_tree().change_scene_to_file("res://MenuScreen/menu.tscn")

func boss_health():
	var tween = healthBarBoss.create_tween()
	if UpgradeDb.boss_presence == true and UpgradeDb.boss_health > 0:
		if UpgradeDb.boss_maxhealth == 150:
			lblBoss.text = "CSS"
		elif UpgradeDb.boss_maxhealth == 200:
			lblBoss.text = "JavaScript"
		tween.tween_property(healthBarBoss,"position",Vector2(256,300),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
		tween.play
		healthBarBoss.max_value = UpgradeDb.boss_maxhealth
		healthBarBoss.value = UpgradeDb.boss_health
	else:
		tween.tween_property(healthBarBoss,"position",Vector2(256,400),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.play
