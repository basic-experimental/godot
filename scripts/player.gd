extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_sfx = $PlayerSFX

const SFX_JUMP = preload("res://assets/sounds/GoatJumpsfx.wav")
const SFX_WALK = preload("res://assets/sounds/GoatWalksfx.wav")
const SPEED = 130.0
const JUMP_VELOCITY = -300.0

enum PowerUp {
	Normal,
	Slam,
	Rocket,
	Fire	
}

var power_up: PowerUp = PowerUp.Normal 

func _physics_process(delta: float) -> void:
	# --- MOVEMENT ---
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		play_player_sound(SFX_JUMP)
		
	var speed_mult = 1
	if Input.is_action_pressed("charge"):
		speed_mult *= 2
		
	# Get the input direction and handle the movement/deceleration
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED * speed_mult
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
	if !is_on_floor():
		animated_sprite.play("jump")
	elif direction == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")

	move_and_slide()
	
func play_player_sound(stream: AudioStream):
	player_sfx.stream = stream
	player_sfx.play()
