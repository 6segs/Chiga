extends HSlider

@onready var sfx_volumen: Label = $".."
@onready var sfx_volumen_slider: HSlider = $"."

@export_enum("Master", "Music", "SFX") var bus_name : String

var bus_index : int = 2

func _ready():
	sfx_volumen_slider.value_changed.connect(sfx_slider_val)
	cambiar_nombre()
	definir_valor_slider()

func cambiar_nombre() -> void:
	sfx_volumen.text = "SFX: " + str(int(sfx_volumen_slider.value)) + "%"

func definir_valor_slider() -> void:
	var volumen = db_to_linear(AudioServer.get_bus_volume_db(0))
	sfx_volumen_slider.value = int(volumen * 100)  # De 0 a 100
	cambiar_nombre()

func sfx_slider_val(value: int) -> void:
	#AudioServer.get_bus_volume_db(0, linear_to_db(value))
	cambiar_nombre()
