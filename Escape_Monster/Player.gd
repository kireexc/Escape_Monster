extends Area2D

signal hit
signal life_up
signal player_died
signal shield_text_change
signal gun_text_change

var defaultSpeed = 400
export (int) var speed = defaultSpeed
var screen_size
export var life = 0
var is_shield_on = false
var bulletPath = preload("res://Bullet.tscn")
var can_fire = false
var rate_fire = 1.3
var is_shield_strong = false
var is_immune = false
var can_immune = true

func _ready():
	screen_size = get_viewport_rect().size
	hide()
	shield_active(false)

func _process(delta):
	
	if is_shield_on:
		$Shield.rotate(0.03)
	
	if Input.is_mouse_button_pressed(1) and can_fire and visible:
		shoot()
	$BulletNode.look_at(get_global_mouse_position())
	
	if is_immune and can_immune:
		player_immunity()
	
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()

	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	if velocity.x != 0:
		$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func shoot():
	can_fire=false
	var bullet = bulletPath.instance()
	bullet.position = $BulletNode/Position2D.global_position
	bullet.rotation = get_angle_to(get_global_mouse_position())
	get_parent().add_child(bullet)
	yield(get_tree().create_timer(rate_fire),"timeout")
	if visible:
		can_fire = true

func _on_HUD_gun(is_power_strong):
	can_fire = true
	if is_power_strong:
		rate_fire = 0.8
		emit_signal("gun_text_change","Strong\nGun")
	else:
		rate_fire = 1.3
		emit_signal("gun_text_change","Weak\nGun")

func _on_Player_body_entered(body):
	if(not body.is_in_group("Bullets")):
		if life > 0 :
			player_hit()
		else:
			emit_signal("player_died")

func player_hit():
	life -= 1
	emit_signal("hit",life)
	$hit.play()
	#immunity frames code
	$ImmunityTimer.start()
	$CollisionShape2D.set_deferred("disabled", true)
	is_immune = true

func player_immunity():
	is_immune = false
	yield(get_tree().create_timer(0.2),"timeout")
	modulate = (Color ("3affffff"))
	yield(get_tree().create_timer(0.2),"timeout")
	modulate = (Color ("ffffff"))
	is_immune = true
	if !can_immune:
		is_immune = false
		can_immune = true
		$CollisionShape2D.set_deferred("disabled", false)

func _on_ImmunityTimer_timeout():
	can_immune = false

func player_dead():
	hide()
	can_fire = false
	$CollisionShape2D.set_deferred("disabled", true)

func shield_active(visibility):
	if visibility:
		$Shield.show()
		shield_type()
		is_shield_on = visibility
		$Shield/ShieldArea/ShieldCollision.set_deferred("disabled", false)
	else:
		$Shield.hide()
		is_shield_on = visibility
		$Shield/ShieldArea/ShieldCollision.set_deferred("disabled", true)

func shield_type():
	if is_shield_strong:
		strong_shield()
		emit_signal("shield_text_change","strong\nshield")
	else:
		weak_shield()
		emit_signal("shield_text_change","weak\nshield")

func _on_game_over():
	#reset variables
	hide()
	shield_active(false)
	life = 0
	speed = defaultSpeed
	is_shield_strong = false
	can_fire = false
	rate_fire = 1.3
	strong_shield()

func strong_shield():
	$Shield.scale = Vector2 (1,1)
	$Shield.modulate = (Color ("ffffff"))

func weak_shield():
	$Shield.scale = Vector2 (0.5,0.5)
	$Shield.modulate = (Color ("7fffffff"))

func _on_HUD_speed_up():
	var speed_factor = 1.3
	speed *= speed_factor

func _on_HUD_life_up(is_power_strong):
	if is_power_strong:
		life+=2
	else:
		life+=1
	emit_signal("life_up",life)

func _on_ShieldArea_body_entered(body):
	# when enemy enter in contact on shield destroy it
	body.queue_free()

func _on_HUD_shield(is_power_strong):
	is_shield_strong = is_power_strong
	shield_active(true)

