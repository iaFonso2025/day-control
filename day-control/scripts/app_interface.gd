extends Control

# Application States: IDLE (Stopped), WORKING (Counting time), BREAK (Pause)
enum State { IDLE, WORKING, BREAK }
var current_state = State.IDLE

# Time variables
var work_seconds: float = 0.0
var break_seconds_left: float = 0.12 * 60.0 # Converted to seconds
var alarm_played: bool = false

# Control to allow only one break per work session
var break_already_used: bool = false 

# UI References using Scene Unique Names (%)
@onready var work_button = %WorkButton
@onready var break_button = %BreakButton
@onready var main_timer_label = %MainTimerLabel
@onready var header_label = %HeaderLabel
@onready var audio_player = %AudioStreamPlayer2D

func _ready():
	# Connect button clicks and audio signals to their functions
	work_button.pressed.connect(_on_work_button_pressed)
	break_button.pressed.connect(_on_break_button_pressed)
	audio_player.finished.connect(_on_audio_finished)
	
	# Load user data and initialize the screen
	setup_user_info()
	update_main_timer(0)
	
	work_button.text = "Iniciar Jornada"
	break_button.text = "Descanso"
	break_button.disabled = true

func setup_user_info():
	# Get the logged-in user from the Global Manager
	var email = Manager.current_user_email
	if Manager.users.has(email):
		var user_data = Manager.users[email]
		var user_name = user_data.get("name", "Usuario")
		var total_acumulado = user_data.get("weekly_seconds", 0.0)
		# Display the personalized greeting and total weekly hours
		header_label.text = "                                 Hola " + user_name + ", llevas " + format_time_short(total_acumulado) + " horas semanales"

func _process(delta):
	# This runs every frame to update the active timer
	match current_state:
		State.WORKING:
			work_seconds += delta
			update_main_timer(work_seconds)
			
		State.BREAK:
			break_seconds_left -= delta
			update_main_timer(break_seconds_left)
			
			# Check if break time is over
			if break_seconds_left <= 0:
				break_seconds_left = 0
				update_main_timer(0)
				if not alarm_played:
					_start_alarm_sequence()

func _start_alarm_sequence():
	# Stop everything and play the 4-second alarm
	alarm_played = true
	current_state = State.IDLE 
	audio_player.play()
	
	# Mark the break as used so it can't be clicked again
	break_already_used = true 
	break_button.disabled = true
	break_button.text = "Descanso Agotado"

func _on_audio_finished():
	# When the sound ends, automatically resume the work timer
	current_state = State.WORKING
	alarm_played = false
	
	work_button.text = "Detener Jornada"
	work_button.disabled = false
	
	# Ensure the break button stays disabled
	break_button.disabled = true
	break_button.text = "Descanso Agotado"

func _on_work_button_pressed():
	if current_state == State.IDLE:
		# Start the session
		current_state = State.WORKING
		work_button.text = "Detener Jornada"
		
		# Only enable break if it hasn't been used before in this session
		if not break_already_used:
			break_button.disabled = false
			break_button.text = "Tomar Descanso"
		else:
			break_button.disabled = true
			break_button.text = "Descanso Agotado"
	else:
		# If already working, save data and quit
		save_and_exit()

func _on_break_button_pressed():
	if current_state == State.WORKING and not break_already_used:
		# Switch from work to break
		current_state = State.BREAK
		break_button.text = "Reanudar"
		work_button.disabled = true
	elif current_state == State.BREAK:
		# Manual resume before the timer hits zero
		current_state = State.WORKING
		break_button.text = "Tomar Descanso"
		work_button.disabled = false

func update_main_timer(time_val):
	# Update the big timer on screen
	main_timer_label.text = format_time_full(time_val)

func format_time_full(total_seconds):
	# Format to HH:MM:SS
	var hours = int(total_seconds) / 3600
	var minutes = (int(total_seconds) % 3600) / 60
	var seconds = int(total_seconds) % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

func format_time_short(total_seconds):
	# Format to HH:MM for the header
	var hours = int(total_seconds) / 3600
	var minutes = (int(total_seconds) % 3600) / 60
	return "%02d:%02d" % [hours, minutes]

func save_and_exit():
	# Update the JSON database before closing the app
	var email = Manager.current_user_email
	if Manager.users.has(email):
		# Accumulate the seconds worked in this session to the total
		Manager.users[email]["weekly_seconds"] += work_seconds
		# Save current week ID for the Sunday reset logic
		Manager.users[email]["last_week_id"] = Manager.get_week_id()
		Manager.save_to_json()
	
	# Go back to the login screen
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
