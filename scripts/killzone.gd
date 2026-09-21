extends Area2D
@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = $"/root/Game/Player"

var enabled = true
var is_colliding = false
var is_already_hit = false

func _on_body_entered(body: Node2D) -> void:
	if(body == player):
		is_colliding = true
			
func _on_body_exited(body: Node2D) -> void:
	if(body == player):
		is_colliding = false
		
func _physics_process(delta: float) -> void:
	if(is_colliding && enabled && !is_already_hit):
		print("oops")
		player.get_node("CollisionShape2D").queue_free()
		timer.start()
		is_already_hit = true

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
