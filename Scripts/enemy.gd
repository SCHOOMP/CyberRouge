extends CharacterBody2D

var speed = 100
var health = 100
var player_chase = false
var player = null
@export var damage = 10
@onready var attack_timer = $AttackTimer
var experience_points = 100

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
	player_chase = false
	# player = null

func take_damage(amount: int, attacker = null) -> void:
	health -= amount
	print("Enemy took damage:", amount, "Remaining health:", health)
	if attacker != null and attacker.is_in_group("player"):
		player = attacker
	
	if health <= 0:
		die()

func deal_damage() -> int:
	return damage 

func die():
	print("Enemy defeated!")
	if player and player.has_method("gain_experience"):
		player.gain_experience(experience_points)
		print("Player gained " + str(experience_points) + " XP!")
	queue_free()  

func _on_attack_timer_timeout() -> void:
	if player: 
		if player.has_method("take_damage"):
			player.take_damage(damage)
			print("Enemy attacked! Dealt", damage, "damage to player.")
			
	attack_timer.start()
