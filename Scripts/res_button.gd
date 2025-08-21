extends OptionButton

@onready var res_button: OptionButton = $"."

const TIPOS_RESOLUCIONES : Dictionary = {
	"1152x648" : Vector2i(1152, 648),
	"1080x720" : Vector2i(1080, 720),
	"1920x1080": Vector2i(1920, 1080),
}

func crear_opciones() -> void:
	for tipos in TIPOS_RESOLUCIONES:
		res_button.add_item(tipos)

func _ready():
	crear_opciones()
	res_button.item_selected.connect(tipo_res_seleccionada)

func tipo_res_seleccionada(index: int) -> void:
	DisplayServer.window_set_size(TIPOS_RESOLUCIONES.values()[index])
	centrar_ventana()

func centrar_ventana():
	var centro = DisplayServer.screen_get_position() + DisplayServer.screen_get_size()/2
	var medida = get_window().get_size_with_decorations()
	get_window().set_position(centro - medida/2)
