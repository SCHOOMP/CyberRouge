extends Area2D

@export var speed := 700 
var damage = 10
var direction := Vector2.ZERO  

func _process(delta):
	if direction != Vector2.ZERO:
		position += direction * speed * delta
		rotation = direction.angle()  # Rotate the bullet in the direction it's moving

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()  

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			var player = get_tree().get_first_node_in_group("player")
			body.take_damage(damage, player)
			queue_free()
