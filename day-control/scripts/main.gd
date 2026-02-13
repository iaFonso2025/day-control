extends Control

@onready var email_input = %EmailInput
@onready var pass_input = %PassInput
@onready var error_label = %ErrorLabel # Referencia al nuevo Label

func _ready():
	# Conexión de botones
	%LoginButton.pressed.connect(_on_login_pressed)
	%RegisterButton.pressed.connect(_on_to_register_pressed)
	
	# Limpiamos el error al arrancar
	error_label.text = ""

func _on_login_pressed():
	var email = email_input.text
	var password_typed = pass_input.text
	
	# Reset del mensaje de error cada vez que pulsamos
	error_label.text = ""

	# 1. Comprobamos si el usuario existe
	if Manager.users.has(email):
		# 2. Hasheamos la contraseña escrita para compararla
		var hashed_typed = Manager.hash_password(password_typed)
		var stored_hash = Manager.users[email]["password"]
		
		if stored_hash == hashed_typed:
			# LOGIN ÉXITO
			Manager.current_user_email = email
			get_tree().change_scene_to_file("res://scenes/AppInterface.tscn")
		else:
			# ERROR: Contraseña mal
			show_error("Contraseña incorrecta")
	else:
		# ERROR: Correo no existe
		show_error("El usuario no existe")

func show_error(msg: String):
	error_label.text = msg
	# Opcional: limpiar los campos cuando hay error
	email_input.text = ""
	pass_input.text = ""

func _on_to_register_pressed():
	get_tree().change_scene_to_file("res://scenes/Register.tscn")
