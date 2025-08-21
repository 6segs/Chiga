extends Node

var config := ConfigFile.new()
var file_path := "user://config.cfg"

# Valores por defecto
var keybinds := {}
var master_volume := 1.0
var language := "es"

func _ready():
	load_config()

# ----------- KEYBINDS -----------

func set_keybind(action_name: String, key: InputEventKey) -> void:
	keybinds[action_name] = key.keycode
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, key)
	save_config()

func get_keybind(action_name: String) -> InputEventKey:
	if keybinds.has(action_name):
		var ev := InputEventKey.new()
		ev.keycode = keybinds[action_name]
		return ev
	return null

# ----------- CONFIG GENERAL -----------

func set_volume(vol: float) -> void:
	master_volume = vol
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(vol))
	save_config()

# ----------- GUARDAR / CARGAR -----------

func save_config():
	# Guardar keybinds
	for action_name in keybinds.keys():
		config.set_value("inputs", action_name, keybinds[action_name])

	# Guardar otras configs
	#config.set_value("audio", "master_volume", master_volume)

	config.save(file_path)

func load_config():
	if config.load(file_path) == OK:
		# Cargar keybinds
		if config.has_section("inputs"):
			for action_name in config.get_section_keys("inputs"):
				var keycode = config.get_value("inputs", action_name)
				keybinds[action_name] = keycode

				# Aplicar al InputMap
				var ev := InputEventKey.new()
				ev.keycode = keycode
				InputMap.action_erase_events(action_name)
				InputMap.action_add_event(action_name, ev)
