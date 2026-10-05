extends Node2D

@onready var killzone: Area2D = $Killzone
@onready var player: CharacterBody2D = $"/root/Game/Player"
@onready var gameNode: Node2D = $"/root/Game/"
@onready var right_foot: CollisionShape2D = $Killzone/RightFoot
@onready var left_foot: CollisionShape2D = $Killzone/LeftFoot
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var health_bar: AnimatedSprite2D = $"../HealthBar"
@onready var lava_floor: Area2D = get_node_or_null("../BossArena/FloorIsLava")
@onready var end_cutscene_player: AnimationPlayer = $"/root/Game/BossCutscene/EndCutScene"
@onready var player_camera: Camera2D =$"/root/Game/Player/Camera2D"
@onready var cutscene_camera: Camera2D = $"/root/Game/BossCutscene/CutsceneCamera2"
@onready var secrets: Label = $"/root/Game/BossCutscene/SecretsCollected"
@onready var end_label: Label = $"/root/Game/BossCutscene/EndCutsceneLabel"
@onready var milk: Sprite2D = $"/root/Game/BossCutscene/HolyMilk"


const RAINDROP_SCENE = preload("res://scenes/raindrop.tscn")

enum State {
	Attack,
	Hurt,
	Idle,
	LavaWait
}

enum Phase {
	Phase1,
	Phase2_Lava,
	Phase3_FastRain
}

var current_phase = Phase.Phase1
var state = State.Idle
var animation_start_time = 0
var last_raindrop_time = 0
var raindrops_spawned = 0
var boss_active: bool = false
var is_invulnerable: bool = false
var lava_phase_timer = 0
var boss_health: int = 3 # 1 hit per phase

# Attack timings
var num_raindrops = 20
var raindrop_interval = 200 # ms
const IDLE_TIME = 3000      # ms
const HURT_TIME = 1000      # ms
const ATTACK_TIME = 5000    # ms
const LAVA_DURATION = 5000  # ms

func _ready() -> void:
	animation_start_time = Time.get_ticks_msec()
	
	# Ensure lava is completely hidden and disabled at level start
	if lava_floor:
		lava_floor.visible = false
		lava_floor.set_deferred("monitoring", false)
		# Connect lava collision directly if not already connected
		if not lava_floor.body_entered.is_connected(_on_lava_floor_body_entered):
			lava_floor.body_entered.connect(_on_lava_floor_body_entered)

	# Initialize healthbar
	if health_bar:
		health_bar.play(str(boss_health))

	if Cutscene.entered_boss_arena:
		start_boss()

func start_boss() -> void:
	boss_active = true
	current_phase = Phase.Phase1
	boss_health = 3
	num_raindrops = 20
	raindrop_interval = 200
	is_invulnerable = false

	state = State.Idle
	animated_sprite_2d.play("Idle")
	animation_start_time = Time.get_ticks_msec()

func _process(delta: float) -> void:
	update_collision()
	
	if not boss_active:
		return

	var TIME = Time.get_ticks_msec()

	# Continuously check for player fire breath damage
	check_player_fire_damage()

	match state:
		State.Attack:
			if raindrops_spawned < num_raindrops and TIME - last_raindrop_time >= raindrop_interval:
				spawn_raindrop()
				raindrops_spawned += 1
				last_raindrop_time = TIME
			
			if TIME - animation_start_time >= ATTACK_TIME:
				raindrops_spawned = 0
				state = State.Idle
				animated_sprite_2d.play("Idle")
				animation_start_time = TIME

		State.Hurt:
			# Stay in Hurt animation until HURT_TIME passes
			if TIME - animation_start_time >= HURT_TIME:
				if current_phase == Phase.Phase2_Lava:
					start_lava_phase()
				elif current_phase == Phase.Phase3_FastRain:
					is_invulnerable = false
					state = State.Attack
					animated_sprite_2d.play("Attack")
					animation_start_time = TIME
				else:
					state = State.Attack
					animated_sprite_2d.play("Attack")
					animation_start_time = TIME

		State.Idle:
			if TIME - animation_start_time >= IDLE_TIME:
				state = State.Attack
				animated_sprite_2d.play("Attack")
				animation_start_time = TIME

		State.LavaWait:
			# Player must survive for 5 seconds
			if TIME - lava_phase_timer >= LAVA_DURATION:
				end_lava_phase()

