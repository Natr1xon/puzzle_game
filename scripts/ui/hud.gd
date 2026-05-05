extends Control

signal open_menu
signal open_tutorial 

@onready var menu_button = $MenuButton
@onready var tutorial_button = $TutorialButton  
@onready var coin_label = $CoinScoreLabel
@onready var sum_label = $SumGraphs

func _ready():
	sum_label.hide()

	var shortcut = Shortcut.new()
	var menu_events = InputMap.action_get_events("open_game_menu")
	if menu_events.size() > 0:
		print("Щёлк")
		shortcut.events = menu_events
		menu_button.shortcut = shortcut
	
	shortcut = Shortcut.new()
	var tutorial_events = InputMap.action_get_events("open_tutorial")
	if tutorial_events.size() > 0:
		print("Щёлк")
		shortcut.events = tutorial_events
		tutorial_button.shortcut = shortcut
	
	menu_button.pressed.connect(_on_menu_pressed)
	tutorial_button.pressed.connect(_on_tutorial_pressed)


func _on_menu_pressed():
	open_menu.emit()

func _on_tutorial_pressed():
	open_tutorial.emit()

func update_coins(value: int):
	coin_label.text = "Coins: " + str(value)
	
func update_sum(value: int):
	sum_label.text = "Sum graph nodes: " + str(value)
	
func reset_coins():
	update_coins(0)

func reset_sum():
	update_sum(0)
	
func show_sum():
	sum_label.show()
	
func hide_sum():
	sum_label.hide()
