extends Sprite2D

@export var speed_increase := 100  # Extra speed boost
@export var boost_duration := 3.0  # Duration of the boost in seconds

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Picked Up!")

		# Apply speed boost if the player has the method
		if body.has_method("apply_speed_boost"):
			body.apply_speed_boost(speed_increase, boost_duration)

		queue_free()  # Remove the pickup after collection
