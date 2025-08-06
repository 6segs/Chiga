extends Control

# Menu > Ventanas
@onready var config_tab: Panel = $Panel/Config_Tab
@onready var ajustes_juego: VBoxContainer = $Panel/Config_Tab/NinePatchRect/ajustes_juego
@onready var ajustes_sonido: VBoxContainer = $Panel/Config_Tab/NinePatchRect/ajustes_sonido
@onready var cfg_titulo: Label = $Panel/Config_Tab/NinePatchRect/Cfg_titulo


@onready var settings_tab: Panel = $Panel/Settings_Tab
@onready var botones_side: VBoxContainer = $Panel/Botones_Side

# Variable de Audio
@onready var music: AudioStreamPlayer = $AudioStreamPlayer
var musica_menu = preload("res://Recursos/Audios/(1) intro_chiga_alt.wav")
func _ready() -> void:
	music.stream = musica_menu
	#music.play()
	
# Menu > Ventanas > Config_Tab > Elementos

func visible_window(levels: bool, config: bool, exit: bool) -> void:
	config_tab.visible = config
	botones_side.visible = levels
	settings_tab.visible = exit

# Code para cada boton y sus respectivas ventanas
func play_pressed() -> void:
	visible_window(true, false, false)
	get_tree().change_scene_to_file("res://Escenas/Niveles/main.tscn")
	
func _on_settings_pressed() -> void:
	visible_window(false, true, false)
	
func _on_quit_pressed() -> void:
	visible_window(false, false, true)
	if music.playing: # Esto pausa la musica al apretar salir
		music.stream_paused = true

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
	visible_window(false, false, false)
	botones_side.visible = true

# Code > Ventanas > Exit
func _on_volver_pressed() -> void:
	visible_window(false, false, false)
	botones_side.visible = true
	if music.stream_paused: #Esto despausa la musica al apretar volver
		music.stream_paused = false

func _on_salir_pressed() -> void:
	get_tree().quit()


func config_atras_pressed() -> void:
	visible_window(true, false, false)

# Pausa la Musica cuando se pone la ventana de salir apretando la tecla escape
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):  # Escape por defecto
		visible_window(false,false,true)
		if music.playing:
			music.stream_paused = true
