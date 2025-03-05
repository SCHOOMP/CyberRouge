extends CharacterBody2D

var speed = 100
var health = 100
var player_chase = false
var player = null
@export var damage = 10
@onready var attack_timer = $AttackTimer

func _physics_process(delta: float) -> void:
	if player_chase:
		position += (player.position - position) / speed
		if (player.position.x - position.x < 0):
			$Sprite2D.flip_h = false
		else:
			$Sprite2D.flip_h = true

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		player = body
		player_chase = true

func _on_detection_area_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	player = null
	player_chase = false

func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy took damage:", amount, "Remaining health:", health)
	if health <= 0:
		die()

func deal_damage() -> int:
	return damage 

func die():
	print("Enemy defeated!")
	queue_free()

func _on_attack_timer_timeout() -> void:
	if player: 
		if player.has_method("take_damage"):
			player.take_damage(damage)
			print("Enemy attacked! Dealt", damage, "damage to player.")

	attack_timer.start()
