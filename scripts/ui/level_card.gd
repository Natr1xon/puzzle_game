extends Control

signal play_pressed(level_path)

@onready var title_label = $Panel/VBoxContainer/Title
@onready var desc_label = $Panel/VBoxContainer/Description
@onready var image = $Panel/VBoxContainer/TextureRect
@onready var play_button = $Panel/VBoxContainer/Button

var level_path = ""

func _ready():
	play_button.pressed.connect(_on_play)

func setup(data):
	title_label.text = data.title
	desc_label.text = data.description
	image.texture = data.texture
	level_path = data.path

func _on_play():
	play_pressed.emit(level_path)
