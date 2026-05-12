extends Node2D

var pegs = [[], [], []]
var selected_peg = -1
var current_near_peg = -1
var tutorial_popup = null
var moves_count = 0  
var start_time = 0   
var is_completed = false  

var DiskScene = preload("res://scenes/objects/disk.tscn")
var input_handler = null
@onready var main = get_tree().root.get_node("Main")

func _ready():
	add_to_group("level_logic")
	await get_tree().process_frame
	main.update_hud_info("Ходов сделано: " + str(moves_count))
	show_tutorial()

func show_tutorial():
	show_tutorial_again(true)

func show_tutorial_again(first_time = false):
	if tutorial_popup:
		return
	
	get_tree().paused = true
	
	tutorial_popup = CanvasLayer.new()
	tutorial_popup.set_script(preload("res://scripts/ui/tutorial_popup.gd"))
	add_child(tutorial_popup)
	
	var pages = [
		{
			"title": "🗼 ТЕОРИЯ: ХАНОЙСКАЯ БАШНЯ",
			"text": "Ханойская башня — классическая математическая головоломка, предложенная французским математиком Эдуаром Люка в XIX веке.
			\nЗадача состоит из трёх стержней и набора дисков разного размера.
			\nНеобходимо перенести всю башню с одного стержня на другой."
		},
		{
			"title": "🧠 АЛГОРИТМИЧЕСКИЙ ПРИНЦИП",
			"text": "Ханойская башня используется для изучения:
			\n• рекурсии
			\n• алгоритмов
			\n• оптимизации действий
			\n• математической логики
			\nДля решения задачи применяется рекурсивный подход — разбиение большой задачи на последовательность более простых."
		},
		{
			"title": "📏 ПРАВИЛА ГОЛОВОЛОМКИ",
			"text": "• За один ход разрешено перемещать только один диск
			\n• Больший диск нельзя размещать поверх меньшего
			\n• Диски можно переносить между любыми стержнями
			\n• Минимальное количество ходов для 5 дисков — 31"
		},
		{
			"title": "🎮 КАК ИГРАТЬ?",
			"text": "1. Подойдите к стержню и нажмите E, чтобы выбрать верхний диск
			\n2. Подойдите к другому стержню и нажмите E для перемещения
			\n3. Соберите все диски на правом стержне"
		},
		{
			"title": "💡 СТРАТЕГИЯ РЕШЕНИЯ",
			"text": "Средний стержень используется как вспомогательный.
			\nДля эффективного решения важно перемещать меньшие диски, освобождая путь для больших.
			\n🎯 Попробуйте найти оптимальный алгоритм!
			\n\nНажмите T, чтобы снова открыть справку."
		}
	]
	
	tutorial_popup.setup_tutorial(pages, first_time)
	await tutorial_popup.closed
	
	tutorial_popup.queue_free()
	tutorial_popup = null
	get_tree().paused = false

	if pegs[0].is_empty() and pegs[1].is_empty() and pegs[2].is_empty():
		start_game()

func start_game():
	moves_count = 0 
	start_time = Time.get_ticks_msec() 

	input_handler = get_node_or_null("../InputHandler")
	if not input_handler:
		input_handler = get_tree().get_first_node_in_group("input_handler")
		if not input_handler:
			print("ОШИБКА: InputHandler не найден!")
			return
	
	var pegs_list = $"../Pegs".get_children()
	for i in range(pegs_list.size()):
		pegs_list[i].index = i
	
	init_game()
	
	Notify.info("Переместите все диски на правый стержень!", 3.0)

func on_player_entered_peg_zone(peg_index: int):
	print(peg_index)
	current_near_peg = peg_index

func on_player_exited_peg_zone(peg_index: int):
	if current_near_peg == peg_index:
		current_near_peg = -1

func interact_with_current_peg():
	if current_near_peg == -1:
		Notify.warn("Подойдите к колышку!")
		return false

	if input_handler and input_handler.has_method("handle_peg_clicked"):
		input_handler.handle_peg_clicked(current_near_peg)
		return true
	else:
		print("ОШИБКА: input_handler не готов!")
		return false

func highlight_peg(peg_index: int, highlight: bool):
	var peg = $"../Pegs".get_child(peg_index)
	var sprite = peg.get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = Color.RED if highlight else Color.WHITE

func init_game():
	for child in $"../Disks".get_children():
		child.queue_free()
	
	pegs = [[], [], []]
	
	for i in range(5, 0, -1):
		var disk = create_disk(i)
		$"../Disks".add_child(disk)
		pegs[0].append(disk)
	
	update_view()

func create_disk(size):
	var disk = DiskScene.instantiate()
	disk.setup(size)
	return disk

func update_view():
	for peg_index in range(3):
		var peg = $"../Pegs".get_child(peg_index)
		
		for i in range(pegs[peg_index].size()):
			var disk = pegs[peg_index][i]
			if not is_instance_valid(disk):
				continue
			
			var center_x = peg.global_position.x
			var y = -25 - i * (disk.size.y + 2)
			var x = center_x - disk.size.x / 2
			
			disk.position = Vector2(x, y)

func increment_moves():
	moves_count += 1
	main.update_hud_info("Ходов сделано: " + str(moves_count))
	check_win()

func check_win():
	if not is_completed and pegs[2].size() == 5:
		is_completed = true
		show_completion_window()

func show_completion_window():
	if main and main.has_method("show_completion_window"):
		var time_spent = (Time.get_ticks_msec() - start_time) / 1000.0
		var minutes = floor(time_spent / 60)
		var seconds = int(time_spent) % 60 
		var time_string = str(minutes) + "м " + str(seconds) + "с"
		
		main.show_completion_window("tower", {
			"moves": moves_count,
			"optimal_moves": 31,  
			"time_spent": time_string,
			"completed": true,
			"next_level": "" 
		})
