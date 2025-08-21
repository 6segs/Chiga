extends HSlider

@onready var music_volumen: Label = $".."
@onready var music_volumen_slider: HSlider = $"."


@export_enum("Master", "Music", "SFX") var bus_name : String

var bus_index : int = 1

func _ready():
	music_volumen_slider.value_changed.connect(musica_slider_val)
	cambiar_nombre()
	definir_valor_slider()

func cambiar_nombre() -> void:
	music_volumen.text = "Musica: " + str(int(music_volumen_slider.value)) + "%"

func definir_valor_slider() -> void:
	var volumen = db_to_linear(AudioServer.get_bus_volume_db(0))
	music_volumen_slider.value = int(volumen * 100)  # De 0 a 100
	cambiar_nombre()

func musica_slider_val(value: int) -> void:
	#AudioServer.get_bus_volume_db(0, linear_to_db(value))
	cambiar_nombre()


func volumen(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, value)
	
func _on_value_changed(value: float) -> void:
	volumen(0, value/100)
