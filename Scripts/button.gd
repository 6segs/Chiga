extends Button

var awaiting_key := false
var assigned_key : InputEventKey = null

func _ready():
	toggle_mode = true
	text = "Asignar tecla"
	self.toggled.connect(_on_button_toggled)

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

func assigned_key_to_string() -> String:
	if assigned_key:
		return OS.get_keycode_string(assigned_key.keycode)
	else:
		return "Asignar tecla"
