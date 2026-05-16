extends Control

signal play_pressed(level_path)

@onready var title_label = $Panel/VBoxContainer/Title
@onready var desc_label = $Panel/VBoxContainer/Description
@onready var image = $Panel/VBoxContainer/TextureRect
@onready var play_button = $Panel/VBoxContainer/Button
@onready var stars_container = $Panel/VBoxContainer/StarsContainer
@onready var star1 = $Panel/VBoxContainer/StarsContainer/Star1
@onready var star2 = $Panel/VBoxContainer/StarsContainer/Star2
@onready var star3 = $Panel/VBoxContainer/StarsContainer/Star3

var level_path = ""
var level_id = ""

func _ready():
	play_button.pressed.connect(_on_play)

func setup(data):
	title_label.text = data.title
	desc_label.text = data.description
	image.texture = data.texture
	level_path = data.path
	level_id = data.id

func set_locked(locked: bool):
	play_button.disabled = locked
	if locked:
		play_button.text = "🔒 ЗАБЛОКИРОВАН"
	else:
		play_button.text = "▶ ИГРАТЬ"

func show_stars(count: int):
	star1.text = "⭐" if count > 0 else "☆"
	star2.text = "⭐" if count > 1 else "☆"
	star3.text = "⭐" if count > 2 else "☆"

func _on_play():
	print("Кнопка нажата! play_button.disabled = ", play_button.disabled)
	if not play_button.disabled:
		play_pressed.emit(level_path)
	else:
		print("Кнопка заблокирована!")
