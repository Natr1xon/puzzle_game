extends Control

signal start_game

func _ready():
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	print("▶ Игра начинается")
	emit_signal("start_game")

func _on_exit_pressed():
	get_tree().quit()
