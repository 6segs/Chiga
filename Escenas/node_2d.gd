extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var _1: AnimatedSprite2D = $"1"


func _ready() -> void:
	_1.visible = false
	animated_sprite_2d.visible = false

func _on_tutorial_mouse_entered() -> void:
	_1.visible = true
	_1.play("Run")
	animated_sprite_2d.visible = true
	animated_sprite_2d.play("Run")


func _on_tutorial_mouse_exited() -> void:
	_1.visible = false
	animated_sprite_2d.visible = false
