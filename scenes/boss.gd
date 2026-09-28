extends Node2D

@onready var killzone: Area2D = $Killzone
@onready var player: CharacterBody2D = $"/root/Game/Player"
@onready var right_foot: CollisionShape2D = $Killzone/RightFoot
@onready var left_foot: CollisionShape2D = $Killzone/LeftFoot
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

const RAINDROP_SCENE = preload("res://scenes/raindrop.tscn")
const ATTACK_TIME = 5000 #ms
const NUM_RAINDROPS = 5
const RAINDROP_INTERVAL = 1000 #ms



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	killzone.enabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_collision()
			
func update_collision():
	match animated_sprite_2d.animation:
		"Attack":
			collision_shape_2d.disabled = false
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
