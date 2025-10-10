extends Node2D

@onready var label: Label = $Panel/NinePatchRect/Label
@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var Flecha_derecha: Sprite2D = $RightInputHitbox/CollisionShape2D/Sprite2D2
@onready var Flecha_izquierda: Sprite2D = $LeftInputHitbox/CollisionShape2D/Sprite2D2
@onready var Flecha_central: Sprite2D = $DownInputHitbox/CollisionShape2D/Sprite2D2


signal hit
signal miss

# vectorsillos donde se van a guardar las flechas q se van a crear
var left_arrows: Array = []
var right_arrows: Array = []
var down_arrows: Array = []

# posiciones *globales* (ya q segun la resolucion puede variar) de cada hitbox
var LEFT_HITBOX_POS: Vector2
var DOWN_HITBOX_POS: Vector2
var RIGHT_HITBOX_POS: Vector2

# Ventana de "acierto" en píxeles
const HIT_WINDOW: float = 60.0

func _ready() -> void:
	LEFT_HITBOX_POS = get_node("LeftInputHitbox/CollisionShape2D").global_position
	DOWN_HITBOX_POS = get_node("DownInputHitbox/CollisionShape2D").global_position
	RIGHT_HITBOX_POS = get_node("RightInputHitbox/CollisionShape2D").global_position
	Flecha_derecha.visible = false
	Flecha_izquierda.visible = false
	Flecha_central.visible = false
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("input_left"):
		check_pego_flecha(left_arrows, LEFT_HITBOX_POS)
		Flecha_izquierda.visible = true
		_esperar_y_ocultar_flecha()
	if Input.is_action_just_pressed("input_right"):
		check_pego_flecha(right_arrows, RIGHT_HITBOX_POS)
		Flecha_derecha.visible = true
		_esperar_y_ocultar_flecha()
	if Input.is_action_just_pressed("input_down"):
		check_pego_flecha(down_arrows, DOWN_HITBOX_POS)
		Flecha_central.visible = true
		_esperar_y_ocultar_flecha()

func _esperar_y_ocultar_flecha() -> void:
	# Esperamos 1 segundo
	await get_tree().create_timer(0.20).timeout
	# Después de esperar, ocultamos la flecha
	Flecha_derecha.visible = false
	Flecha_izquierda.visible = false
	Flecha_central.visible = false

func check_pego_flecha(lista: Array, pos_hitbox: Vector2) -> void:
	# primero, se limpia la lista
	lista = lista.filter(func(a): return a != null and a.is_inside_tree())
	
	# si la lista esta vacia, q vuelva
	if lista.is_empty():
		return
	
	var flecha_disponible = null
	var distancia = INF
	
	for flecha in lista:
		if flecha == null or !flecha.is_inside_tree():
			continue
		var dist = abs(flecha.global_position.y - pos_hitbox.y)
		if dist < distancia:
			distancia = dist
			flecha_disponible = flecha
	
	if flecha_disponible and distancia <= HIT_WINDOW:
		# prefiero primero emitir la señal de q la flecha fue exitosa antes de borrar :p
		hit.emit(flecha_disponible)
		lista.erase(flecha_disponible)
	else:
		miss.emit() # mal ahi :(

####################################################
# Cuando una flecha entra en la hitbox, la guardamos
func _on_left_input_hitbox_body_entered(body: Node2D) -> void:
	left_arrows.append(body)
	body.deleted.connect(func(_x): _on_arrow_deleted(body, left_arrows))

func _on_right_input_hitbox_body_entered(body: Node2D) -> void:
	right_arrows.append(body)
	body.deleted.connect(func(_x): _on_arrow_deleted(body, right_arrows))

func _on_down_input_hitbox_body_entered(body: Node2D) -> void:
	down_arrows.append(body)
	body.deleted.connect(func(_x): _on_arrow_deleted(body, down_arrows))

# elimina la flecha de la lista/vector si se borro
func _on_arrow_deleted(flecha: Node2D, lista: Array) -> void:
	if flecha in lista:
		lista.erase(flecha)
	miss.emit()
