extends CharacterBody2D

var speed = 100
var player_chase = false
var player = null

func _physics_process(delta: float) -> void:
	if player_chase:
		position += (player.position - position) / speed
		if (player.position.x - position.x < 0):
			$Sprite2D.flip_h = false
		else:
			$Sprite2D.flip_h = true


func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true


func _on_detection_area_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	player = null
	player_chase = false

func damage():
	pass
