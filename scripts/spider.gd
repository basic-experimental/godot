extends CharacterBody2D

@onready var game_manager: Node = %GameManager

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d_l: RayCast2D = $RayCast2D_L
@onready var ray_cast_2d_r: RayCast2D = $RayCast2D_R

const SPEED = 60
var direction = 1
var health = 3

func _process(delta: float) -> void:
	if(health <= 0):
		queue_free()
	
	# Enable player collision while charging
	if(game_manager.player.is_charging):
		set_collision_layer_value(1, true)
	else:
		set_collision_layer_value(1, false)
	
	# Turn anound when on a ledge
	if(!ray_cast_2d_l.is_colliding()):
		direction = 1
		print("ray l")
	
	if(!ray_cast_2d_r.is_colliding()):
		direction = -1
		print("ray r")
	
	
	animated_sprite_2d.flip_h = (direction == -1)
	position.x += direction * SPEED * delta
	move_and_slide()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		if(abs(normal.angle() - Vector2.LEFT.angle()) < PI / 4):
			direction = -1
			print("collide l")
		elif(abs(normal.angle() - Vector2.RIGHT.angle()) < PI / 4):
			direction = 1
			print("collide r")