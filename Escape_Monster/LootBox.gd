extends Node2D
var initial_speed_factor
var has_gold_chest
var player_has_bomb = false
onready var default_animationPI = $PowerIcon.frames.duplicate()
onready var default_speed_scale =  $PowerIcon.speed_scale
onready var bombIconFrame =  load("res://art/bomb.png")
onready var spacebar_instruct =  load("res://art/spacebar_instruct.png")
onready var gun_instruct =  load("res://art/gun_instruct.png")

signal powerUp_reward

func _ready():
	hide()

func start(pos,gold_chest):
	reset()
	position = pos
	has_gold_chest = gold_chest
	show()
	if(has_gold_chest):
		$Sprite.play("gold")
		#powers exclusive to gold chest!
		if !player_has_bomb: #only one bomb at time!
			$PowerIcon.frames.add_frame("icons",bombIconFrame)
	else:
		$Sprite.play("default")

func _on_Sprite_animation_finished():
	$Flash.show()
	$Flash.play("flash")
	$PowerIcon.show()
	$PowerIcon.play("icons")

func _on_PowerIcon_frame_changed():
	if $PowerIcon.playing:
		$PowerIcon.speed_scale += -initial_speed_factor
		$PowerIcon/tick.play()
		if $PowerIcon.speed_scale < 0.25:
			$PowerIcon.stop()
			$Button.show()
			var frame_name = $PowerIcon.frames.get_frame("icons",$PowerIcon.frame).get_path().get_file().trim_suffix(".png")
			choose_instruction_type(frame_name)
			yield($Button, "pressed")
			emit_signal("powerUp_reward",frame_name,has_gold_chest)

func choose_instruction_type(frame_name):
	match frame_name:
		"bomb":
			$Instruction.texture=spacebar_instruct
			$Instruction.show()
		"gun":
			$Instruction.texture=gun_instruct
			$Instruction.show()

func reset():
	#reset all
	$PowerIcon.speed_scale = default_speed_scale
	$Sprite.frame = 0
	$Flash.frame = 0
	player_has_bomb = false
	$Button.hide()
	$Flash.hide()
	$PowerIcon.hide()
	$Instruction.hide()
	randomize()
	initial_speed_factor = rand_range(0.15,0.3)

func _on_HUD_speed_up():
	$PowerIcon.frames.remove_frame ("icons",$PowerIcon.frame)

func _on_HUD_shield(_is_power_strong):
	$PowerIcon.frames.remove_frame ("icons",$PowerIcon.frame)

func _on_HUD_slowmo(_is_power_strong):
	$PowerIcon.frames.remove_frame ("icons",$PowerIcon.frame)

func _on_HUD_gun(_is_power_strong):
	$PowerIcon.frames.remove_frame ("icons",$PowerIcon.frame)

func _on_HUD_start_game():
	$PowerIcon.set_sprite_frames(default_animationPI.duplicate())

func _on_HUD_bomb():
	player_has_bomb = true
