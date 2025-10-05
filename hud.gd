extends CanvasLayer

@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var label: Label = $NinePatchRect/Label

# Lista de líneas de diálogo
var dialogo: Array[String] = [
	"Escúchame querido te voy a enseñar los conceptos básicos para
	tocar el shamisen bien piola.",
	"Las cuerdas son 3, la izquierda, la derecha y la del medio.",
	"Primero quiero que toques la cuerda izquierda “←”",
	"Buen trabajo.",
	"Ahora quiero que toques la cuerda derecha “→”", 
	"Estas totalmente loco.",
	"Para terminar, toca la cuerda del medio “↓”",
	"Nana definitivamente eres parte del clan chiga lo tienes en la
	sangre.",
	"No sos tan picante como tu abuelo chi-gerr, pero para 
	ser tu primera vez tocando un shamisen, esta bastante bien.",
	"Ahora vamos por un reto real."
]

var indice: int = 0
var texto_actual: String = ""
var char_index: int = 0
var velocidad: float = 0.06  # segundos por letra
var espera_final: float = 2 # segundos para esperar al final de la línea
var timer_espera: float = 0.0
var mostrando: bool = true
var time_accumulator: float = 0.0

func _ready() -> void:
	if Global.nivel_actual == 1:
		iniciar_linea()
	else:
		nine_patch_rect.visible = false


func _process(_delta: float) -> void:
	if mostrando:
		time_accumulator += _delta
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
		timer_espera += _delta
		if timer_espera >= espera_final:
			indice += 1
			if indice < dialogo.size():
				iniciar_linea()
			else:
				nine_patch_rect.visible = false

func iniciar_linea() -> void:
	texto_actual = dialogo[indice]
	char_index = 0
	label.text = ""
	mostrando = true
	time_accumulator = 0.0
