extends Node

# File path where the user data is stored on the device
const SAVE_PATH = "user://database.json"

# Global variables: the users dictionary and the current session email
var users = {} 
var current_user_email = "" 

func _ready():
	# Load existing data as soon as the app starts
	load_from_json()

func save_to_json():
	# Open the file for writing
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		# Convert the dictionary to a JSON string and save it
		var json_data = JSON.stringify(users)
		file.store_string(json_data)
		file.close()

func load_from_json():
	# Check if the file exists before trying to read it
	if not FileAccess.file_exists(SAVE_PATH): return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var json = JSON.new()
		# Parse the JSON string back into the 'users' dictionary
		if json.parse(content) == OK:
			users = json.data
			# Every time we load, we check if it's a new week to reset hours
			check_weekly_reset()
		file.close()

# Generates a unique ID for the current week based on Unix time
func get_week_id():
	var unix_time = Time.get_unix_time_from_system()
	# 604800 is the number of seconds in one week
	# We subtract an offset to align the reset with Sunday night/Monday morning
	return int((unix_time - 345600) / 604800) 

func check_weekly_reset():
	var current_week = get_week_id()
	var changed = false
	
	# Loop through every user in the database
	for email in users:
		# If the stored week ID is different from current week, reset their time
		if not users[email].has("last_week_id") or users[email]["last_week_id"] != current_week:
			users[email]["weekly_seconds"] = 0.0
			users[email]["last_week_id"] = current_week
			changed = true
	
	# If any user was reset, save the changes to the file immediately
	if changed:
		save_to_json()

# Security: Convert plain text password into a SHA-256 Hash
func hash_password(password: String) -> String:
	return password.sha256_text()

# Create a new user entry with encrypted password and default values
func add_new_user(email, password, name, company):
	users[email] = {
		"password": hash_password(password), # Store the hash, never the real password
		"name": name,
		"company": company,
		"weekly_seconds": 0.0,
		"last_week_id": get_week_id()
	}
	save_to_json()
