extends Control

# Menu > Ventanas
@onready var config_tab: Panel = $Panel/Config_Tab
@onready var settings_tab: Panel = $Panel/Settings_Tab


# Menu > Ventanas > Config_Tab > Elementos

func visible_window(levels: bool, config: bool, exit: bool) -> void:
	config_tab.visible = config
	settings_tab.visible = exit

# Code para cada boton y sus respectivas ventanas
func play_pressed() -> void:
	visible_window(true, false, false)
func _on_settings_pressed() -> void:
	visible_window(false, true, false)
func _on_quit_pressed() -> void:
	visible_window(false, false, true)

#Code > Ventanas > Config
func cfg_exit_pressed() -> void:
	visible_window(false, false, false)

# Code > Ventanas > Exit
func _on_volver_pressed() -> void:
	visible_window(false, false, false)
func _on_salir_pressed() -> void:
	get_tree().quit()
