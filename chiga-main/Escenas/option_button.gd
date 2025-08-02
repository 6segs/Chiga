extends OptionButton

@onready var option_button: OptionButton = $"."

const TIPOS_VENTANAS : Array[String] = [
	"Full-Screen",
	"Window",
	"Borderless Window",
]

func crear_opciones() -> void:
	for tipos in TIPOS_VENTANAS:
		option_button.add_item(tipos)

func _ready():
	crear_opciones()
	option_button.item_selected.connect(tipo_ventana_seleccionado)

func tipo_ventana_seleccionado(index: int) -> void:
	match index:
		0: #Full screen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: #Window
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2: #Borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
