extends Sprite2D

@export var speed_increase := 100
@export var boost_duration := 3.0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Picked Up!")
		if body.has_method("apply_speed_boost"):
			body.apply_speed_boost(speed_increase, boost_duration)

		queue_free() 
