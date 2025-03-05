extends Area2D

@export var speed := 700 
var damage = 20
var direction := Vector2.ZERO  

func _process(delta):
	if direction != Vector2.ZERO:
		position += direction * speed * delta 

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()  

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage) 
			queue_free()
