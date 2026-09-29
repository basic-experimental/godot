extends Node2D
@onready var anim_player: AnimationPlayer = $OpeningCutscene/OpeningCutscene
@onready var cutscene_camera: Camera2D = $OpeningCutscene/Path2D/PathFollow2D/CutsceneCamera
@onready var player: CharacterBody2D = $"/root/Game/Player"
@onready var player_camera: Camera2D = $Player/Camera2D 
@onready var rocket: AnimatedSprite2D = $OpeningCutscene/RocketShip
@onready var boss_arena: TileMapLayer = $BossArena/BossArenaTrap
@onready var music: AudioStreamPlayer2D = $Player/AudioStreamPlayer2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Cutscene.entered_boss_arena:
		player.position = Vector2(1500,-850)
		player_camera.limit_left = 1420
		player_camera.limit_right = 2000
		player_camera.limit_bottom = -820
		player.visible = true
		boss_arena.collision_enabled = true
		cutscene_camera.enabled = false
		player_camera.enabled = true
		boss_arena.visibility_layer = 0
		music.stream = load("res://assets/music/BossBattleMusic.wav")
		music.play()
	else:
		if !Cutscene.world2_cutscene_played:
			anim_player.play("OpeningCutsceneW2")
			await anim_player.animation_finished
			Cutscene.world2_cutscene_played = true
			boss_arena.collision_enabled = false
			boss_arena.visibility_layer = 0
		else:
			anim_player.seek(anim_player.get_animation("OpeningCutsceneW2").length, true)
			player.visible = true
			cutscene_camera.enabled = false
			player_camera.enabled = true
			rocket.position = Vector2(0,-65)
			rocket.visible = true
			rocket.frame = 0
			boss_arena.collision_enabled = false
			boss_arena.visibility_layer = 0

func _on_boss_arena_body_entered(body: Node2D) -> void:
	if body == player:
		player_camera.limit_left = 1420
		player_camera.limit_right = 2000
		player_camera.limit_bottom = -820
		await get_tree().create_timer(.1).timeout
		boss_arena.collision_enabled = true
		Cutscene.entered_boss_arena = true
		music.stream = load("res://assets/music/BossBattleMusic.wav")
		music.play()
