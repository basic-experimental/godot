extends Node2D

@onready var killzone: Area2D = $Killzone
@onready var player: CharacterBody2D = $"/root/Game/Player"
@onready var gameNode: Node2D = $"/root/Game/"
@onready var right_foot: CollisionShape2D = $Killzone/RightFoot
@onready var left_foot: CollisionShape2D = $Killzone/LeftFoot
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

const RAINDROP_SCENE = preload("res://scenes/raindrop.tscn")

enum State {
	Attack,
	Hurt,
	Idle
}

const IDLE_TIME = 3000 #ms
const HURT_TIME = 1000 #ms
const ATTACK_TIME = 5000 #ms
const NUM_RAINDROPS = 20
const RAINDROP_INTERVAL = 200 #ms

var state = State.Idle
var animation_start_time = 0
var last_raindrop_time = 0
var raindrops_spawned = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_start_time = Time.get_ticks_msec()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var TIME = Time.get_ticks_msec()
	
	update_collision()
	
	match(state):
		State.Attack:
			if(raindrops_spawned < NUM_RAINDROPS && TIME - last_raindrop_time >= RAINDROP_INTERVAL):
				spawn_raindrop()
				raindrops_spawned += 1
				last_raindrop_time = TIME
			
			if(TIME - animation_start_time >= ATTACK_TIME):
				raindrops_spawned = 0
				state = State.Idle
				animated_sprite_2d.animation = "Idle"
				animation_start_time = TIME
			
		State.Hurt:
			if(TIME - animation_start_time >= HURT_TIME):
				state = State.Attack
				animated_sprite_2d.animation = "Attack"
				animation_start_time = TIME
			
		State.Idle:
			if(TIME - animation_start_time >= IDLE_TIME):
				state = State.Attack
				animated_sprite_2d.animation = "Attack"
				animation_start_time = TIME
			
func update_collision():
	match animated_sprite_2d.animation:
		"Attack":
			collision_shape_2d.disabled = true
			match animated_sprite_2d.frame:
				0: left_foot.disabled =  true; right_foot.disabled =  true;
				1: left_foot.disabled =  true; right_foot.disabled =  true;
				2: left_foot.disabled = false; right_foot.disabled =  true;
				3: left_foot.disabled =  true; right_foot.disabled =  true;
				4: left_foot.disabled =  true; right_foot.disabled =  true;
				5: left_foot.disabled =  true; right_foot.disabled = false;
				6: left_foot.disabled =  true; right_foot.disabled =  true;
				7: left_foot.disabled =  true; right_foot.disabled =  true;
				8: left_foot.disabled =  true; right_foot.disabled =  true;
				9: left_foot.disabled =  true; right_foot.disabled =  true;
		
		"Hurt":
			collision_shape_2d.disabled = true
			left_foot.disabled = true
			right_foot.disabled = true
		
		"Idle":
			collision_shape_2d.disabled = false
			left_foot.disabled = true
			right_foot.disabled = true
			
func spawn_raindrop():
	if Cutscene.entered_boss_arena:
		var raindrop = RAINDROP_SCENE.instantiate()
		raindrop.position.x = position.x + randi_range(-400, 400)
		raindrop.position.y = position.y - 150
		gameNode.add_child(raindrop)
	
