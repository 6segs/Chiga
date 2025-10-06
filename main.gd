extends Node

@export var arrow_right_scene: PackedScene
@export var arrow_center_scene : PackedScene
@export var arrow_left_scene : PackedScene
@export var FALL_SPEED: float

@onready var chiga: AnimatedSprite2D = $Chiga
@onready var meiko_happy: AnimatedSprite2D = $Meiko_happy
@onready var meiko_agry: AnimatedSprite2D = $Meiko_agry
@onready var paraguas: AnimatedSprite2D = $Paraguas
@onready var sin_ojos: AnimatedSprite2D = $sin_ojos
@onready var narigon: AnimatedSprite2D = $Narigon


const st_texto = preload("res://Objects/texto.tscn")
var BPM: float
var TIME_NUMERATOR: float
var QUARTER_NOTES_PER_SECOND: float
var QUARTER_NOTE_DURATION: float
var MEASURE_DURATION: float
var FALL_DURATION: float
var music_has_intro

var PERFECT_TIMING_Y: float
var PERFECT_POINTS: float = 1000
var GOOD_POINTS: float = 800
var OK_POINTS: float = 500
var MAX_SCORE: float
var MAX_COMBO

var LOADING_DELAY_OFFSET: float = 0.1

var game_has_started = false
var play_countdown_sfx = false

var nivel_iniciado: bool = false
var paso_nivel = false

var last_beat: float = 0.0

# gugy, te deseo suerte cuando tengas q hacer esto D:
var arrow_timers: Array = []
var arrows_before_music: Array = []
#niveles
var nivel1_iniciado = false 
var nivel2_iniciado = false 
var nivel3_iniciado = false 
var curr_combo = 0
var max_combo = 0
var score = 0
var DURACIONES_NIVELES := {
	1: 57.0,
	2: 60.0,
	3: 80.0,
	4: 100.0
}
##############################################################
# basicamente el init de todo
func _ready() -> void:
	# es tan estupido esto -_-
	$Player/LeftInputHitbox/MissZone.arrow_missed.connect(_on_arrow_missed)
	$Player/RightInputHitbox/MissZone.arrow_missed.connect(_on_arrow_missed)
	$Player/DownInputHitbox/MissZone.arrow_missed.connect(_on_arrow_missed)
	$StartTimer.timeout.connect(_on_start_timer_timeout)
	$EndTimer.timeout.connect(_on_end_timer_timeout)
	$MusicStartTimer.timeout.connect(_on_music_start_timer_timeout)
	$Conductor.beat.connect(_on_conductor_beat)
	$Player.hit.connect(_on_player_hit)
	$Player.miss.connect(_on_player_miss)
	$HUD/GameOverMenu/NinePatchRect/GoBackButton.button_down.connect(_go_back_button)
	# $Conductor.stream = preload("res://Recursos/Audios/cancion_1_chiga.mp3")
	$HitPlayer.stream = preload("res://Recursos/Audios/clap_1.wav")
	$CountdownPlayer.stream = preload("res://Recursos/Audios/countdown_high.wav")
	$FinalSFX.stream = preload("res://Recursos/Audios/sfx_perder.mp3")
	arrows_before_music.clear()
	music_has_intro = false
	BPM = 84
	TIME_NUMERATOR = 4
	QUARTER_NOTES_PER_SECOND = BPM / 60
	QUARTER_NOTE_DURATION = 60 / BPM
	MEASURE_DURATION = TIME_NUMERATOR * QUARTER_NOTE_DURATION
	if music_has_intro:
		pass
	
	PERFECT_TIMING_Y = get_node("Player/LeftInputHitbox/CollisionShape2D").position.y
	
	MAX_COMBO = arrow_timers.size()
	MAX_SCORE = PERFECT_POINTS * arrow_timers.size()
	
	FALL_DURATION = (PERFECT_TIMING_Y + 60) / FALL_SPEED
	# Duraciones de cada nivel (en segundos)
	chiga.visible = false
	compute_offset_beat_times()
	new_game()
	Global.aplicar_volumenes()

