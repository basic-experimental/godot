extends Node2D

const RAINDROP_TIMEOUT = 5000

var spawn_time = 0
var on_screen = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_time = Time.get_ticks_msec()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Time.get_ticks_msec() - spawn_time > RAINDROP_TIMEOUT):
		queue_free()
	
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	on_screen = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if(on_screen): queue_free()
