extends Control

# --- UI NODES ---
# Getting references to input fields for user data
@onready var email_field = %EmailInput
@onready var name_field = %NameInput
@onready var company_field = %CompanyInput
@onready var pass_field = %PassInput

# References to labels that will show specific error messages
@onready var mail_error_label = %MailErrorLabel
@onready var mail_used_error_label = %MailUsedErrorLabel
@onready var pass_error_label = %PassErrorLabel

func _ready():
	# Connect buttons to their logic functions
	%Submit.pressed.connect(_on_submit_pressed)
	%Back.pressed.connect(_on_back_pressed)
	
	# Start with a clean interface
	hide_all_errors()

func _on_submit_pressed():
	var email = email_field.text
	var password = pass_field.text
	
	# Clear previous errors before validating again
	hide_all_errors()

	# 1. DOMAIN VALIDATION: Check for the specific school email domain
	if not email.ends_with("@cadiz.salesianos.edu"):
		mail_error_label.text = "Error: Use @cadiz.salesianos.edu"
		clear_all_inputs()
		return
	
	# 2. DUPLICATE CHECK: Verify if the email already exists in the database
	if Manager.users.has(email):
		mail_used_error_label.text = "Error: Email already registered"
		clear_all_inputs()
		return

	# 3. SECURITY POLICY: Force a minimum password length
	if password.length() < 12:
		pass_error_label.text = "Error: Password too short (min 12)"
		clear_all_inputs()
		return

	# If all checks pass, register the user in the Global Manager and go back to Login
	Manager.add_new_user(email, password, email_field.text, company_field.text)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_back_pressed():
	# Navigation to return to the main login screen
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func clear_all_inputs():
	# Helper to reset the form
	email_field.text = ""
	pass_field.text = ""

func hide_all_errors():
	# Resets all error messages to empty strings
	mail_error_label.text = ""
	mail_used_error_label.text = ""
	pass_error_label.text = ""
