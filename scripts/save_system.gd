extends Node

var save_data = {
	"unlocked_levels": ["level_01"],
	"level_stars": {
		"level_01": 0,
		"level_02": 0,
		"level_03": 0
	}
}

const SAVE_PATH = "user://savegame.save"

func _ready():
	load_game()

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)
		file.store_string(json_string)
		print("Игра сохранена!")

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("Сохранение не найдено, создаём новое")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK:
			save_data = json.data
			print("Игра загружена!")
		else:
			print("Ошибка загрузки: ", json.get_error_message())

func unlock_level(level_id: String):
	if level_id not in save_data.unlocked_levels:
		save_data.unlocked_levels.append(level_id)
		save_game()

func is_level_unlocked(level_id: String) -> bool:
	return level_id in save_data.unlocked_levels

func update_level_stars(level_id: String, new_stars: int):
	var current_stars = save_data.level_stars.get(level_id, 0)
	
	if new_stars > current_stars:
		save_data.level_stars[level_id] = new_stars
		
		if new_stars >= 1:
			var next_level = get_next_level(level_id)
			if next_level:
				unlock_level(next_level)
		
		save_game()
		print("Уровень ", level_id, " получил ", new_stars, " звёзд!")

func get_level_stars(level_id: String) -> int:
	return save_data.level_stars.get(level_id, 0)

func get_next_level(level_id: String) -> String:
	match level_id:
		"level_01": return "level_02"
		"level_02": return "level_03"
		_: return ""

func reset_progress():
	save_data = {
		"unlocked_levels": ["level_01"],
		"level_stars": {
			"level_01": 0,
			"level_02": 0,
			"level_03": 0
		}
	}
	save_game()
	print("Прогресс сброшен!")
