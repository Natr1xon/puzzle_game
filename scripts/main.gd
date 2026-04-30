extends Node

@onready var menu = $MainMenu
@onready var level_select = $LevelSelectMenu
@onready var level_container = $LevelContainer
@onready var ui = $UI
@onready var hud = $UI/HUD
@onready var game_menu = $UI/game_menu
@onready var resume_button = $UI/game_menu/Panel/VBoxContainer/ResumeButton


var current_level_path = ""

var coins := 0

func add_coin():
	coins += 1
	hud.update_coins(coins)

func _ready():
	print_tree_pretty()

	menu.show()
	level_select.hide()
	ui.hide()
	
	var shortcut = Shortcut.new()
	
	var events = InputMap.action_get_events("game_menu")
	if events.size() > 0:
		shortcut.events = events
		resume_button.shortcut = shortcut

	menu.start_game.connect(_on_start_game)

	hud.open_menu.connect(_on_open_game_menu)
	game_menu.resume_pressed.connect(_on_resume)
	game_menu.level_select_pressed.connect(_on_level_select_from_game)
	game_menu.main_menu_pressed.connect(_on_main_menu_from_game)

	level_select.level_selected.connect(_on_level_selected)
	level_select.back_pressed.connect(_on_back_from_select)

	print("MAIN ЗАПУЩЕН")

func _on_start_game():
	menu.hide()
	level_select.show()

func _on_level_selected(path):
	level_select.hide()

	load_level(path)

	ui.show()
	hud.show()
	if "level_02" in current_level_path:
		hud.show_sum()
	else:
		hud.hide_sum()

	game_menu.hide()
	get_tree().paused = false

func _on_back_from_select():
	level_select.hide()
	menu.show()
	
func _on_open_game_menu():
	game_menu.show()
	get_tree().paused = true
	
func _on_resume():
	game_menu.hide()
	get_tree().paused = false

func _on_level_select_from_game():
	get_tree().paused = false

	# удалить уровень
	for child in level_container.get_children():
		child.queue_free()
	
	game_menu.hide()
	hud.hide()
	
	level_select.show()
	
func _on_main_menu_from_game():
	get_tree().paused = false

	# удалить уровень
	for child in level_container.get_children():
		child.queue_free()

	game_menu.hide()
	hud.hide()

	menu.show()
	
func update_hud_sum(value: int):
	hud.update_sum(value)

func load_level(path):
	current_level_path = path
	
	coins = 0
	hud.update_coins(coins)

	for child in level_container.get_children():
		child.queue_free()

	var scene = load(path)
	var level = scene.instantiate()
	$LevelContainer.add_child(level)
	
	for coin in get_tree().get_nodes_in_group("coins"):
		if not coin.collected.is_connected(add_coin):
			coin.collected.connect(add_coin)

	var killzone = level.get_node_or_null("KillZone")
	if killzone:
		killzone.player_killed.connect(_on_player_died)

func _on_player_died():
	if current_level_path != "":
		load_level(current_level_path)
