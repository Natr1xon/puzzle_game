extends Control

signal level_selected(path)
signal back_pressed

@onready var grid = $GridContainer
@onready var back_button = $VBoxContainer/BackButton
@onready var save_reset_button = $VBoxContainer/ResetButton

var unlocked_levels = []
var level_stars = {}

var LevelCardScene = preload("res://scenes/main/level_card.tscn")

var levels = [
	{
		"id": "level_01",
		"title": "Уровень 1. Сортировка",
		"description": "Изучите основы алгоритмов сортировки данных.",
		"path": "res://scenes/levels/level_01.tscn",
		"texture": preload("res://assets/background/bluecity.jpg")
	},
	{
		"id": "level_02",
		"title": "Уровень 2. Графы",
		"description": "Познакомьтесь с основами теории графов.",
		"path": "res://scenes/levels/level_02.tscn",
		"texture": preload("res://assets/background/sunsetcity.png")
	},
	{
		"id": "level_03",
		"title": "Уровень 3. Ханойская башня",
		"description": "Решите классическую математическую головоломку.",
		"path": "res://scenes/levels/level_03.tscn",
		"texture": preload("res://assets/background/nightcity.png")
	}
]

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	_create_levels()

func set_unlocked_levels(levels_list):
	unlocked_levels = levels_list
	update_cards_status()

func set_level_stars(stars_data):
	level_stars = stars_data
	update_cards_status()

func _create_levels():
	for data in levels:
		var card = LevelCardScene.instantiate()
		grid.add_child(card)
		card.setup(data)
		card.play_pressed.connect(_on_level_play)

func update_cards_status():
	for i in range(grid.get_child_count()):
		var card = grid.get_child(i)
		var level_id = extract_level_id_from_card(card)
		var is_unlocked = level_id in unlocked_levels
		var stars = level_stars.get(level_id, 0)
		
		card.set_locked(not is_unlocked)
		card.show_stars(stars)

func extract_level_id_from_card(card) -> String:
	var path = card.level_path
	match path:
		"res://scenes/levels/level_01.tscn": return "level_01"
		"res://scenes/levels/level_02.tscn": return "level_02"
		"res://scenes/levels/level_03.tscn": return "level_03"
	return ""

func _on_level_play(path):
	level_selected.emit(path)

func _on_back_pressed():
	back_pressed.emit()
