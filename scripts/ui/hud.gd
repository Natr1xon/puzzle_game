extends Control

signal open_menu
signal open_tutorial 

@onready var menu_button = $MenuButton
@onready var tutorial_button = $TutorialButton  
@onready var info_label = $InfoLabel

func _ready():
	var shortcut = Shortcut.new()
	var menu_events = InputMap.action_get_events("open_game_menu")
	if menu_events.size() > 0:
		shortcut.events = menu_events
		menu_button.shortcut = shortcut
	
	shortcut = Shortcut.new()
	var tutorial_events = InputMap.action_get_events("open_tutorial")
	if tutorial_events.size() > 0:
		shortcut.events = tutorial_events
		tutorial_button.shortcut = shortcut
	
	menu_button.pressed.connect(_on_menu_pressed)
	tutorial_button.pressed.connect(_on_tutorial_pressed)

func _on_menu_pressed():
	open_menu.emit()

func _on_tutorial_pressed():
	open_tutorial.emit()

func update_info(string: String):
	info_label.text = string

func reset_info():
	update_info(' ')
