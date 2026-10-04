extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_sfx = $PlayerSFX

const SFX_JUMP = preload("res://assets/sounds/GoatJumpsfx.wav")
const SFX_WALK = preload("res://assets/sounds/GoatWalksfx.wav")
const SFX_HURT = preload("res://assets/sounds/GompeiGetsHurt.wav")
const SFX_FIRE = preload("res://assets/sounds/GomepiFireAbility.wav")
const SFX_Statue = preload("res://assets/sounds/GompeiTurnsIntoStatue.wav")
const SFX_Jetpack = preload("res://assets/sounds/GompeiJetpackAbility.wav")
const SFX_UFO = preload("res://assets/sounds/UFOAbsorbing.wav")

const SPEED = 130.0
const ACCELERATION = 300.0
const JUMP_VELOCITY = -350.0
const BUMP_VELOCITY = -150.0
const BUMP_MULT = -0.5
const CHARGE_MULT = 2.0
const BUMP_SPEED_MULT_THRESHOLD = 1.5
const SLAM_SPEED = 500.0
const ROCKET_TIME = 500 # ms
const ROCKET_SPEED = 300.0
const FIRE_MULT = 0.5
const FIRE_TIME = 2000 # ms
const FIRE_COOLDOWN = 1000 # ms

enum PowerUp {
	All,
	Normal,
	Slam,
	Rocket,
	Fire
}

var power_up: PowerUp = PowerUp.All
var direction = 0.0
var face_dir = 1
var is_jumping = false 
var is_charging = false
var is_slamming = false
var is_rocketing = false
var is_firing = false
var rocket_start_time = 0
var rocket_on_cooldown = false
var fire_start_time = 0
var fire_end_time = -FIRE_COOLDOWN
var is_being_abducted = false
var has_infinite_rocket: bool = false

func _physics_process(delta: float) -> void:
	var TIME = Time.get_ticks_msec()

	# --- ABDUCTION ---
	if is_being_abducted and not Input.is_action_just_pressed("slam"):
		animated_sprite.play("idle")
		if not player_sfx.is_playing() or player_sfx.stream != SFX_UFO:
			play_player_sound(SFX_UFO)
		return
	elif not is_being_abducted:
		stop_if_sound(SFX_UFO)

	# --- MOVEMENT ---
	
	# Gravity
	if !is_on_floor():
		if is_slamming:
			velocity.y = SLAM_SPEED
		elif is_rocketing:
			velocity.y = 0
		else:
			velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		is_jumping = true
		velocity.y = JUMP_VELOCITY * (1 + abs(velocity.x / 1000))
		play_player_sound(SFX_JUMP)

	if Input.is_action_just_released("jump") and velocity.y < 0 and is_jumping:
		is_jumping = false
		velocity.y /= 2

	# Charging
	if Input.is_action_pressed("charge") and is_on_floor():
		is_charging = true
	elif Input.is_action_just_released("charge"):
		is_charging = false

	# Slam
	if power_up == PowerUp.Slam or power_up == PowerUp.All:
		if !is_slamming and !is_firing and Input.is_action_just_pressed("slam"):
			is_slamming = true
			velocity.x = 0
			play_player_sound(SFX_Statue)
			is_being_abducted = false
			stop_if_sound(SFX_UFO)
		elif is_slamming and Input.is_action_just_released("slam"):
			is_slamming = false

	# Rocket
	if is_on_floor() and not has_infinite_rocket:
		rocket_on_cooldown = false
	
	if power_up == PowerUp.Rocket or power_up == PowerUp.All:
		# Allow launching if off the floor OR if in infinite rocket mode
		if !is_rocketing and (!is_on_floor() or has_infinite_rocket) and (!rocket_on_cooldown or has_infinite_rocket) and Input.is_action_just_pressed("rocket"):
			is_rocketing = true
			rocket_start_time = TIME
			play_player_sound(SFX_Jetpack)
		elif is_rocketing and Input.is_action_just_released("rocket"):
			is_rocketing = false
			if not has_infinite_rocket:
				rocket_on_cooldown = true
			stop_if_sound(SFX_Jetpack)
		elif is_rocketing and not has_infinite_rocket and TIME - rocket_start_time >= ROCKET_TIME:
			is_rocketing = false
			rocket_on_cooldown = true
			stop_if_sound(SFX_Jetpack)

	# Fire
	if power_up == PowerUp.Fire or power_up == PowerUp.All:
		if !is_firing and !is_slamming and is_on_floor() and TIME - fire_end_time >= FIRE_COOLDOWN and Input.is_action_just_pressed("fire"):
			is_firing = true
			fire_start_time = TIME
			play_player_sound(SFX_FIRE)
		elif is_firing and TIME - fire_start_time >= FIRE_TIME:
			is_firing = false
			fire_end_time = TIME
			stop_if_sound(SFX_FIRE)

	# Movement & Deceleration
	if !is_slamming and !is_rocketing:
		direction = Input.get_axis("move_left", "move_right")
		if direction:
			var speed = SPEED * CHARGE_MULT if is_charging else SPEED * FIRE_MULT if is_firing else SPEED
			velocity.x = move_toward(velocity.x, direction * speed, ACCELERATION * delta)
			if is_on_floor() and not player_sfx.is_playing():
				play_player_sound(SFX_WALK)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if is_on_floor() and player_sfx.stream == SFX_WALK:
				player_sfx.stop()

	if is_rocketing:
		velocity.x = face_dir * ROCKET_SPEED
		velocity.y = -ROCKET_SPEED

	# --- GRAPHICS ---
	if direction > 0:
		face_dir = 1
	elif direction < 0:
		face_dir = -1

	animated_sprite.flip_h = (face_dir == -1)

	# Animation Priority
	if is_slamming:
		animated_sprite.play("statue")
	elif is_rocketing:
		animated_sprite.play("rocket")
	elif is_firing:
		animated_sprite.play("fire_breathing")
	elif !is_on_floor():
		animated_sprite.play("jump")
	elif direction == 0:
		animated_sprite.play("idle")
	elif is_charging:
		animated_sprite.play("ram")
	else:
		animated_sprite.play("run")

	var vx_before_collide = velocity.x

	move_and_slide()

	# --- COLLISIONS & ATTACKS ---
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		var collider = collision.get_collider()

		if collider and collider.is_in_group("enemy"):
			# SLAM DAMAGE: landing on top of an enemy
			if is_slamming and normal.y < -0.5:
				if "health" in collider:
					collider.health -= 3
				is_slamming = false

			# CHARGING DAMAGE: ramming into enemy
			elif is_charging:
				if abs(normal.x) > abs(normal.y) and abs(vx_before_collide) > SPEED * BUMP_SPEED_MULT_THRESHOLD:
					velocity.x = BUMP_MULT * vx_before_collide
					if is_on_floor():
						velocity.y = BUMP_VELOCITY
				
				if collider.direction == face_dir and collider.direction == -sign(velocity.x):
					collider.health -= 1
					is_charging = false

func play_player_sound(stream: AudioStream) -> void:
	player_sfx.stream = stream
	player_sfx.play()

func stop_if_sound(stream: AudioStream) -> void:
	if player_sfx.stream == stream and player_sfx.is_playing():
		player_sfx.stop()
