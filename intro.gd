extends Node

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var intro: Control = $"."

func _ready():
	# Conectar la señal del video
	video_player.play()
	video_player.connect("finished", Callable(self, "_on_video_finished"))

	if not Global.intro_vista:
		intro.visible = true
		# Espera la duración del video (20 segundos)
		await get_tree().create_timer(20.0).timeout
		_end_intro()
	else:
		intro.queue_free()
		_change_scene()

	# Iniciar el video
	video_player.play()

func _end_intro():
	intro.queue_free()
	Global.intro_vista = true
	_change_scene()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_accept"):
		_skip_video()

func _on_video_stream_player_finished() -> void:
	_change_scene()

func _skip_video():
	# Detenemos el video y cambiamos de escena
	video_player.stop()
	_change_scene()

func _change_scene():
	get_tree().change_scene_to_file("res://Escenas/Menu_Principal.tscn")
