extends Node

var lore_vista := false
var juego_iniciado := false
var nivel_actual: int = 1
var rangos: Array = []  # Guarda el rango de cada nivel
var orden_rangos: Array = ["D", "C", "B", "A", "S"]
var nivel_max: int = 1  # Máximo nivel desbloqueado
var _config := ConfigFile.new()
var _file_path := "user://save.cfg"
var volumen_master: float = 1.0
var volumen_musica: float = 1.0
var volumen_sfx: float = 1.0


func _ready():
	load_data()
	aplicar_volumenes()
# -------- GUARDAR --------
func save_data():
	_config.set_value("progress", "lore_vista", lore_vista)
	_config.set_value("progress", "nivel_actual", nivel_actual)
	_config.set_value("progress", "nivel_max", nivel_max)
	_config.set_value("progress", "rangos", rangos)
	# Guardar Volumenes 
	_config.set_value("audio", "master", volumen_master)
	_config.set_value("audio", "musica", volumen_musica)
	_config.set_value("audio", "sfx", volumen_sfx)
	_config.save(_file_path)


func load_data():
	var err = _config.load(_file_path)
	if err == OK:
		lore_vista = _config.get_value("progress", "lore_vista", false)
		nivel_actual = _config.get_value("progress", "nivel_actual", 1)
		nivel_max = _config.get_value("progress", "nivel_max", 1)
		rangos = _config.get_value("progress", "rangos", [])
		# Cargar los volumenes
		volumen_master = _config.get_value("audio", "master", 1.0)
		volumen_musica = _config.get_value("audio", "musica", 1.0)
		volumen_sfx = _config.get_value("audio", "sfx", 1.0)

func aplicar_volumenes():
	volumen_master = clamp(volumen_master, 0.0, 1.0)
	volumen_musica = clamp(volumen_musica, 0.0, 1.0)
	volumen_sfx = clamp(volumen_sfx, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volumen_master))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musica"), linear_to_db(volumen_musica))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(volumen_sfx))

# -------- RANGOS Y DESBLOQUEO --------
func rango_valido(rango: String, minimo: String = "B") -> bool:
	return orden_rangos.find(rango) >= orden_rangos.find(minimo)

func guardar_rango(nivel: int, rango: String) -> void:
	if rangos.size() < nivel:
		for i in range(rangos.size(), nivel):
			rangos.append("")
	rangos[nivel - 1] = rango

	# desbloquear el siguiente si el rango fue válido
	if rango_valido(rango):
		nivel_actual = max(nivel_actual, nivel + 1)
		nivel_max = max(nivel_max, nivel + 1)

	save_data()


func nivel_desbloqueado(nivel: int) -> bool:
	return nivel <= nivel_actual

# -------- NIVELES --------
func avanzar_nivel():
	nivel_actual += 1
	save_data()

func cargar_nivel_actual():
	var path = "res://Niveles/Nivel_%d.tscn" % nivel_actual
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)
	else:
		print("⚠ El nivel no existe:", path)
