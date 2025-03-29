extends Node

class_name SandboxLevelManager

var base_path: String = "user://CustomLevels/"

var _extension: String = ".anet"

func _ready() -> void:
	var levels = get_custom_level_paths()
	print(levels)

func get_base_directory() -> DirAccess:
	
	var base_dir: DirAccess
	if not DirAccess.dir_exists_absolute(base_path):
		var result = DirAccess.make_dir_absolute(base_path)
		
		if result != OK:
			print("Error creating custom levels base path: " + base_path)
			return null
		
	base_dir = DirAccess.open(base_path)
	if not base_dir:
		print("Erro opening custom levels base path: " + base_path)	
		return null
	return base_dir
	
func save_custom_level() -> void:
	pass


func load_save_file(file_path: String):
	var absolute_path = base_path + file_path

	if not FileAccess.file_exists(absolute_path):
		print("File {} does not exists".format(absolute_path))
		return []

	var data = []
	var file = FileAccess.open(absolute_path, FileAccess.READ)
	
	
	
	while file.get_position() < file.get_length():
		var json_string = file.get_line().strip_edges()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		data.append(json.data)

	return data


## Data is array of dictionaries (each entry is a dict returned by a save() call)
func write_save_file(data, file_path: String) -> void:
	var absolute_path = base_path + file_path
	if not FileAccess.file_exists(absolute_path):
		print("File {} does not exists".format(absolute_path))
		return
	
	var file = FileAccess.open(absolute_path, FileAccess.WRITE)
	for entry in data:
		file.store_line(JSON.stringify(entry))


func get_next_level_name_with_ext() -> String:
	
	var base_name = "Nuevo nivel"
	
	# Try with the base name without additional numbers
	if not FileAccess.file_exists(base_path + base_name + _extension):
		return base_name + _extension
	
	var numbers = []
	
	var base_dir = get_base_directory()
	for file in base_dir.get_files():
	
		file = file.replace(_extension, "") # remove extension
		if file.begins_with(base_name):		
			var split = file.split(" ")
			if len(split) != 3:
				# file with base_name "Nuevo nivel" => without number
				continue
				
			var number = int(split[2])
			numbers.append(number)
	
	
	var next_number
	
	if len(numbers) == 0:
		next_number = 1
	else:
		next_number = numbers.max() + 1	
	
	return base_name + " " + str(next_number) + _extension
	
func delete_level(level_path: String) -> void:
	var base_dir = get_base_directory()
	if not base_dir:
		return
	
	var result = base_dir.remove(level_path)
	if result != OK:
		print("Error deleting " + level_path)
	

func create_custom_level() -> void:
	var level_path = base_path + get_next_level_name_with_ext()
	
	if FileAccess.file_exists(level_path):
		print("Ya hay un fichero con el mismo nombre")
		return
	
	var file = FileAccess.open(level_path, FileAccess.WRITE)
	if file:
		print(level_path + " creado")

func get_custom_level_paths() -> PackedStringArray:
	var base_dir = get_base_directory()
	var level_paths = []
	
	if not base_dir:
		return level_paths
	
	return base_dir.get_files()
