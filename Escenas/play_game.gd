extends Node2D


@onready var animation = $AnimatedSprite2D
@onready var animacion =$"1"

func _ready() -> void:
	animation.visible = false
	animacion.visible = false

func _on_jogoo_mouse_entered() -> void:
	animation.visible = true
	animation.play("Run")
	animacion.visible = true
	animacion.play("Run")


func _on_jogoo_mouse_exited() -> void:
	animation.visible = false
	animacion.visible = false
