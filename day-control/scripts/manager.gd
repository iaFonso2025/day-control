extends Node

const SAVE_PATH = "user://database.json"
var users = {} 
var current_user_email = "" 

func _ready():
	load_from_json()

func save_to_json():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_data = JSON.stringify(users)
		file.store_string(json_data)
		file.close()

func load_from_json():
	if not FileAccess.file_exists(SAVE_PATH): return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var json = JSON.new()
		if json.parse(content) == OK:
			users = json.data
			check_weekly_reset() # Comprobar reinicio al cargar
		file.close()

# Calcula el número de semana único (ID de semana)
func get_week_id():
	var unix_time = Time.get_unix_time_from_system()
	# 604800 son los segundos de una semana. 
	# Al dividir, obtenemos un número que cambia cada lunes a las 00:00
	return int((unix_time - 345600) / 604800) 

func check_weekly_reset():
	var current_week = get_week_id()
	var changed = false
	
	for email in users:
		# Si la semana guardada es vieja o no existe, resetear
		if not users[email].has("last_week_id") or users[email]["last_week_id"] != current_week:
			users[email]["weekly_seconds"] = 0.0
			users[email]["last_week_id"] = current_week
			changed = true
	
	if changed:
		save_to_json()

# Función para convertir texto plano en un Hash irreconocible
func hash_password(password: String) -> String:
	return password.sha256_text()

# Actualizamos la función de añadir usuario para que guarde el HASH
func add_new_user(email, password, name, company):
	users[email] = {
		"password": hash_password(password), # <--- Guardamos el hash, no la clave real
		"name": name,
		"company": company,
		"weekly_seconds": 0.0,
		"last_week_id": get_week_id()
	}
	save_to_json()
