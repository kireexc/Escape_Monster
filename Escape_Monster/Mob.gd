extends RigidBody2D

export var min_speed = 150
export var max_speed = 250

func _ready():
	$explosion.hide()
	$AnimatedSprite.playing = true
	var mob_types = $AnimatedSprite.frames.get_animation_names()
	$AnimatedSprite.animation = mob_types[randi() % mob_types.size()]

func explode_mob():
	$explosion.show()
	$explosion.play()
	$explosion/explosionSound.play()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_start_game():
	queue_free()

func _on_explosion_animation_finished():
	queue_free()
