extends Node2D

@onready var bg_music: AudioStreamPlayer2D = $Player/AudioStreamPlayer2D
@onready var anim_player: AnimationPlayer = $OpeningCutscene/StartCutscene
@onready var cutscene_camera: Camera2D = $OpeningCutscene/StartCutsceneCamera
@onready var player: CharacterBody2D = $"/root/Game/Player"
@onready var player_camera: Camera2D = $Player/Camera2D 
@onready var other_gompei: AnimatedSprite2D = $OpeningCutscene/GompeiRam
@onready var cow1: AnimatedSprite2D = $OpeningCutscene/Cow1
@onready var cow2: AnimatedSprite2D = $OpeningCutscene/Cow2
@onready var cow3: AnimatedSprite2D = $OpeningCutscene/Cow3
@onready var fence: TileMapLayer = $OpeningCutscene/Fence
@onready var controls: Label = $Labels/Controls
@onready var skip: Label = $OpeningCutscene/SkipHint
var cutscene_ended: bool = false

func _ready() -> void:
	if !Cutscene.start_cutscene_played:
		Cutscene.start_cutscene_played = true
		anim_player.play("StartAnimation")
		await anim_player.animation_finished
		fence.visibility_layer = 0
		player.position = Vector2(107, 50)
		controls.visible = true
		skip.visible = false


	else:
		# Player died & scene reloaded: snap everything to gameplay state
		player.visible = true
		other_gompei.visible = false
		cow1.visible = false
		cow2.visible = false
		cow3.visible = false
		fence.visibility_layer = 0
		player.position = Vector2(107, 50)
		cutscene_camera.enabled = false
		player_camera.enabled = true
		controls.visible = true
		skip.visible = false
		start_music()


func _unhandled_input(event: InputEvent) -> void:
	if not cutscene_ended and event.is_action_pressed("ui_cancel"):
		skip_cutscene()

func skip_cutscene() -> void:
	anim_player.seek(anim_player.current_animation_length, true)
	finish_cutscene()

func _on_start_cutscene_animation_finished(anim_name: StringName) -> void:
	if anim_name == "StartAnimation":
		finish_cutscene()

func finish_cutscene() -> void:
	if cutscene_ended:
		return
	cutscene_ended = true
	
	anim_player.stop()
	
	# Cutscene elements cleanup
	other_gompei.visible = false
	cow1.visible = false
	cow2.visible = false
	cow3.visible = false
	fence.visibility_layer = 0
	
	# Switch cameras
	if cutscene_camera:
		cutscene_camera.enabled = false
	if player_camera:
		player_camera.enabled = true
	
	# Unhide and reposition player
	if player:
		player.visible = true
		player.position = Vector2(107, 50)
		player.set_physics_process(true)
	
	# Start background music
	start_music()

func start_music() -> void:
	if not bg_music.playing:
		bg_music.stream = load("res://assets/music/Level1MusicRedo.wav")
		bg_music.play()
	fence.visibility_layer = 0
	player.position = Vector2(107, 50)
	controls.visible = true
	skip.visible = false