func iniciar_nivel():
	# Reiniciar variables comunes
	arrows_before_music.clear()
	curr_combo = 0
	max_combo = 0
	score = 0
	last_beat = 0.0

	# Asignar flechas según nivel
	match Global.nivel_actual:
		1:
			arrow_timers = [["left",22],["right",35],["down",49]] # tu lista completa
			FALL_SPEED = 100 
			BPM = 100
		2:
			arrow_timers = [["left",4],["right",6],["left",7],
	["left",8],["down",10],["down",11],
	["left",12],["right",14],["right",15],
	["left",16],["right",18],["left",19],
	["left",20],["right",22],["left",23],
	["left",24],["down",25],["right",26],["left",27],
	["left",28],["right",30],["left",31],
	["left",32],["left",34],["down",35],
	["right",36],["left",38],["down",39],
	["right",40]] # tu lista completa
			FALL_SPEED = 120 
		3:
			arrow_timers = [["left",4],["right",6],["left",7],
	["left",8],["down",10],["down",11],
	["left",12],["right",14],["right",15],
	["left",16],["right",18],["left",19],
	["left",20],["right",22],["left",23],
	["left",24],["down",25],["right",26],["left",27],
	["left",28],["right",30],["left",31],
	["left",32],["left",34],["down",35],
	["right",36],["left",38],["down",39],
	["right",40]]
			FALL_SPEED = 250
		4:
			arrow_timers = [["left",4],["right",6],["left",7],
	["left",8],["down",10],["down",11],
	["left",12],["right",14],["right",15],
	["left",16],["right",18],["left",19],
	["left",20],["right",22],["left",23],
	["left",24],["down",25],["right",26],["left",27],
	["left",28],["right",30],["left",31],
	["left",32],["left",34],["down",35],
	["right",36],["left",38],["down",39],
	["right",40]]
			FALL_SPEED = 400
	FALL_DURATION = (PERFECT_TIMING_Y + 60) / FALL_SPEED
	# Calcular combos y puntajes máximos
	MAX_COMBO = arrow_timers.size()
	MAX_SCORE = PERFECT_POINTS * arrow_timers.size()
	compute_offset_beat_times()
	$EndTimer.wait_time = DURACIONES_NIVELES.get(Global.nivel_actual, 40.0)
	$EndTimer.start()
	# Asignar música
	asignar_musica_según_nivel()
	cambiar_sprite_por_nivel()
	# Preparar countdown
	game_has_started = false
	$HUD/CountdownLabel.visible = true
	$HUD/CountdownLabel.text = ""    # empezar vacío
	$CountdownPlayer.stream = preload("res://Recursos/Audios/countdown_high.wav") # beep genérico

func cambiar_sprite_por_nivel():
	match Global.nivel_actual:
		1:
			chiga.visible= true
			meiko_happy.visible = true
			meiko_happy.play("Run")
		2:
			chiga.visible= true
			paraguas.visible = true
		3:
			chiga.visible= true
			sin_ojos.visible = true
		4:
			chiga.visible= true
			narigon.visible = true
 
func manejar_countdown():
	var beats_left = ceil($MusicStartTimer.time_left / QUARTER_NOTE_DURATION)
	var countdown_text = ""

	# Mostrar READY primero
	if beats_left > 3:
		countdown_text = "READY..."
	elif beats_left == 3:
		countdown_text = "3"
	elif beats_left == 2:
		countdown_text = "2"
	elif beats_left == 1:
		countdown_text = "1"
	elif beats_left == 0:
		countdown_text = "GO!"

	# Solo actualizar si cambió el texto
	if countdown_text != $HUD/CountdownLabel.text:
		print(countdown_text)
		if countdown_text == "GO!":
			chiga.play("Run")
			paraguas.play("Run")
			sin_ojos.play("Run")
			narigon.play("Run")
			$CountdownPlayer.stream = load("res://Recursos/Audios/sfx_inicio_nivel.mp3")
		else:
			$CountdownPlayer.stream = preload("res://Recursos/Audios/countdown_high.wav")
		$CountdownPlayer.playing = true


	$HUD/CountdownLabel.text = countdown_text

	# Cuando ya terminó la cuenta → arrancar el juego
	if countdown_text == "GO!":
		game_has_started = true
		await get_tree().create_timer(1.0).timeout
		$HUD/CountdownLabel.visible = false

