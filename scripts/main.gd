extends Node

@onready var menu = $MainMenu
@onready var level_select = $LevelSelectMenu
@onready var level_container = $LevelContainer

func _ready():
	menu.show()
	level_select.hide()

	menu.start_game.connect(_on_start_game)

	level_select.level_selected.connect(_on_level_selected)
	level_select.back_pressed.connect(_on_back_from_select)

	print("MAIN ЗАПУЩЕН")

func _on_start_game():
	menu.hide()
	level_select.show()

func _on_level_selected(path):
	level_select.hide()
	load_level(path)

func _on_back_from_select():
	level_select.hide()
	menu.show()

func load_level(path):
	# удалить старый уровень
	for child in level_container.get_children():
		child.queue_free()

	var scene = load(path)
	if scene == null:
		print("❌ Не удалось загрузить:", path)
		return

	var level = scene.instantiate()
	level_container.add_child(level)

	print("✅ Уровень загружен:", path)
