extends Node2D

var pegs = [[], [], []]
var current_near_peg: int = -1
var tutorial_popup: CanvasLayer = null
var moves_count: int = 0
var start_time: int = 0
var is_completed: bool = false

var DiskScene = preload("res://scenes/objects/disk.tscn")
@onready var input_handler = get_node("../InputHandler")
@onready var main = get_tree().root.get_node("Main")

func _ready():
	add_to_group("level_logic")
	await get_tree().process_frame
	main.update_hud_info("❗Ходов сделано: " + str(moves_count))
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
	is_completed = false
	
	var pegs_list = $"../PegContainer".get_children()
	for i in range(pegs_list.size()):
		pegs_list[i].index = i
	
	init_game()
	
	Notify.info("Переместите все диски \n на правый стержень!", 3.0)

func on_player_entered_peg_zone(peg_index: int):
	print(peg_index)
	current_near_peg = peg_index

func on_player_exited_peg_zone(peg_index: int):
	if current_near_peg == peg_index:
		current_near_peg = -1

func interact_with_current_peg() -> bool:
	if current_near_peg == -1:
		Notify.warn("Подойдите к колышку!")
		return false

	if input_handler:
		input_handler.handle_peg_clicked(current_near_peg)
		return true

	return false

func highlight_peg(peg_index: int, highlight: bool):
	var peg = $"../PegContainer".get_child(peg_index)
	var sprite = peg.get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = Color.RED if highlight else Color.WHITE

func can_move_disk(from_peg: int, to_peg: int) -> bool:
	if from_peg < 0 or from_peg >= pegs.size():
		return false
	if to_peg < 0 or to_peg >= pegs.size():
		return false
	if pegs[from_peg].is_empty():
		return false
	if pegs[to_peg].is_empty():
		return true

	return pegs[from_peg].back().disk_size < pegs[to_peg].back().disk_size

func move_disk(from_peg: int, to_peg: int) -> bool:
	if not can_move_disk(from_peg, to_peg):
		Notify.error("Нельзя положить большой диск \n на маленький!")
		return false

	var disk = pegs[from_peg].back()
	var end_peg: Node2D = $"../PegContainer".get_child(to_peg)
	var target_position := Vector2(
		end_peg.global_position.x - disk.size.x / 2.0,
		-25 - pegs[to_peg].size() * (disk.size.y + 2)
	)
	var lift_position := Vector2(disk.position.x, disk.position.y - 50)

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(disk, "position", lift_position, 0.25)
	await tween.finished

	pegs[from_peg].pop_back()
	pegs[to_peg].append(disk)
	increment_moves()

	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(disk, "position:x", target_position.x, 0.35)
	await tween.finished

	tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(disk, "position", target_position, 0.25)
	await tween.finished

	update_view()
	return true

func init_game():
	for child in $"../DiskContainer".get_children():
		child.queue_free()
	
	pegs = [[], [], []]
	
	for i in range(5, 0, -1):
		var disk = create_disk(i)
		$"../DiskContainer".add_child(disk)
		pegs[0].append(disk)
	
	update_view()

func create_disk(size):
	var disk = DiskScene.instantiate()
	disk.setup(size)
	return disk

func update_view():
	for peg_index in range(3):
		var peg = $"../PegContainer".get_child(peg_index)
		
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
	main.update_hud_info("❗Ходов сделано: " + str(moves_count))
	check_win()

func check_win():
	if not is_completed and pegs[2].size() == 5:
		is_completed = true
		await get_tree().create_timer(1.0).timeout
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
