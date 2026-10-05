extends Node2D

@onready var anim_player: AnimationPlayer = $OpeningCutscene/OpeningCutscene
@onready var cutscene_camera: Camera2D = $OpeningCutscene/Path2D/PathFollow2D/CutsceneCamera
@onready var player: CharacterBody2D = $"/root/Game/Player"
@onready var player_camera: Camera2D = $Player/Camera2D 
@onready var rocket: AnimatedSprite2D = $OpeningCutscene/RocketShip

# Arena & Trap
@onready var boss_arena: TileMapLayer = $BossArena/BossArenaTrap
@onready var arena_music: AudioStreamPlayer2D = $BossArena/ArenaMusic
@onready var player_music: AudioStreamPlayer2D = $Player/AudioStreamPlayer2D

# Combat Boss
@onready var combat_boss: Node2D = $Boss

#Cutscene Objects
@onready var end_label: Label = $BossCutscene/EndCutsceneLabel
@onready var secrets: Label = $BossCutscene/SecretsCollected
@onready var holy_milk: Sprite2D = $BossCutscene/HolyMilk

# Cutscene Hierarchy
@onready var boss_cutscene_container: Node = $BossCutscene
@onready var boss_anim_player: AnimationPlayer = $BossCutscene/BossStartCutscene
@onready var boss_camera: Camera2D = $BossCutscene/CutsceneCamera2

const LEVEL_2_MUSIC = preload("res://assets/music/2ndLevelMusic(space).wav")

func _ready() -> void:
	$BossCutscene/BossCutscene.visible = false
	$BossCutscene/Goat.visible = false
	$BossCutscene/StartCutsceneLabel.visible = false
<<<<<<< HEAD
	end_label.visible = false
	secrets.visible = false
	holy_milk.visible = false
=======
	
	#Cutscene.entered_boss_arena = true
>>>>>>> 56f024bf816694d72137d6dc6e47dda8eae290bb
	
	if boss_camera:
		boss_camera.enabled = false

	if Cutscene.entered_boss_arena:
<<<<<<< HEAD
		
=======
		# Respawn directly in boss arena after death:
		# Completely hide the cutscene puppets container so they never reappear
		$BossCutscene/BossCutscene.visible = false
		$BossCutscene/Goat.visible = false

>>>>>>> 56f024bf816694d72137d6dc6e47dda8eae290bb
		player.position = Vector2(1500, -850)
		player_camera.limit_left = 1420
		player_camera.limit_right = 2000
		player_camera.limit_bottom = -820
		player.visible = true
		player.set_physics_process(true)
		
		boss_arena.collision_enabled = true
		boss_arena.visibility_layer = 0
		cutscene_camera.enabled = false
		player_camera.enabled = true
		
		combat_boss.visible = true
		if combat_boss.has_method("start_boss"):
			combat_boss.start_boss()
		
		if player_music.is_playing():
			player_music.stop()
		play_arena_music()
	else:
		# Level 2 normal start
		combat_boss.visible = false
		
		# Start playing Level 2 music right away during the opening cutscene
		play_level_music()
		
		if not Cutscene.world2_cutscene_played:
			cutscene_camera.enabled = true
			player_camera.enabled = false
			anim_player.play("OpeningCutsceneW2")
			await anim_player.animation_finished
			
			Cutscene.world2_cutscene_played = true
			
			cutscene_camera.enabled = false
			player_camera.enabled = true
			player.visible = true
			player.set_physics_process(true)
			
			boss_arena.collision_enabled = false
			boss_arena.visibility_layer = 0
		else:
			anim_player.seek(anim_player.get_animation("OpeningCutsceneW2").length, true)
			player.visible = true
			cutscene_camera.enabled = false
			player_camera.enabled = true
			rocket.position = Vector2(0, -65)
			rocket.visible = true
			rocket.frame = 0
			boss_arena.collision_enabled = false
			boss_arena.visibility_layer = 0

func _on_boss_arena_body_entered(body: Node2D) -> void:
	if body == player:
		if not Cutscene.entered_boss_arena:
			Cutscene.entered_boss_arena = true
			Cutscene.num_goat_bucks = Cutscene.num_goat_bucks
			Cutscene.goat_bucks_since_death = 0
			
			# 1. Lock player and switch to cutscene camera
			player.set_physics_process(false)
			player.velocity = Vector2.ZERO
			player.visible = false
			player_camera.enabled = false
			boss_camera.enabled = true
			
			# Stop background level music
			if player_music.is_playing():
				player_music.stop()
			
			# 2. Play intro cutscene
			boss_anim_player.play("Boss")
			await boss_anim_player.animation_finished
			
			# 3. Cutscene is done: hide the entire cutscene container permanently
			$BossCutscene/BossCutscene.visible = false
			$BossCutscene/Goat.visible = false
<<<<<<< HEAD
			$BossCutscene/StartCutsceneLabel.visible = false
=======
>>>>>>> 56f024bf816694d72137d6dc6e47dda8eae290bb
			
			# 4. Enable combat boss and restore controls
			combat_boss.visible = true
			boss_camera.enabled = false
			player.visible = true
			player_camera.enabled = true
			player.position = Vector2(1500, -850)
			player.set_physics_process(true)
			
			# 5. Start boss attacks
			if combat_boss.has_method("start_boss"):
				combat_boss.start_boss()
		
		# Set arena limits and trap
		player_camera.limit_left = 1420
		player_camera.limit_right = 2000
		player_camera.limit_bottom = -820
		
		await get_tree().create_timer(0.1).timeout
		boss_arena.collision_enabled = true
		
		if player_music.is_playing():
			player_music.stop()
		play_arena_music()

func play_level_music() -> void:
	if not player_music.playing or player_music.stream != LEVEL_2_MUSIC:
		player_music.stream = LEVEL_2_MUSIC
		player_music.play()

func play_arena_music() -> void:
	if not arena_music.playing:
		if arena_music.stream == null:
			arena_music.stream = preload("res://assets/music/BossBattleMusic.wav")
		arena_music.play()
