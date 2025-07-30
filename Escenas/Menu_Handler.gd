extends Control

# Menu > Ventanas
@onready var config_tab: Panel = $Panel/Config_Tab
@onready var ajustes_juego: VBoxContainer = $Panel/Config_Tab/NinePatchRect/ajustes_juego
@onready var ajustes_sonido: VBoxContainer = $Panel/Config_Tab/NinePatchRect/ajustes_sonido
@onready var cfg_titulo: Label = $Panel/Config_Tab/NinePatchRect/Cfg_titulo


@onready var settings_tab: Panel = $Panel/Settings_Tab
@onready var botones_side: VBoxContainer = $Panel/Botones_Side


# Menu > Ventanas > Config_Tab > Elementos

func visible_window(levels: bool, config: bool, exit: bool) -> void:
	config_tab.visible = config
	botones_side.visible = levels
	settings_tab.visible = exit

# Code para cada boton y sus respectivas ventanas
func play_pressed() -> void:
	visible_window(true, false, false)
func _on_settings_pressed() -> void:
	visible_window(false, true, false)
	botones_side.visible = false
	
func _on_quit_pressed() -> void:
	visible_window(false, false, true)

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
func _on_salir_pressed() -> void:
	get_tree().quit()


func config_atras_pressed() -> void:
	visible_window(false, false, false)
	botones_side.visible = true

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):  # Escape por defecto
		settings_tab.visible = true
		botones_side.visible = false
