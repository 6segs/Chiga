extends CanvasLayer

@onready var anim = $AnimationPlayer

func _ready() -> void:
	layer = -1
	$AnimationPlayer.play("trans")
	
func change_scene(path : String) -> void:
	# Layer es para poner el CanvasLayer delante del juego
	layer = 1
	# Reproducir la animación: trans
	anim.play("trans")
	await ($AnimationPlayer. animation_finished)
	# Cambiar la escena
	get_tree().change_scene_to_file(path)
	anim.play_backwards("trans")
	await ($AnimationPlayer. animation_finished)
	layer = -1
