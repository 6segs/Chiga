extends Node

var lore_vista := false
var juego_iniciado := false

# Progreso general
var nivel_actual: int = 1
var rangos: Array = [] # guarda el rango de cada nivel
var orden_rangos: Array = ["D", "C", "B", "A", "S"]

# 🔥 Nueva variable para la historia
var historia_vista: bool = false

var _config := ConfigFile.new()
var _file_path := "user://save.cfg"

func _ready():
	load_data()

# -------- GUARDAR --------
func save_data():
	_config.set_value("progress", "lore_vista", lore_vista)
	_config.set_value("progress", "juego_iniciado", juego_iniciado)
	_config.set_value("progress", "nivel_actual", nivel_actual)
	_config.set_value("progress", "rangos", rangos)
	_config.set_value("progress", "historia_vista", historia_vista)  # 🔥 guardar historia
	_config.save(_file_path)

# -------- CARGAR --------
func load_data():
	if _config.load(_file_path) == OK:
		lore_vista = bool(_config.get_value("progress", "lore_vista", false))
		juego_iniciado = bool(_config.get_value("progress", "juego_iniciado", false))
		nivel_actual = int(_config.get_value("progress", "nivel_actual", 1))
		rangos = _config.get_value("progress", "rangos", [])
		historia_vista = bool(_config.get_value("progress", "historia_vista", false)) # 🔥 cargar historia

# -------- RANGOS Y DESBLOQUEO --------
func rango_valido(rango: String, minimo: String = "B") -> bool:
	return orden_rangos.find(rango) >= orden_rangos.find(minimo)

func guardar_rango(nivel: int, rango: String) -> void:
	if rangos.size() < nivel:
		rangos.resize(nivel)
	rangos[nivel - 1] = rango

	# desbloquear el siguiente si el rango fue válido
	if rango_valido(rango):
		nivel_actual = max(nivel_actual, nivel + 1)

func nivel_desbloqueado(nivel: int) -> bool:
	return nivel <= nivel_actual
