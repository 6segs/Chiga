extends Control
@onready var control: Control = $"."
@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer


func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://node_2d.tscn")
