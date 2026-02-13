extends Control

enum State { IDLE, WORKING, BREAK }
var current_state = State.IDLE

var work_seconds: float = 0.0
var break_seconds_left: float = 15 * 60.0 

@onready var work_button = %WorkButton
@onready var break_button = %BreakButton
@onready var main_timer_label = %MainTimerLabel
@onready var header_label = %HeaderLabel

func _ready():
	work_button.pressed.connect(_on_work_button_pressed)
	break_button.pressed.connect(_on_break_button_pressed)
	setup_user_info()
	update_main_timer(0)
	
	work_button.text = "Start Journey"
	break_button.text = "Take Break"
	break_button.disabled = true

func setup_user_info():
	var email = Manager.current_user_email
	if Manager.users.has(email):
		var user_data = Manager.users[email]
		var user_name = user_data.get("name", "User")
		var weekly_total = user_data.get("weekly_seconds", 0.0)
		
		# Actualizar el saludo arriba a la izquierda
		header_label.text = "                                             Hola " + user_name + ", llevas " + format_time_short(weekly_total) + " horas semanales"

func _process(delta):
	if current_state == State.WORKING:
		work_seconds += delta
		update_main_timer(work_seconds)
	elif current_state == State.BREAK:
		break_seconds_left -= delta
		update_main_timer(break_seconds_left)
		if break_seconds_left <= 0:
			current_state = State.IDLE
			main_timer_label.text = "00:00:00"

func _on_work_button_pressed():
	if current_state == State.IDLE:
		current_state = State.WORKING
		work_button.text = "Stop Journey"
		break_button.disabled = false
	else:
		save_and_exit()

func _on_break_button_pressed():
	if current_state == State.WORKING:
		current_state = State.BREAK
		break_button.text = "Resume Work"
		work_button.disabled = true
	elif current_state == State.BREAK:
		current_state = State.WORKING
		break_button.text = "Take Break"
		work_button.disabled = false

func update_main_timer(val):
	main_timer_label.text = format_time_full(val)

func format_time_full(total_seconds):
	var hours = int(total_seconds) / 3600
	var minutes = (int(total_seconds) % 3600) / 60
	var seconds = int(total_seconds) % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

func format_time_short(total_seconds):
	var hours = int(total_seconds) / 3600
	var minutes = (int(total_seconds) % 3600) / 60
	return "%02d:%02d" % [hours, minutes]

func save_and_exit():
	var email = Manager.current_user_email
	if Manager.users.has(email):
		# SUMA CORRECTA: tiempo que ya había + tiempo de ahora
		Manager.users[email]["weekly_seconds"] += work_seconds
		Manager.users[email]["last_week_id"] = Manager.get_week_id()
		Manager.save_to_json()
	
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
