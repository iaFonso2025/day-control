extends Control

# UI References - Using % to find nodes easily in the scene
@onready var email_input = %EmailInput
@onready var pass_input = %PassInput
@onready var error_label = %ErrorLabel 

func _ready():
	# Connect the buttons to their functions when the game starts
	%LoginButton.pressed.connect(_on_login_pressed)
	%RegisterButton.pressed.connect(_on_to_register_pressed)
	
	# Make sure the error message is empty at the beginning
	error_label.text = ""

func _on_login_pressed():
	# Get the text that the user typed
	var email = email_input.text
	var password_typed = pass_input.text
	
	# Clear the error label every time we try to log in
	error_label.text = ""

	# 1. Check if the user exists in our database (Manager dictionary)
	if Manager.users.has(email):
		
		# 2. Encrypt the typed password to compare it safely
		# We compare hashes, not the actual plain text
		var hashed_typed = Manager.hash_password(password_typed)
		var stored_hash = Manager.users[email]["password"]
		
		# 3. Check if the passwords match
		if stored_hash == hashed_typed:
			# If everything is okay, save the email and go to the app
			Manager.current_user_email = email
			get_tree().change_scene_to_file("res://scenes/AppInterface.tscn")
		else:
			# Wrong password case
			show_error("Contraseña incorrecta")
	else:
		# Email not found case
		show_error("El usuario no existe")

# Function to show errors in red and reset the inputs
func show_error(msg: String):
	error_label.text = msg
	email_input.text = ""
	pass_input.text = ""

# Go to the register screen
func _on_to_register_pressed():
	get_tree().change_scene_to_file("res://scenes/Register.tscn")
