extends Node

@export var arrow_scene: PackedScene
@export var FALL_SPEED: float
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

var last_beat: float = 0.0

# Obviously this is hard-coded for now...
var arrow_timers: Array = [
	["right",0],["right",2],["down",3],
	["left",4],["right",6],["left",7],
	["left",8],["down",10],["down",11],
	["left",12],["right",14],["right",15],
	["left",16],["right",18],["left",19],
	["left",20],["right",22],["left",23],
	["left",24],["down",25],["right",26],["left",27],
	["left",28],["right",30],["left",31],
	["left",32],["left",34],["down",35],
	["right",36],["left",38],["down",39],
	["right",40]]
var arrows_before_music: Array = []

var curr_combo = 0
var max_combo = 0
var score = 0

# Called when the node enters the scene tree for the first time.
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
	$HUD/GameOverMenu/RetryButton.button_down.connect(_on_retry_button_button_down)

	#TODO: Change these to be parsed from specific level data
	$EndTimer.wait_time = 40 # no need to convert
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
	
	compute_offset_beat_times()
	
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !game_has_started:
		if $MusicStartTimer.time_left < TIME_NUMERATOR * QUARTER_NOTE_DURATION:
			var countdown_text = str(max(ceil($MusicStartTimer.time_left / QUARTER_NOTE_DURATION) - 1,0))
			if countdown_text == "0":
				countdown_text = "GO!"
			if countdown_text != $HUD/CountdownLabel.text:
				print(countdown_text)
				if countdown_text == "GO!":
					$CountdownPlayer.stream = load("res://sound/countdown_high.wav")
				
				$CountdownPlayer.playing = true
			$HUD/CountdownLabel.text = countdown_text
			if $MusicStartTimer.time_left == 0:
				game_has_started = true
				$HUD/CountdownLabel.visible = false
				
	if ($Conductor.song_position > last_beat + QUARTER_NOTE_DURATION):
		last_beat += QUARTER_NOTE_DURATION

	if (!arrow_timers.is_empty()):
		if arrow_timers[0][1] <= $Conductor.song_position && arrow_timers[0][1] >= 0:
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
	# Display final score.
	var score_percentage = score / MAX_SCORE
	if score_percentage >= 0.9:
		$HUD/GameOverMenu/FinalRankLabel.text = "Rank S"
	elif score_percentage >= 0.8:
		$HUD/GameOverMenu/FinalRankLabel.text = "Rank A"
	elif score_percentage >= 0.7:
		$HUD/GameOverMenu/FinalRankLabel.text = "Rank B"
	elif score_percentage >= 0.6:
		$HUD/GameOverMenu/FinalRankLabel.text = "Rank C"
	else:
		$HUD/GameOverMenu/FinalRankLabel.text = "Rank D"
	
	if max_combo == MAX_COMBO:
		$HUD/GameOverMenu/ComboLabel.text = "Full Combo!"
	else:
		$HUD/GameOverMenu/ComboLabel.text = "Max Combo:\n" + str(max_combo)
	$HUD/GameOverMenu.visible = true
	#TODO: Show exit and play-again buttons.

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
	# q no se note el chatgpt aca 🫣
	var arrow = arrow_scene.instantiate()  # Instanciás la flecha
	arrow.add_to_group("arrows")           # Le agregás el grupo a la instancia
	arrow.deleted.connect(_on_arrow_missed) # Conectás la señal deleted

	# Posicionamiento según dirección
	if arrow_data[0] == "left":
		arrow.position = $LeftArrowPath/LeftArrowSpawnLocation.position
	elif arrow_data[0] == "down":
		arrow.position = $DownArrowPath/DownArrowSpawnLocation.position
	elif arrow_data[0] == "right":
		arrow.position = $RightArrowPath/RightArrowSpawnLocation.position

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

func _on_retry_button_button_down():
	print("pressed")
	get_tree().reload_current_scene()
