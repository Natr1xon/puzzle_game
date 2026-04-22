extends Control

signal open_menu

@onready var menu_button = $MenuButton
@onready var coin_label = $CoinScoreLabel

func _ready():
	menu_button.pressed.connect(_on_menu_pressed)

func _on_menu_pressed():
	open_menu.emit()

func update_coins(value: int):
	coin_label.text = "Coins: " + str(value)

func reset_coins():
	update_coins(0)
