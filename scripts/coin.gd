extends Area2D

@onready var game_manager: Node = %GameManager
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D

var collected = false

func _on_body_entered(_body: Node2D) -> void:
	if collected == false:
		game_manager.add_point()
		hide()
		sfx.play()
		collected = true
		

		



func _on_audio_stream_player_2d_finished() -> void:
	queue_free()
