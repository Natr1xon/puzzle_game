extends Node

@onready var menu = $MainMenu
@onready var level_select = $LevelSelectMenu
@onready var level_container = $LevelContainer
@onready var ui = $UI
@onready var hud = $UI/HUD
@onready var tutorial = $UI/HUD/TutorialButton
@onready var game_menu = $UI/game_menu
@onready var resume_button = $UI/game_menu/Panel/VBoxContainer/ResumeButton

var current_level_path = ""
var current_level_instance = null

func _ready():
	menu.show()
	level_select.hide()
	ui.hide()
	
	var shortcut = Shortcut.new()
	var menu_events = InputMap.action_get_events("open_game_menu")
	if menu_events.size() > 0:
		shortcut.events = menu_events
		resume_button.shortcut = shortcut
	
	menu.start_game.connect(_on_start_game)

	hud.open_menu.connect(_on_open_game_menu)
	hud.open_tutorial.connect(_on_open_tutorial)  
	
	game_menu.resume_pressed.connect(_on_resume)
	game_menu.restart_pressed.connect(_on_restart_level)
	game_menu.level_select_pressed.connect(_on_level_select_from_game)
	game_menu.main_menu_pressed.connect(_on_main_menu_from_game)

	level_select.level_selected.connect(_on_level_selected)
	level_select.back_pressed.connect(_on_back_from_select)

	print("MAIN ЗАПУЩЕН")

	update_level_select()

func _on_start_game():
	menu.hide()
	level_select.show()

func _on_level_selected(path):
	var level_id = extract_level_id(path)
	if not SaveSystem.is_level_unlocked(level_id):
		Notify.warn("Этот уровень ещё не открыт!", 2.0)
		return
	
	level_select.hide()
	load_level(path)
	ui.show()
	hud.show()

	game_menu.hide()
	get_tree().paused = false

func extract_level_id(path: String) -> String:
	match path:
		"res://scenes/levels/level_01.tscn": return "level_01"
		"res://scenes/levels/level_02.tscn": return "level_02"
		"res://scenes/levels/level_03.tscn": return "level_03"
	return ""

func _on_back_from_select():
	level_select.hide()
	menu.show()
	
func _on_open_game_menu():
	game_menu.show()
	get_tree().paused = true 

func _on_open_tutorial():
	var current_level_logic = get_current_level_logic()
	if current_level_logic and current_level_logic.has_method("show_tutorial_again"):
		current_level_logic.show_tutorial_again()
	else:
		print("Туториал не доступен для текущего уровня")

func get_current_level_logic():
	for child in level_container.get_children():
		var level_logic = child.find_child("LevelLogic", true, false)
		if level_logic and level_logic.has_method("show_tutorial_again"):
			return level_logic
	return null

func _on_resume():
	game_menu.hide()
	get_tree().paused = false

func _on_level_select_from_game():
	get_tree().paused = false

	for child in level_container.get_children():
		child.queue_free()
	
	Notify.clear_now()
	
	game_menu.hide()
	hud.hide()
	level_select.show()
	
	update_level_select()
	
func _on_main_menu_from_game():
	get_tree().paused = false

	for child in level_container.get_children():
		child.queue_free()
	
	Notify.clear_now()

	game_menu.hide()
	hud.hide()
	menu.show()

	update_level_select()

func _on_restart_level():
	game_menu.hide()
	
	if current_level_path != "":
		load_level(current_level_path)
	
func update_hud_info(string: String):
	hud.update_info(string)

func load_level(path):
	current_level_path = path

	for child in level_container.get_children():
		child.queue_free()

	var scene = load(path)
	current_level_instance = scene.instantiate()
	$LevelContainer.add_child(current_level_instance)

	var player = current_level_instance.find_child("Player", true, false)
	if player:
		player.add_to_group("player")
		
	var killzone = current_level_instance.get_node_or_null("KillZone")
	if killzone:
		killzone.player_killed.connect(_on_player_died)

func _on_player_died():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("respawn"):
		player.respawn()
	else:
		if current_level_path != "":
			load_level(current_level_path)

func close_completion_window():
	var completion_window = get_node_or_null("CompletionWindow")
	if completion_window:
		completion_window.queue_free()

func update_level_select():
	level_select.set_unlocked_levels(SaveSystem.save_data.unlocked_levels)
	level_select.set_level_stars(SaveSystem.save_data.level_stars) 

func show_completion_window(level_type: String, data: Dictionary):
	var completion_window = get_node_or_null("UI/CompletionWindow")
	
	if completion_window:
		completion_window.show()
		if not completion_window.restart_level_requested.is_connected(_on_completion_restart):
			completion_window.restart_level_requested.connect(_on_completion_restart)
		if not completion_window.menu_requested.is_connected(_on_completion_menu):
			completion_window.menu_requested.connect(_on_completion_menu)
		if not completion_window.next_level_requested.is_connected(_on_completion_next_level):
			completion_window.next_level_requested.connect(_on_completion_next_level)

		completion_window.show_summary(level_type, data)
	
	var level_id = extract_level_id(current_level_path)
	var earned_stars = data.get("stars", 0)
	
	SaveSystem.update_level_stars(level_id, earned_stars) 
	update_level_select()

func _on_completion_restart():
	print("Рестарт уровня из окна итогов")
	get_tree().paused = false
	_on_restart_level()
	close_completion_window()

func _on_completion_menu():
	print("Выход в меню из окна итогов")
	get_tree().paused = false
	_on_main_menu_from_game()
	close_completion_window()

func _on_completion_next_level():
	print("Следующий уровень из окна итогов")
	get_tree().paused = false
	
	var next_path = ""
	
	if "level_01" in current_level_path:
		next_path = "res://scenes/levels/level_02.tscn"
	elif "level_02" in current_level_path:
		next_path = "res://scenes/levels/level_03.tscn"
	else:
		_on_main_menu_from_game()
		close_completion_window()
		return
	
	if next_path != "" and ResourceLoader.exists(next_path):
		load_level(next_path)
	else:
		_on_main_menu_from_game()
	
	close_completion_window()
