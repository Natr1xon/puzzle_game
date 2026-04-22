extends Control

signal resume_pressed
signal level_select_pressed
signal main_menu_pressed

@onready var resume_btn = $Panel/VBoxContainer/ResumeButton
@onready var level_btn = $Panel/VBoxContainer/LevelSelectButton
@onready var menu_btn = $Panel/VBoxContainer/MainMenuButton

func _ready():
	resume_btn.pressed.connect(func(): resume_pressed.emit())
	level_btn.pressed.connect(func(): level_select_pressed.emit())
	menu_btn.pressed.connect(func(): main_menu_pressed.emit())

func _on_button_pressed():
	level_select_pressed.emit()
