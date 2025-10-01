extends Control
@onready var historia: Control = $"."
@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer


func _on_video_stream_player_finished() -> void:
	Global.lore_vista = true
	Global.save_data()
	get_tree().change_scene_to_file("res://Escenas/Niveles/main.tscn")
