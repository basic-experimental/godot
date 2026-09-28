extends Node2D

const SPEED = 100
const RAINDROP_TIMEOUT = 5000

var spawn_time = 0
var on_screen = false

func _ready() -> void:
	spawn_time = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if(!on_screen && Time.get_ticks_msec() - spawn_time > RAINDROP_TIMEOUT):
		queue_free()
	
	position.y += SPEED * delta
	
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	on_screen = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if(on_screen):
		queue_free()
