extends Control

signal open_menu

@onready var menu_button = $MenuButton
@onready var coin_label = $CoinScoreLabel
@onready var sum_label = $SumGraphs

func _ready():
	sum_label.hide()
	
	var shortcut = Shortcut.new()
	
	var events = InputMap.action_get_events("game_menu")
	if events.size() > 0:
		shortcut.events = events
		menu_button.shortcut = shortcut
	
	menu_button.pressed.connect(_on_menu_pressed)

func _on_menu_pressed():
	open_menu.emit()

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
	
