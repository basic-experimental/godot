extends Area2D
@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = $"/root/Game/Player"

var enabled = true
var is_already_hit = false

func _physics_process(delta: float) -> void:
	if(overlaps_body(player) && enabled && !is_already_hit):
		print("oops")
		player.get_node("CollisionShape2D").queue_free()
		timer.start()
		is_already_hit = true

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
