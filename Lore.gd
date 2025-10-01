extends Control
@onready var lore: Control = $"."
@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer


func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://Escenas/Menu_Principal.tscn")
