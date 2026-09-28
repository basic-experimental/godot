extends Area2D
@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = $"/root/Game/Player"

var enabled = true
var is_already_hit = false

func _physics_process(delta: float) -> void:
	if(overlaps_body(player) && enabled && !is_already_hit):
		print("Restart")
		player.play_player_sound(player.SFX_HURT)
		player.get_node("CollisionShape2D").queue_free()
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
