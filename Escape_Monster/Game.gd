extends Node

export (PackedScene) var mob_scene
export (Array) var all_mobs
export (Array) var all_mobs_velocity
var mobLinearVelFactor = 1
signal slowmo_text_change

func _ready():
	$StartPosition.position = get_viewport().size/2

func _process(_delta):
	if $HUD.is_bomb_active:
		if Input.is_action_just_released("ui_select"):
			time_freeze(0.15,1.5)
			get_tree().call_group("mobs", "explode_mob")
			$HUD/PowerIcons/bomb.hide()
			$HUD.is_bomb_active = false

func time_freeze(timescale, duration):
	Engine.time_scale = timescale
	yield( get_tree().create_timer(duration*timescale), "timeout")
	Engine.time_scale = 1.0

func _on_MobTimer_timeout():
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.offset = randi()

	var mob = mob_scene.instance()
	add_child(mob)
	all_mobs.append(mob)

	var direction = mob_spawn_location.rotation + PI / 2

	mob.position = mob_spawn_location.position

	direction += rand_range(-PI / 4, PI / 4)
	mob.rotation = direction

	var velocity = Vector2(rand_range(mob.min_speed, mob.max_speed), 0) * mobLinearVelFactor
	mob.linear_velocity = velocity.rotated(direction)
	all_mobs_velocity.append(mob.linear_velocity)

func _on_HUD_slowmo(is_power_strong):
	if is_power_strong:
		mobLinearVelFactor = 0.4
		emit_signal("slowmo_text_change","Slow\nMonster\n60%")
	else:
		mobLinearVelFactor = 0.7
		emit_signal("slowmo_text_change","Slow\nMonster\n30%")

func _on_ColorRect_item_rect_changed():
	$StartPosition.position = get_viewport().size/2

func _on_Main_game_over():
	mobLinearVelFactor = 1
	
