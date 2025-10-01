extends Node

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var intro: Control = $"."

func _ready():
	video_player.play()
	video_player.connect("finished", Callable(self, "_on_intro_finished"))
	intro.visible = true


func _on_intro_finished():
	_end_intro()

func _end_intro():
	intro.queue_free()
	_change_scene()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_accept"):
		_skip_video()

func _skip_video():
	video_player.stop()
	_change_scene()

func _change_scene():
		get_tree().change_scene_to_file("res://Escenas/Menu_Principal.tscn")
