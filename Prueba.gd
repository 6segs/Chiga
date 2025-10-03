extends Control

@onready var label: Label = $Panel/NinePatchRect/Label

# Lista de líneas de diálogo
var dialogo: Array[String] = [
	"Hola, viajero.",
	"Bienvenido a este ejemplo de diálogo estilo Undertale.",
	"Cada letra aparece automáticamente.",
	"¡Disfrutalo!"
]

var indice: int = 0
var texto_actual: String = ""
var char_index: int = 0
var velocidad: float = 0.05  # segundos por letra
var espera_final: float = 1.5 # segundos para esperar al final de la línea
var timer_espera: float = 0.0
var mostrando: bool = true
var time_accumulator: float = 0.0

func _ready() -> void:
	iniciar_linea()

func _process(delta: float) -> void:
	if mostrando:
		time_accumulator += delta
		if time_accumulator >= velocidad:
			time_accumulator = 0.0
			if char_index < texto_actual.length():
				label.text += texto_actual[char_index]
				char_index += 1
			else:
				mostrando = false
				timer_espera = 0.0
	else:
		# Espera entre líneas
		timer_espera += delta
		if timer_espera >= espera_final:
			indice += 1
			if indice < dialogo.size():
				iniciar_linea()
			else:
				# 🚪 Cuando termina el diálogo, cambia de escena
				get_tree().change_scene_to_file("res://Escenas/intro.tscn")

func iniciar_linea() -> void:
	texto_actual = dialogo[indice]
	char_index = 0
	label.text = ""
	mostrando = true
	time_accumulator = 0.0
