extends Node

func _ready():
	load_level("res://scenes/levels/level_01.tscn")
	print("MAIN ЗАПУЩЕН")

func load_level(path):
	var scene = load(path)
	
	if scene == null:
		print("❌ Не удалось загрузить сцену:", path)
		return
		
	var level = load(path).instantiate()
	$LevelContainer.add_child(level)
	
	print("✅ Уровень загружен")
