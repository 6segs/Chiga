extends Control

@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var camera_2d: Camera2D = $Camera2D

func _ready() -> void:
	Global.aplicar_volumenes()

func _on_video_stream_player_finished() -> void:
	Global.lore_vista = true
	Global.save_data()
	get_tree().change_scene_to_file("res://Escenas/Niveles/main.tscn")
