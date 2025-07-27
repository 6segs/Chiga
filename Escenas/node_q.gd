extends Node2D

@onready var animation = $AnimatedSprite2D

func _ready() -> void:
	animation.visible = false


func _on_quit_mouse_entered() -> void:
	animation.visible = true
	animation.play("Run")


func _on_quit_mouse_exited() -> void:
	animation.visible = false
