extends Area2D

@export var speed := 700  # Bullet speed
var direction := Vector2.ZERO  # Movement direction

func _process(delta):
	if direction != Vector2.ZERO:
		position += direction * speed * delta  # Move bullet forward

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()  # Remove bullet when it leaves the screen
