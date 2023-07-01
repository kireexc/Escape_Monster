extends Node

var score
var all_mobs_velocity = []
onready var defaultMobTimer = $Game/MobTimer.wait_time
var bool_game_mode_rand
var stage_initial_timer = 10
signal game_over
var game_mode_text = "Game mode 1"
onready var wasd_instruct =  load("res://art/wasd-keys.png")
onready var gun_instruct =  load("res://art/gun_instruct.png")

func _ready():
	randomize()
	bool_game_mode_rand = bool(randi() % 2)
	if bool_game_mode_rand:
		game_mode_text = "Game mode 2"
	$Game/HUD/GameMode.text = game_mode_text + "\nStage 1"
	#setInstructPosition
	$Game/DefaultIntruct.position = $Game/StartPosition.position
	$Game/DefaultIntruct.position.x += -350

func game_over():
	emit_signal("game_over")
	$Game/ScoreTimer.stop()
	$Game/MobTimer.stop()
	$Game/DefaultIntruct.texture = wasd_instruct
	$Game/DefaultIntruct.show()
	$Game/HUD.show_game_over()
	$Game/Player.player_dead()
	$Game/Music.stop()
	$Game/DeathSound.play()

func freeze_node(node, freeze):
	node.set_process(!freeze)
	node.set_physics_process(!freeze)
	node.set_process_input(!freeze)
	node.set_process_internal(!freeze)
	node.set_process_unhandled_input(!freeze)
	node.set_process_unhandled_key_input(!freeze)

func freeze_scene(node, freeze):
	freeze_node(node, freeze)
	for c in node.get_children():
		if !c.is_in_group("mobs"):
			freeze_scene(c, freeze)

func mob_move(should_move):
	if(should_move):
		for i in $Game.all_mobs.size():
			var c = $Game.all_mobs[i]
			var wr = weakref(c)
			if (wr.get_ref()):
				c.apply_central_impulse(all_mobs_velocity[i])
	else:
		#save current mob velocity
		all_mobs_velocity = $Game.all_mobs_velocity
		for c in $Game.all_mobs:
			var wr = weakref(c)
			if (wr.get_ref()):
				c.set_sleeping(true)

func new_game():
	get_tree().call_group("mobs", "queue_free")
	score = 0
	all_mobs_velocity = []
	$Game/DefaultIntruct.hide()
	$Game/HUD/GameMode.text = game_mode_text + "\nStage 1"
	$Game/MobTimer.wait_time = defaultMobTimer
	$Game/Player.start($Game/StartPosition.position)
	$Game/StartTimer.start()
	$Game/HUD.update_score(score)
	$Game/HUD.show_message("Se prepare!")
	$Game/Music.play()

func game_mode(has_loot_box,has_gold_chest,stage):
#	with loot box or without loot box
	if(has_loot_box):
		freeze_scene($Game, true)
		mob_move(false)
		$LootBox.start($Game/StartPosition.position,has_gold_chest)
		yield($LootBox/Button, "pressed")
		$LootBox.hide()
		mob_move(true)
		freeze_scene($Game, false)
	else:
		game_mode_default(stage)

func game_mode_default(stage):
	match stage:
		1:
			$LootBox.emit_signal("powerUp_reward","heart",false)
		2:
			$LootBox.emit_signal("powerUp_reward","shield_icon",false)
		3:
			$LootBox.emit_signal("powerUp_reward","gun",false)
			$Game/DefaultIntruct.texture = gun_instruct
			$Game/DefaultIntruct.show()
			yield(get_tree().create_timer(2.5), "timeout")
			$Game/DefaultIntruct.hide()
		4:
			$LootBox.emit_signal("powerUp_reward","slowmo",false)

func _on_ScoreTimer_timeout():
	#define stages
	score += 1
	$Game/HUD.update_score(score)
	if (score == stage_initial_timer):
		game_mode(bool_game_mode_rand,false,1)
		$Game/HUD.show_message("Stage 2")
		$Game/HUD/GameMode.text = game_mode_text + "\nStage 2"
		$Game/MobTimer.wait_time /= 1.3
	if (score == stage_initial_timer+10):
		game_mode(bool_game_mode_rand,false,2)
		$Game/HUD.show_message("Stage 3")
		$Game/HUD/GameMode.text = game_mode_text + "\nStage 3"
		$Game/MobTimer.wait_time /= 1.4
	if (score == stage_initial_timer+30):
		game_mode(bool_game_mode_rand,true,3)
		$Game/HUD.show_message("Stage 4")
		$Game/HUD/GameMode.text = game_mode_text + "\nStage 4"
		$Game/MobTimer.wait_time /= 1.4
	if(score == stage_initial_timer+50):
		game_mode(bool_game_mode_rand,true,4)
		$Game/HUD.show_message("Final Stage")
		$Game/HUD/GameMode.text = game_mode_text + "\nFinal Stage"
		$Game/MobTimer.wait_time /= 1.5
	if(score == stage_initial_timer+80):
		$Game/HUD/ScoreLabel.text = "Você Venceu!!"
		game_over()

func _on_StartTimer_timeout():
	$Game/MobTimer.start()
	$Game/ScoreTimer.start()