func asignar_musica_según_nivel():
	match Global.nivel_actual:
		1:
			$Conductor.stream = preload("res://Recursos/Audios/(2) menu_chiga.mp3")
		2:
			$Conductor.stream = preload("res://Recursos/Audios/chiga.mp3")
		3:
			$Conductor.stream = preload("res://Recursos/Audios/cancion_level2_chiga.mp3")
		4:
			$Conductor.stream = preload("res://Recursos/Audios/2023-02-16-#29.mp3")
		_:
			$Conductor.stream = preload("res://Recursos/Audios/cancion_level2_chiga.mp3")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Global.juego_iniciado:
		if Global.juego_iniciado and !nivel_iniciado:
			iniciar_nivel()
			nivel_iniciado = true

		# Si el nivel está iniciado pero el juego no empezó todavía,
		# mostramos/actualizamos el countdown cada frame
		if nivel_iniciado and not game_has_started:
			manejar_countdown()


	# ============================
	# LÓGICA GENERAL — sólo ejecuta después de que game_has_started == true
	# ============================
	if game_has_started:
		if ($Conductor.song_position > last_beat + QUARTER_NOTE_DURATION):
			last_beat += QUARTER_NOTE_DURATION

		if (!arrow_timers.is_empty()):
			if arrow_timers[0][1] <= $Conductor.song_position and arrow_timers[0][1] >= 0:
				var arrow = arrow_timers.pop_front()
				spawn_arrow(arrow)

		if (!arrows_before_music.is_empty()):
			if abs(arrows_before_music[0][1]) >= $MusicStartTimer.time_left:
				var arrow = arrows_before_music.pop_front()
				spawn_arrow(arrow)

		$HUD/VBoxContainer/ScoreLabel.text = "Puntos: " + str(score)
		$HUD/VBoxContainer/ComboLabel.text = "Combo: " + str(curr_combo) + "X"


func new_game():
	$StartTimer.start()

func game_over():
	var score_percentage = score / MAX_SCORE
	var rango_final: String

	if score_percentage >= 0.9:
		rango_final = "S"
	elif score_percentage >= 0.8:
		rango_final = "A"
	elif score_percentage >= 0.7:
		rango_final = "B"
	elif score_percentage >= 0.6:
		rango_final = "C"
	else:
		rango_final = "D"

	$HUD/GameOverMenu/NinePatchRect/FinalRankLabel.text = "Rank " + rango_final
	if max_combo == MAX_COMBO:
		$HUD/GameOverMenu/NinePatchRect/ComboLabel.text = "Full Combo!"
	else:
		$HUD/GameOverMenu/NinePatchRect/ComboLabel.text = "Max Combo:\n" + str(max_combo)

	Global.guardar_rango(Global.nivel_actual, rango_final)
	Global.save_data()

	if Global.rango_valido(rango_final):  # solo si el rango es suficiente
		if Global.nivel_actual >= Global.nivel_max:
			Global.nivel_max = Global.nivel_actual + 1
		$FinalSFX.stream = load("res://Recursos/Audios/sfx_ganar_nivel.mp3")
	else:
		$FinalSFX.stream = load("res://Recursos/Audios/sfx_perder.mp3")
	$FinalSFX.play()
	$HUD/GameOverMenu.visible = true
func _on_nivel_completado():
	# supongamos que calculás el rango en alguna variable
	var rango_obtenido = Global.guardar_rango
	Global.guardar_rango(Global.nivel_actual, rango_obtenido)

	if Global.nivel_actual >= Global.nivel_max:
		Global.nivel_max = Global.nivel_actual + 1
	
	Global.save_data()



