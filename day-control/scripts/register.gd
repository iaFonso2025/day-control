extends Control

@onready var email_field = %EmailInput
@onready var name_field = %NameInput
@onready var company_field = %CompanyInput
@onready var pass_field = %PassInput

@onready var mail_error_label = %MailErrorLabel
@onready var mail_used_error_label = %MailUsedErrorLabel
@onready var pass_error_label = %PassErrorLabel

func _ready():
	%Submit.pressed.connect(_on_submit_pressed)
	%Back.pressed.connect(_on_back_pressed)
	hide_all_errors()

func _on_submit_pressed():
	var email = email_field.text
	var password = pass_field.text
	
	hide_all_errors()

	if not email.ends_with("@cadiz.salesianos.edu"):
		mail_error_label.text = "Error: Use @cadiz.salesianos.edu"
		clear_all_inputs()
		return
	
	if Manager.users.has(email):
		mail_used_error_label.text = "Error: Email already registered"
		clear_all_inputs()
		return

	if password.length() < 12:
		pass_error_label.text = "Error: Password too short (min 12)"
		clear_all_inputs()
		return

	Manager.add_new_user(email, password, email_field.text, company_field.text)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func clear_all_inputs():
	email_field.text = ""
	pass_field.text = ""

func hide_all_errors():
	mail_error_label.text = ""
	mail_used_error_label.text = ""
	pass_error_label.text = ""
