extends CharacterBody2D

# ====================
# === Player Stats ===
# ====================

@export var health: int = 100
@export var speed: float = 400
@export var base_speed: float = 400
@export var dash_speed: float = 600
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.5
@export var friction: float = 0.01
@export var acceleration: float = 0.1

var boost_timer: float = 0.0
var player_alive: bool = true
var last_direction: Vector2 = Vector2.ZERO

# =====================
# === Dash Handling ===
# =====================

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0

# ======================
# === Melee Attacks ====
# ======================

@export var melee_range: float = 50.0
@export var melee_damage: int = 20
@export var melee_cooldown_time: float = 0.5
var melee_cooldown_timer: float = 0.0

# ============================
# === Experience & Leveling ==
# ============================

@export var level: int = 1
var experience: int = 0
var experience_total: int = 0
var experience_required: int = get_required_experiance(level + 1)

# ========================
# === Scene References ===
# ========================

@onready var bullet_scene = preload("res://Scenes/bullet_scene.tscn")
@onready var firePoint = $FirePoint

# ===================
# === Misc States ===
# ===================

var enemy_in_attack_range: bool = false
var attack_cooldown: bool = true

# ================================
# === Game Loop / Physics Tick ===
# ================================

func _physics_process(delta: float) -> void:
	# Check for death
	if health <= 0:
		player_alive = false
		health = 0
		print("Player Killed")
		queue_free()
		return

	# Read player input
	var direction = get_input()

	# Handle boost reset
	if boost_timer > 0:
		boost_timer -= delta
		if boost_timer <= 0:
			speed = base_speed

	# Handle dash movement
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

	# Update cooldowns
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	if melee_cooldown_timer > 0:
		melee_cooldown_timer -= delta

	# Apply movement
	move_and_slide()

# ======================
# === Player Actions ===
# ======================

func get_input() -> Vector2:
	var input = Vector2()

	# Movement input
	if Input.is_action_pressed("Right"):
		input.x += 1
	if Input.is_action_pressed("Left"):
		input.x -= 1
	if Input.is_action_pressed("Down"):
		input.y += 1
	if Input.is_action_pressed("Up"):
		input.y -= 1

	# Fire projectile
	if Input.is_action_just_pressed("Primary"):
		shoot()

	# Melee attack
	if Input.is_action_just_pressed("Melee"):
		melee()

	# Dash
	if Input.is_action_just_pressed("Dash") and dash_cooldown_timer <= 0:
		start_dash()

	return input

func start_dash() -> void:
	# Trigger a directional dash if moving
	if last_direction != Vector2.ZERO:
		is_dashing = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown
		velocity = last_direction * dash_speed

func shoot() -> void:
	# Fire a bullet toward mouse position
	var bullet = bullet_scene.instantiate()
	bullet.global_position = firePoint.global_position
	bullet.direction = (get_global_mouse_position() - firePoint.global_position).normalized()
	get_parent().add_child(bullet)

func melee() -> void:
	# Melee attack using a circular area around the player
	if melee_cooldown_timer > 0:
		return

	var space_state = get_world_2d().direct_space_state

	var shape = CircleShape2D.new()
	shape.radius = melee_range

	var shape_params = PhysicsShapeQueryParameters2D.new()
	shape_params.shape = shape
	shape_params.transform = Transform2D(0, global_position)
	shape_params.collision_mask = 1  # Change this based on your enemy layer
	shape_params.exclude = [self]

	# Damage all enemies within melee range
	var result = space_state.intersect_shape(shape_params)
	for item in result:
		var body = item.get("collider")
		if body and body.has_method("take_damage"):
			body.take_damage(melee_damage)

	melee_cooldown_timer = melee_cooldown_time

# =========================
# === Health Management ===
# =========================

func apply_health(amount: float) -> void:
	# Heal the player
	health += amount
	print("Health healed! Health:", health)

func take_damage(amount: int) -> void:
	# Take damage and die if below zero
	health -= amount
	print("Player took damage:", amount, "Remaining health:", health)
	if health <= 0:
		die()

func die() -> void:
	# Handle death
	print("Player has died!")
	queue_free()

# =========================
# === Buffs / Temporary ===
# =========================

func apply_speed_boost(amount: float, duration: float) -> void:
	# Temporarily increase movement speed
	speed += amount
	boost_timer = duration
	print("Speed Boosted! New speed:", speed)

# =============================
# === Experience & Leveling ===
# =============================

func gain_experience(amount: int) -> void:
	# Gain EXP and level up when enough is gathered
	experience_total += amount
	experience += amount

	while experience >= experience_required:
		experience -= experience_required
		level_up()

func level_up() -> void:
	# Level up and recalculate required EXP
	level += 1
	print("Leveled Up!")
	experience_required = get_required_experiance(level + 1)

func get_required_experiance(level: int) -> int:
	# EXP curve formula
	return round(pow(level, 1.8) + level * 4)

# ==========================
# === Collision Handling ===
# ==========================

func _on_hitbox_body_entered(body: Node2D) -> void:
	# Get damaged if the entering body deals damage
	if body.has_method("deal_damage"):
		take_damage(body.deal_damage())

func _on_hitbox_body_exited(body: Node2D) -> void:
	# Reset enemy-in-range flag (optional usage)
	if body.has_method("deal_damage"):
		enemy_in_attack_range = false
