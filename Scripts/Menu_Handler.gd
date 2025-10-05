extends Control

# todo esto es tedioso, pero bueno . . .
# Menu > Ventanas
@onready var config_tab: Panel = $Panel/Config_Tab
@onready var ajustes_juego: VBoxContainer = $Panel/Config_Tab/NinePatchRect/ajustes_juego
@onready var ajustes_sonido: VBoxContainer = $Panel/Config_Tab/NinePatchRect/ajustes_sonido
@onready var cfg_titulo: Label = $Panel/Config_Tab/NinePatchRect/Cfg_titulo
@onready var play_tab: Panel = $Panel/Play_Tab
@onready var panel: Panel = $Panel
@onready var info_holder: Panel = $Panel/Play_Tab/Info_Holder
@onready var info_holder_2: Panel = $Panel/Play_Tab/Info_Holder2
@onready var info_holder_3: Panel = $Panel/Play_Tab/Info_Holder3

@onready var settings_tab: Panel = $Panel/Settings_Tab
@onready var botones_side: VBoxContainer = $Panel/Botones_Side

# settings > sonido
@onready var master_volumen: HSlider = $Panel/Config_Tab/NinePatchRect/ajustes_sonido/master_volumen/master_volumen_slider
@onready var label_master: Label = $Panel/Config_Tab/NinePatchRect/ajustes_sonido/master_volumen

@onready var music_volumen: HSlider = $Panel/Config_Tab/NinePatchRect/ajustes_sonido/music_volumen/music_volumen_slider
@onready var label_music: Label = $Panel/Config_Tab/NinePatchRect/ajustes_sonido/music_volumen

@onready var sfx_volumen: HSlider = $Panel/Config_Tab/NinePatchRect/ajustes_sonido/sfx_volumen/sfx_volumen_slider
@onready var label_sfx: Label = $Panel/Config_Tab/NinePatchRect/ajustes_sonido/sfx_volumen

# ------------------- BOTONES DE NIVELES -------------------
# Ajustá la ruta según dónde estén los botones en tu escena
@onready var tutorial: Button = $Panel/Play_Tab/Info_Holder/NinePatchRect2/tutorial
@onready var boton_nivel1: Button = $Panel/Play_Tab/Info_Holder/NinePatchRect4/Nivel1
@onready var boton_nivel2: Button = $"Panel/Play_Tab/Info_Holder2/NinePatchRect4/Nivel 2"
@onready var boton_nivel3: Button = $Panel/Play_Tab/Info_Holder3/NinePatchRect4/Nivel3


# buses de audio
var bus_master: int
var bus_music: int
var bus_sfx: int

@onready var musica: AudioStreamPlayer = $musica
var musica_de_gameplay = preload("res://Recursos/Audios/(2) menu_chiga.mp3")

func _ready() -> void:
	Cfg.load_config()
	musica.play()
	musica.finished.connect(_on_musica_finished)
	
	bus_master = AudioServer.get_bus_index("Master")
	bus_music = AudioServer.get_bus_index("Musica")
	bus_sfx = AudioServer.get_bus_index("SFX")
	
	master_volumen.value_changed.connect(_on_master_slider_val)
	music_volumen.value_changed.connect(_on_music_slider_val)
	sfx_volumen.value_changed.connect(_on_sfx_slider_val)
	
	# init sliders
	init_sliders()
	panel.visible = true
	actualizar_botones_niveles()
# ----------------- BLOQUEO DE NIVELES -----------------
func actualizar_botones_niveles():
	tutorial.disabled = false  # El tutorial siempre disponible
	boton_nivel1.disabled = Global.nivel_max < 1
	boton_nivel2.disabled = Global.nivel_max < 2
	boton_nivel3.disabled = Global.nivel_max < 3


# ------------------- SLIDERS -------------------
# Menu > Ventanas > Config_Tab > Elementos
func init_sliders() -> void:
	# Master
	var vol_master = db_to_linear(AudioServer.get_bus_volume_db(bus_master))
	master_volumen.value = int(vol_master * 100)
	actualizar_label(label_master, "Master", master_volumen.value)

	# Musica
	var vol_music = db_to_linear(AudioServer.get_bus_volume_db(bus_music))
	music_volumen.value = int(vol_music * 100)
	actualizar_label(label_music, "Music", music_volumen.value)

	# SFX
	var vol_sfx = db_to_linear(AudioServer.get_bus_volume_db(bus_sfx))
	sfx_volumen.value = int(vol_sfx * 100)
	actualizar_label(label_sfx, "SFX", sfx_volumen.value)

