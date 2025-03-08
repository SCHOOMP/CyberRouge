extends CharacterBody2D

@export var speed = 400
@export var dash_speed = 600 
@export var dash_duration = 0.2 
@export var dash_cooldown = 0.5 
@export var friction = 0.01
@export var acceleration = 0.1
@export var level = 1
var experience = 0
var experience_total = 0
var experience_required = get_required_experiance(level + 1)
@onready var bullet_scene = preload("res://Scenes/bullet_scene.tscn")
@onready var firePoint = $FirePoint
var enemy_in_attack_range = false
var attack_cooldown = true
var health = 100
var player_alive = true
var last_direction = Vector2.ZERO
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
@export var base_speed := 200
var boost_timer := 0.0

func apply_speed_boost(amount: float, duration: float) -> void:
	speed += amount
	boost_timer = duration
	print("Speed Boosted! New speed:", speed)
	
func apply_health(amount: float) -> void:
	health += amount
	print("Health healed! Health:", health)

func get_input():
	var input = Vector2()
	if Input.is_action_pressed('Right'):
		input.x += 1
	if Input.is_action_pressed('Left'):
		input.x -= 1
	if Input.is_action_pressed('Down'):
		input.y += 1
	if Input.is_action_pressed('Up'):
		input.y -= 1
	if Input.is_action_just_pressed("Primary"):
		shoot()
	
	if Input.is_action_just_pressed("Dash") and dash_cooldown_timer <= 0:
		start_dash()
	return input

func start_dash():
	if last_direction != Vector2.ZERO:
		is_dashing = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown
		velocity = last_direction * dash_speed

func _physics_process(delta):
	if health <= 0:
		player_alive = false
		health = 0
		queue_free()
		print('Player Killed')

	var direction = get_input()

	if boost_timer > 0:
		boost_timer -= delta
		if boost_timer <= 0:
			speed = base_speed

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	else:
		if direction.length() > 0:
			last_direction = direction.normalized()
			velocity = velocity.lerp(direction.normalized() * speed, acceleration)
		else:
			velocity = velocity.lerp(Vector2.ZERO, friction)
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	move_and_slide()

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = firePoint.global_position
	bullet.direction = (get_global_mouse_position() - firePoint.global_position).normalized()
	get_parent().add_child(bullet)

# Function to take damage
func take_damage(amount: int) -> void:
	health -= amount
	print("Player took damage:", amount, "Remaining health:", health)

	if health <= 0:
		die()

func die():
	print("Player has died!")
	queue_free()  # Removes the player from the game

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("deal_damage"):
		take_damage(body.deal_damage())

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("deal_damage"):
		enemy_in_attack_range = false
		
func get_required_experiance(level):
	return round(pow(level, 1.8) + level * 4)

func gain_experience(amount):
	experience_total += amount
	experience += amount
	while experience >= experience_required:
		experience -= experience_required
		level_up()
		
func level_up():
	level += 1
	print("leveled Up!")
	experience_required = get_required_experiance(level + 1)
	
