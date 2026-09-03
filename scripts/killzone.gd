extends Area2D
@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = $"/root/Game/Player"

func _on_body_entered(body: Node2D) -> void:
	print("oops")
	Engine.time_scale = 0.5
	player.get_node("CollisionShape2D").queue_free()
	timer.start()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
	Engine.time_scale = 1