func _on_start_timer_timeout() -> void:
	$EndTimer.start()
	
	var first_arrow_delay = (PERFECT_TIMING_Y + 60) / FALL_SPEED
	var countdown_delay = QUARTER_NOTE_DURATION * TIME_NUMERATOR

	if (countdown_delay < first_arrow_delay):
		# $ArrowTimer.wait_time = 0.00001
		$MusicStartTimer.wait_time = first_arrow_delay
	else:
		# $ArrowTimer.wait_time = countdown_delay - first_arrow_delay
		$MusicStartTimer.wait_time = countdown_delay
	
	$MusicStartTimer.start()
	
func _on_end_timer_timeout() -> void:
	game_over()
	
func _on_music_start_timer_timeout() -> void:
	$Conductor.playing = true

func _on_conductor_beat(_last_reported_beat) -> void:
	pass
	
func spawn_arrow(arrow_data):
	var arrow: RigidBody2D

	match arrow_data[0]:
		"left":
			arrow = arrow_right_scene.instantiate()
			arrow.position = $LeftArrowPath/LeftArrowSpawnLocation.position
		"down", "center":   # usan el mismo scene
			arrow = arrow_center_scene.instantiate()
			arrow.position = $DownArrowPath/DownArrowSpawnLocation.position
		"right":
			arrow = arrow_left_scene.instantiate()
			arrow.position = $RightArrowPath/RightArrowSpawnLocation.position
		_:
			return
	
	arrow.add_to_group("arrows")
	arrow.deleted.connect(_on_arrow_missed)
	arrow.linear_velocity = Vector2.DOWN * FALL_SPEED

	add_child(arrow)




func _on_player_hit(body) -> void:
	if body == null:
		return
	update_score_and_play_sfx(body)
	update_combo()
	remove_child(body)

func _on_arrow_missed(body):
	_on_player_miss()

	# Instanciar texto
	var pt_inst = st_texto.instantiate()
	get_tree().get_root().call_deferred("add_child", pt_inst)

	# Mostrarlo en la posición de la flecha que fue missed
	pt_inst.position = body.global_position + Vector2(-100, 0)

	pt_inst.DefTexto("Miss")

	await get_tree().create_timer(1.0).timeout
	pt_inst.queue_free()


func _on_player_miss() -> void:
	curr_combo = 0

func update_score_and_play_sfx(body: RigidBody2D):
	$HitPlayer.playing = true
	var y_diff = abs(body.position.y - PERFECT_TIMING_Y)

	var pt_inst = st_texto.instantiate()
	get_tree().get_root().call_deferred("add_child", pt_inst)
	pt_inst.position = body.global_position + Vector2(-100, 0)

	if y_diff <= 50:
		score += PERFECT_POINTS
		pt_inst.DefTexto("PERFECTO!")
		print("PERFECT")
	elif y_diff <= 70:
		score += GOOD_POINTS
		pt_inst.DefTexto("Bien")
		print("GOOD")
	else:
		score += OK_POINTS
		pt_inst.DefTexto("Ok")
		print("OK")
	
	await get_tree().create_timer(1.0).timeout
	pt_inst.queue_free()

func update_combo():
	curr_combo += 1
	max_combo = max(curr_combo, max_combo)
	
func compute_offset_beat_times():
	for i in range(arrow_timers.size()):
		arrow_timers[i][1] = (arrow_timers[i][1] * (60 / BPM)) - FALL_DURATION - LOADING_DELAY_OFFSET
		
	var num_negative = 0
	for i in range(arrow_timers.size()):
		if arrow_timers[i][1] < 0:
			arrows_before_music.append(arrow_timers[i])
			num_negative += 1
			
	arrow_timers = arrow_timers.slice(num_negative, arrow_timers.size())
	

func _go_back_button():
	get_tree().change_scene_to_file("res://Escenas/Menu_Principal.tscn")
	
