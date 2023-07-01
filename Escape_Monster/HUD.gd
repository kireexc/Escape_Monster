extends CanvasLayer

signal start_game
signal speed_up
signal life_up
signal shield
signal slowmo
signal bomb
signal gun
enum powerUps {heart,shield_icon,speedUP,slowmo,gun,bomb}

export var is_bomb_active = false

func _ready():
	$PowerIcons/SpeedPowerUp.hide()
	$PowerIcons/LiveUp.hide()
	$PowerIcons/Shield.hide()
	$PowerIcons/bomb.hide()
	$PowerIcons/SlowMo.hide()
	$PowerIcons/Gun.hide()

func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	yield($MessageTimer, "timeout")
	$MessageLabel.text = "Escape dos\ninimigos!"
	$MessageLabel.show()
	yield(get_tree().create_timer(1), "timeout")
	$StartButton.show()

func update_score(score):
	$ScoreLabel.text = str(score)

func _on_StartButton_pressed():
	$StartButton.hide()
	emit_signal("start_game")

func _on_MessageTimer_timeout():
	$MessageLabel.hide()

func _on_game_over():
	$PowerIcons/SpeedPowerUp.hide()
	$PowerIcons/LiveUp.hide()
	$PowerIcons/Shield.hide()
	$PowerIcons/bomb.hide()
	$PowerIcons/SlowMo.hide()
	$PowerIcons/Gun.hide()
	is_bomb_active = false

func _on_Player_hit(life):
	live_label_update(life)
	if(life<1):
		$PowerIcons/LiveUp.hide()

func _on_Player_life_up(life):
	live_label_update(life)

func live_label_update(life):
	$PowerIcons/LiveUp/LiveUpLabel.text = str(life) + " Up"

func _on_LootBox_powerUp_reward(reward,has_gold_chest):
	var is_power_strong = has_gold_chest
	if typeof(reward) == TYPE_STRING:
		reward = powerUps.get(reward)
	match reward:
		powerUps.heart:
			$PowerIcons/LiveUp.show()
			emit_signal("life_up",is_power_strong)
		powerUps.shield_icon:
			$PowerIcons/Shield.show()
			emit_signal("shield",is_power_strong)
		powerUps.speedUP:
			$PowerIcons/SpeedPowerUp.show()
			emit_signal("speed_up")
		powerUps.slowmo:
			$PowerIcons/SlowMo.show()
			emit_signal("slowmo",is_power_strong)
		powerUps.gun:
			$PowerIcons/Gun.show()
			emit_signal("gun",is_power_strong)
		powerUps.bomb:
			$PowerIcons/bomb.show()
			is_bomb_active = true
			emit_signal("bomb")

func _on_Player_shield_text_change(text):
	$PowerIcons/Shield/ShieldLabel.text = text

func _on_Game_slowmo_text_change(text):
	$PowerIcons/SlowMo/SlowMoLabel.text = text
	
func _on_Player_gun_text_change(text):
	$PowerIcons/Gun/GunLabel.text = text
