extends Node
@onready var cutscene = $Cutscene
@onready var player: CharacterBody2D = $"/root/Game/Player"
@onready var camera = $Path2D/PathFollow2D/CutsceneCamera
@onready var gompei = $GompeiWalk
var is_cutscene = false
var player_entered_area = false

func _on_cutscene_detection_body_entered(body: Node2D) -> void:
	print("Body entered: ", body.name, " | Groups: ", body.get_groups())
	if body == player:
		if !player_entered_area:
			player_entered_area = true
			rocket_cutscene()

func rocket_cutscene():
	print("rocket_cutscene triggered")
	gompei.set_visibility_layer_bit(1,true)
	is_cutscene = true
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	player.visible = false
	player.get_node("Camera2D").enabled = false
	camera.enabled = true
	cutscene.play("cutscene")
	await get_tree().create_timer(12.0).timeout
	get_tree().change_scene_to_file("res://scenes/world_2.tscn")