func actualizar_label(label: Label, nombre: String, valor: float) -> void:
	label.text = nombre + ": " + str(int(valor)) + "%"

func _on_master_slider_val(valor: float) -> void:
	AudioServer.set_bus_volume_db(bus_master, linear_to_db(valor / 100.0))
	actualizar_label(label_master, "Master", valor)

func _on_music_slider_val(valor: float) -> void:
	AudioServer.set_bus_volume_db(bus_music, linear_to_db(valor / 100.0))
	$musica.volume_db = linear_to_db(valor / 100.0)
	actualizar_label(label_music, "Musica", valor)

func _on_sfx_slider_val(valor: float) -> void:
	AudioServer.set_bus_volume_db(bus_sfx, linear_to_db(valor / 100.0))
	$sonidos.volume_db = linear_to_db(valor / 100.0)
	actualizar_label(label_sfx, "SFX", valor)

# --------------------------------------------------
# ------------------- VENTANAS ---------------------
func visible_window(levels: bool, config: bool, exit: bool, buttons: bool) -> void:
	play_tab.visible = levels
	config_tab.visible = config
	botones_side.visible = buttons
	settings_tab.visible = exit
	$sonidos.stream = load("res://Recursos/Audios/sfx_pasar_por_arriba_a_algo.mp3")
	$sonidos.playing = true
	
func visible_game(info1: bool, info2: bool, info3: bool) -> void:
	info_holder.visible = info1
	info_holder_2.visible = info2
	info_holder_3.visible = info3

# --------------------------------------------------
# ------------------- BOTONES ----------------------
func play_pressed() -> void:
	visible_window(true, false, false, false)

func _on_settings_pressed() -> void:
	visible_window(false, true, false, false)
	
func _on_quit_pressed() -> void:
	visible_window(false, false, true, false)
	if $musica.playing: # Esto pausa la musica al apretar salir
		$musica.stream_paused = true

#Code > Ventanas > Config
func _on_sonido_pressed() -> void:
	ajustes_juego.visible = false
	ajustes_sonido.visible = true
	cfg_titulo.text = "Ajustes de sonido"

func _on_juego_pressed() -> void:
	ajustes_juego.visible = true
	ajustes_sonido.visible = false
	cfg_titulo.text = "Ajustes de juego"

func cfg_exit_pressed() -> void:
	visible_window(false, false, false, true)

# Code > Ventanas > Exit
func _on_volver_pressed() -> void:
	visible_window(false, false, false, true)
	if $musica.stream_paused: #Esto despausa la musica al apretar volver
		$musica.stream_paused = false

func _on_salir_pressed() -> void:
	get_tree().quit()

func config_atras_pressed() -> void:
	visible_window(false, false, false, true)

# Pausa la Musica cuando se pone la ventana de salir apretando la tecla escape
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):  # Escape por defecto
		visible_window(false,false,true, false)
		if $musica.playing:
			$musica.stream_paused = true

func _on_volver_play_pressed() -> void:
	visible_window(false, false, false, true)

func _on_musica_finished() -> void:
	musica.play()

# ---------------- BOTONES DE NIVELES ----------------
func _on_button_pressed() -> void:
	visible_game(true,false,false)
	
func _on_button_2_pressed() -> void:
	visible_game(false,true,false)

func _on_button_3_pressed() -> void:
	visible_game(false,false,true)

func _on_tutorial_pressed() -> void:
	Global.juego_iniciado = true
	Global.nivel_actual = 1
	Global.save_data()
	get_tree().change_scene_to_file("res://Escenas/Niveles/main.tscn")
func _on_jogoo_pressed() -> void:
	Global.juego_iniciado = true
	Global.nivel_actual = 2
	Global.save_data()
	if not Global.lore_vista:
		get_tree().change_scene_to_file("res://Lore.tscn")
	else:
		get_tree().change_scene_to_file("res://Escenas/Niveles/main.tscn")
	
func _on_nivel_2_pressed() -> void:
	Global.juego_iniciado = true
	Global.nivel_actual = 3
	Global.save_data()
	get_tree().change_scene_to_file("res://Escenas/Niveles/main.tscn")
	
func _on_nivel_3_pressed() -> void:
	Global.juego_iniciado = true
	Global.nivel_actual = 4
	Global.save_data()
	get_tree().change_scene_to_file("res://Escenas/Niveles/main.tscn")
