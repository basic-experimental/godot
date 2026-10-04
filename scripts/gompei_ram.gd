extends AnimatedSprite2D

func _ready() -> void:
	if sprite_frames and sprite_frames.has_animation("idle"):
		play("idle")

func play_anim(animation_name: StringName) -> void:
	if sprite_frames and sprite_frames.has_animation(animation_name):
		play(animation_name)

func stop_anim() -> void:
	stop()
