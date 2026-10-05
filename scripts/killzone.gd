extends Area2D
@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = $"/root/Game/Player"

var enabled = true
var is_already_hit = false

func _physics_process(delta: float) -> void:
	if(overlaps_body(player) && enabled && !is_already_hit):
		is_already_hit = true
		print("Restart")
		Cutscene.num_goat_bucks = Cutscene.num_goat_bucks - Cutscene.goat_bucks_since_death
		Cutscene.goat_bucks_since_death = 0
		player.play_player_sound(player.SFX_HURT)
		player.get_node("CollisionShape2D").queue_free()
		timer.start()
		

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
