extends Control

signal level_selected(path)
signal back_pressed

@onready var grid = $GridContainer
@onready var back_button = $VBoxContainer/BackButton

var LevelCardScene = preload("res://scenes/main/level_card.tscn")

var levels = [
	{
		"title": "Уровень 1. Сортировка",
		"description": "Обучающий уровень по изучении простейших сортировок",
		"path": "res://scenes/levels/level_01.tscn",
		"texture": preload("res://assets/background/bluecity.jpg")
	},
	{
		"title": "Уровень 2. Графы",
		"description": "Обучающий уровень по поиску кратчайшего пути в графе",
		"path": "res://scenes/levels/level_02.tscn",
		"texture": preload("res://assets/background/sunsetcity.png")
	},
	{
		"title": "Уровень 3. Ханойская башня",
		"description": "Обучающий уровень про популярную головоломку",
		"path": "res://scenes/levels/level_03.tscn",
		"texture": preload("res://assets/background/nightcity.png")
	}
]

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	_create_levels()
	print(grid.get_child_count())

func _create_levels():
	for data in levels:
		var card = LevelCardScene.instantiate()
		grid.add_child(card)

		card.setup(data)
		card.play_pressed.connect(_on_level_play)

func _on_level_play(path):
	level_selected.emit(path)

func _on_back_pressed():
	back_pressed.emit()
