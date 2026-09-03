extends Control
@export var markdown_label: MarkdownLabel
@export var text_canvas: CanvasLayer

func _ready() -> void:
	text_canvas.hide()
	
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_version_notes_button_pressed() -> void:
	text_canvas.show()
	markdown_label.display_file("res://assets/text/version_notes.md")

func _on_credits_button_pressed() -> void:
	text_canvas.show()
	markdown_label.display_file("res://assets/text/credits.md")

func _on_close_button_pressed() -> void:
	text_canvas.hide()
