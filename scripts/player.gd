extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_sfx = $PlayerSFX

const SFX_JUMP = preload("res://assets/sounds/GoatJumpsfx.wav")
const SFX_WALK = preload("res://assets/sounds/GoatWalksfx.wav")
const SPEED = 130.0
const ACCELERATION = 300.0
const JUMP_VELOCITY = -350.0
const BUMP_VELOCITY = -150.0
const BUMP_MULT = -0.5
const CHARGE_MULT = 2.0
const BUMP_SPEED_MULT_THRESHOLD = 1.5
const SLAM_SPEED = 400.0
const ROCKET_TIME = 1000.0

enum PowerUp {
	Normal,
	Slam,
	Rocket,
	Fire	
}

var power_up: PowerUp = PowerUp.Normal
var direction = 0.0
var is_jumping = false 
var is_charging = false
var is_slamming = false
var is_rocketing = false
var rocket_start_time = -9223372036854775808 # Minimum int value

func _physics_process(delta: float) -> void:
	# --- MOVEMENT ---
	# Gravity
	if not is_on_floor():
		if is_slamming:
			velocity.y = SLAM_SPEED
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
	
	if Input.is_action_pressed("charge") and is_on_floor():
		is_charging = true
	else:
		is_charging = false
		
	# Slam
	if power_up == PowerUp.Slam:
		if  !is_slamming && !is_on_floor() && Input.is_action_just_pressed("slam"):
			is_slamming = true
		elif is_slamming && is_on_floor() && Input.is_action_just_released("slam"):
			is_slamming = false
	
	# Rocket
	if power_up == PowerUp.Rocket:
		if !is_rocketing && !is_on_floor() && Input.is_action_just_pressed("charge"):
			is_rocketing = true
			rocket_start_time = Time.get_ticks_msec()
		elif is_rocketing && Input.is_action_just_released("rocket"):
			is_rocketing = false
		elif is_rocketing && Time.get_ticks_msec() - rocket_start_time >= ROCKET_TIME:
			is_rocketing = false
	
	# Get the input direction and handle the movement/deceleration
	if !is_slamming:
		direction = Input.get_axis("move_left", "move_right")
		if direction:
			var speed = SPEED * CHARGE_MULT if is_charging else SPEED
			velocity.x = move_toward(velocity.x, direction * speed, ACCELERATION * delta)
			# Only play walk sound if on floor and not already playing
			if is_on_floor() and not player_sfx.is_playing():
				play_player_sound(SFX_WALK)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			# Stop walk sound when player stops moving on the ground
			if is_on_floor() and player_sfx.stream == SFX_WALK:
				player_sfx.stop()
	
	# --- GRAPHICS ---
	# Sprite flipping
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Animation
	if is_slamming:
		animated_sprite.play("slam")
	elif !is_on_floor():
		animated_sprite.play("jump")
	elif direction == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")

	var vx_before_collide = velocity.x
	
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		# Bump on wall
		if abs(normal.x) > abs(normal.y) and is_charging and abs(vx_before_collide) > SPEED * BUMP_SPEED_MULT_THRESHOLD:
			velocity.x = BUMP_MULT * vx_before_collide
			
			if is_on_floor():
				velocity.y = BUMP_VELOCITY
	
func play_player_sound(stream: AudioStream):
	player_sfx.stream = stream
	player_sfx.play()
