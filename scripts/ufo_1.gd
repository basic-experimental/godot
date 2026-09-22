extends AnimatedSprite2D

func _ready() -> void:
	play("idle")

func play_anim(animation_name) -> void:
	play(animation_name)

func stop_anim() -> void:
	stop()
