extends Node2D

@onready var player: CharacterBody2D = $"/root/Game/Player"
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision: CollisionShape2D = $CollisionShape2D 
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var coin_sfx = preload("res://assets/sounds/coin.wav")

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		Cutscene.num_goat_bucks = Cutscene.num_goat_bucks + 1
		Cutscene.goat_bucks_since_death = Cutscene.goat_bucks_since_death + 1
		collision.set_deferred("disabled", true)
		sprite.visible = false
		audio.stream = coin_sfx
		audio.play()
		await audio.finished
		queue_free()
		print(Cutscene.num_goat_bucks)
		
	
	
