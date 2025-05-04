extends Sprite2D

@export var health_increase := 40
@export var boost_duration := 3.0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Picked Up!")
		if body.has_method("apply_health"):
			body.apply_health(health_increase)

		queue_free() 
