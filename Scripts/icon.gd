extends Node2D

@export var amplitude_degrees: float = 10.0
@export var frequency: float = 3.0

var time := 0.0
var original_rotation := 0.0

func _ready():
	original_rotation = rotation_degrees

func _process(delta):
	time += delta
	rotation_degrees = original_rotation + sin(time * frequency) * amplitude_degrees
