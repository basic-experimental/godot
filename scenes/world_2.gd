extends Node2D
@onready var anim_player: AnimationPlayer = $OpeningCutscene/OpeningCutscene
@onready var cutscene_camera: Camera2D = $OpeningCutscene/Path2D/PathFollow2D/CutsceneCamera
@onready var player: CharacterBody2D = $"/root/Game/Player"
@onready var player_camera: Camera2D = $Player/Camera2D 
@onready var rocket: AnimatedSprite2D = $OpeningCutscene/RocketShip

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Cutscene.world2_cutscene_played:
		anim_player.play("OpeningCutsceneW2")
		await anim_player.animation_finished
		Cutscene.world2_cutscene_played = true
	else:
		anim_player.seek(anim_player.get_animation("OpeningCutsceneW2").length, true)
		player.visible = true
		cutscene_camera.enabled = false
		player_camera.enabled = true
		rocket.position = Vector2(0,-65)
		rocket.visible = true
		rocket.frame = 0
	
	
