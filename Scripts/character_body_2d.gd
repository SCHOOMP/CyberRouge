extends CharacterBody2D

@export var speed = 200
@export var dash_speed = 600  # Speed boost during dash
@export var dash_duration = 0.2  # How long dash lasts (seconds)
@export var dash_cooldown = 0.5  # Time before dashing again
@export var friction = 0.01
@export var acceleration = 0.1

@onready var bullet_scene = preload("res://Scenes/bullet_scene.tscn")
@onready var firePoint = $FirePoint  # Reference to the Muzzle node
@onready var speed_label = $HUD/SpeedLabel

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
	speed += amount  # Temporarily increase speed
	boost_timer = duration  # Set boost timer
	update_speed_display()  # Update UI
	print("Speed Boosted! New speed:", speed)

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
	
	# Dash logic
	if Input.is_action_just_pressed("Dash") and dash_cooldown_timer <= 0:
		start_dash()
	return input

func start_dash():
	if last_direction != Vector2.ZERO:  # Only dash if there's movement
		is_dashing = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown
		velocity = last_direction * dash_speed  # Apply burst of speed

func _physics_process(delta):
	if (health <= 0):
		player_alive = false
		health = 0
		self.queue_free()
		print('Player Killed')
	var direction = get_input()
	take_damage()

	# Speed boost timer logic
	if boost_timer > 0:
		boost_timer -= delta
		if boost_timer <= 0:
			speed = base_speed  # Reset speed
			update_speed_display()  # Update UI when speed resets

	# Dash logic
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false  # Stop dashing
	else:
		if direction.length() > 0:
			last_direction = direction.normalized()  # Store last direction
			velocity = velocity.lerp(direction.normalized() * speed, acceleration)
		else:
			velocity = velocity.lerp(Vector2.ZERO, friction)

	# Dash cooldown timer
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	move_and_slide() 
	update_speed_display()  # Continuously update speed on screen

func shoot():
	var bullet = bullet_scene.instantiate()  # Create bullet instance
	bullet.global_position = firePoint.global_position  # Spawn from muzzle position
	bullet.direction = (get_global_mouse_position() - firePoint.global_position).normalized()  # Set direction
	get_parent().add_child(bullet)  # Add bullet to the scene

func update_speed_display() -> void:
	if speed_label:
		speed_label.text = "Speed: " + str(speed)  # Update UI speed text


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("damage"):
		enemy_in_attack_range = true
		
func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("damage"):
		enemy_in_attack_range = false
		
func take_damage():
	if enemy_in_attack_range and attack_cooldown:
		health = health - 20
		attack_cooldown = false
		$AttackCooldown.start()
		print(health)
	


func _on_attack_cooldown_timeout() -> void:
	attack_cooldown = true
