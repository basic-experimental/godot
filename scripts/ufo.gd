extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = $"/root/Game/Player"
@onready var ray_cast_2d_l: RayCast2D = $RayCast2D_L
@onready var ray_cast_2d_r: RayCast2D = $RayCast2D_R
@onready var killzone: Area2D = $Killzone

const SPEED = 60
const ABDUCT_COOLDOWN = 5000 #ms
const ABDUCT_TIME = 2000 #ms

var direction = 1
var health = 3
var is_abducting = false
var abduct_start_time = 0
var abduct_end_time = -ABDUCT_COOLDOWN
var player_start_y = 0

func _ready():
	killzone.enabled = false

func _process(delta: float) -> void:
	var TIME = Time.get_ticks_msec()
	
	if(player.is_being_abducted == false):
		is_abducting = false
	
	if(health <= 0):
		queue_free()
	
	if(!is_abducting && TIME - abduct_end_time >= ABDUCT_COOLDOWN && killzone.overlaps_body(player) && !player.is_slamming):
		is_abducting = true
		abduct_start_time = TIME
		position.x = player.position.x
		player_start_y = player.position.y
		animated_sprite_2d.play("abduct")
		player.is_being_abducted = true
		
	if(is_abducting && TIME - abduct_start_time >= ABDUCT_TIME):
		killzone.enabled = true
	
	if(is_abducting):
		player.position.y = lerp(player_start_y, position.y + 10, float(TIME - abduct_start_time) / ABDUCT_TIME)
		return
		
	# Turn anound when on a ledge
	if(!ray_cast_2d_l.is_colliding()):
		direction = 1
	
	if(!ray_cast_2d_r.is_colliding()):
		direction = -1
	
	animated_sprite_2d.flip_h = (direction == -1)
	position.x += direction * SPEED * delta
	move_and_slide()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		if(abs(normal.angle() - Vector2.LEFT.angle()) < PI / 4):
			direction = -1
		elif(abs(normal.angle() - Vector2.RIGHT.angle()) < PI / 4):
			direction = 1
