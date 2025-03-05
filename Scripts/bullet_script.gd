extends Area2D

@export var speed := 700 
var damage
var direction := Vector2.ZERO  

func _process(delta):
	if direction != Vector2.ZERO:
		position += direction * speed * delta 

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()  

	
