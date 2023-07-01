extends RigidBody2D

var speed = 300

func _ready():
	linear_velocity = Vector2(speed,0).rotated(rotation)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Area2D_body_entered(body):
	body.queue_free()
	queue_free()
