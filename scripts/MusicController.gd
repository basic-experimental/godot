extends Node

var bg_music: AudioStreamPlayer
var cutscene_completed: bool = false

func _ready() -> void:
	bg_music = AudioStreamPlayer.new()
	add_child(bg_music)
	bg_music.stream = preload("res://assets/music/Level1MusicRedo.wav")

func play_music() -> void:
	if not bg_music.playing:
		bg_music.play()

func stop_music() -> void:
	bg_music.stop()
