extends Button

var awaiting_key := false
var assigned_key : InputEventKey = null

func _ready():
	toggle_mode = true
	text = "-"
	self.toggled.connect(_on_button_toggled)
	_load_keybind()

func _on_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		text = ". . ."
		awaiting_key = true
	else:
		awaiting_key = false
		text = assigned_key_to_string()

func _input(event: InputEvent) -> void:
	if awaiting_key and event is InputEventKey and event.pressed and not event.echo:
		assigned_key = event
		awaiting_key = false
		button_pressed = false
		text = assigned_key_to_string()
		
		var action_name = "input_down"
		InputMap.action_erase_events(action_name) # limpia todos los eventos previos
		InputMap.action_add_event(action_name, assigned_key) # usa el evento capturado
		Cfg.set_keybind(action_name, assigned_key)

func assigned_key_to_string() -> String:
	if assigned_key:
		return OS.get_keycode_string(assigned_key.keycode)
	else:
		return "-"
func _load_keybind():
	assigned_key = Cfg.get_keybind("input_down")
	text = assigned_key_to_string()