func check_player_fire_damage() -> void:
	if is_invulnerable or not player:
		return
	
	# Only vulnerable when in Idle or Attack (not during LavaWait)
	if player.is_firing and (state == State.Idle or state == State.Attack):
		var boss_rect = Rect2(global_position - Vector2(70, 70), Vector2(140, 140))
		if boss_rect.has_point(player.global_position):
			take_damage()

func take_damage() -> void:
	is_invulnerable = true
	boss_health -= 1
	
	if(boss_health > 0):
		health_bar.play(str(boss_health))

	# Trigger the Hurt animation
	state = State.Hurt
	animated_sprite_2d.play("Hurt")
	animation_start_time = Time.get_ticks_msec()

	match current_phase:
		Phase.Phase1:
			current_phase = Phase.Phase2_Lava
		Phase.Phase2_Lava:
			current_phase = Phase.Phase3_FastRain
			num_raindrops = 35
			raindrop_interval = 80 # Faster downpour
		Phase.Phase3_FastRain:
			boss_defeated()

func start_lava_phase() -> void:
	state = State.LavaWait
	animated_sprite_2d.play("Attack")
	lava_phase_timer = Time.get_ticks_msec()
	
	# Give player flight boost
	player.has_infinite_rocket = true
	
	# Turn ON lava visuals and hitbox
	if lava_floor:
		lava_floor.visible = true
		lava_floor.set_deferred("monitoring", true)

func end_lava_phase() -> void:
	# Turn OFF lava visuals and hitbox
	if lava_floor:
		lava_floor.visible = false
		lava_floor.set_deferred("monitoring", false)
	
	# Remove flight buff
	player.has_infinite_rocket = false
	
	# Boss drops into vulnerable Idle state
	is_invulnerable = false
	state = State.Idle
	animated_sprite_2d.play("Idle")
	animation_start_time = Time.get_ticks_msec()

func _on_lava_floor_body_entered(body: Node2D) -> void:
	if body == player:
		# Kill or reset player on lava touch
		player.play_player_sound(player.SFX_HURT)
		get_tree().reload_current_scene()

func boss_defeated() -> void:
	boss_active = false
	animated_sprite_2d.play("Hurt")
	
	player.has_infinite_rocket = false
	
	if lava_floor:
		lava_floor.visible = false
		lava_floor.set_deferred("monitoring", false)
	
	if health_bar:
		health_bar.visible = false

	secrets.visible = true
	end_label.visible = true
	milk.visible = true
	secrets.text = "You collected " + str(Cutscene.num_goat_bucks) + " out of 7 secrets!"
	player.visible = false
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	cutscene_camera.enabled = true
	end_cutscene_player.play("EndCutScene")
	queue_free()
	await end_cutscene_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func spawn_raindrop() -> void:
	if Cutscene.entered_boss_arena:
		var raindrop = RAINDROP_SCENE.instantiate()
		raindrop.position.x = position.x + randi_range(-400, 400)
		raindrop.position.y = position.y - 150
		gameNode.add_child(raindrop)

func update_collision() -> void:
	match animated_sprite_2d.animation:
		"Attack":
			collision_shape_2d.disabled = true
			match animated_sprite_2d.frame:
				0: left_foot.disabled =  true; right_foot.disabled =  true
				1: left_foot.disabled =  true; right_foot.disabled =  true
				2: left_foot.disabled = false; right_foot.disabled =  true
				3: left_foot.disabled =  true; right_foot.disabled =  true
				4: left_foot.disabled =  true; right_foot.disabled =  true
				5: left_foot.disabled =  true; right_foot.disabled = false
				6: left_foot.disabled =  true; right_foot.disabled =  true
				7: left_foot.disabled =  true; right_foot.disabled =  true
				8: left_foot.disabled =  true; right_foot.disabled =  true
				9: left_foot.disabled =  true; right_foot.disabled =  true
		"Hurt":
			collision_shape_2d.disabled = true
			left_foot.disabled = true
			right_foot.disabled = true
		"Idle":
			collision_shape_2d.disabled = false
			left_foot.disabled = true
			right_foot.disabled = true
