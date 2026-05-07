extends Node

var is_completed = false
var tutorial_popup = null
var attempts = 0
var swap_count = 0
var start_time = 0 

@onready var feedback_label = $"../FeedbackLabel"

func _ready():
	add_to_group("level_logic")
	await get_tree().process_frame
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
			"title": "📚 ЧТО ТАКОЕ СОРТИРОВКА?",
			"text": "Сортировка - это расположение элементов в правильном порядке.
			\n\nЗдесь вам нужно расставить числа от меньшего к большему
			\nслева направо.
			\n\nПример: 1, 2, 3, 4, 5, 6, 7, 8, 9"
		},
		{
			"title": "🎮 КАК ИГРАТЬ?",
			"text": "1. Подойдите к коробу, на котором написано число
			\n2. Нажмите клавишу E, чтобы выбрать его
			\n   (объект подсветится желтым)
			\n3. Подойдите к другому коробу и нажмите E
			\n   (они поменяются местами)
			\n4. Повторяйте, пока числа не будут в правильном порядке"
		},
		{
			"title": "✅ ЗАВЕРШЕНИЕ УРОВНЯ",
			"text": "Когда вы расставите все числа по порядку:
				\n\n1. Подойдите к кнопке \"ПРОВЕРИТЬ\"
				\n2. Нажмите E для проверки
				\n3. Если всё правильно - уровень пройден!
				\n\n🎯 Удачи!
			\nЧтобы снова открыть это окно можете воспользоваться клавишей T"
		}
	]
	
	tutorial_popup.setup_tutorial(pages, first_time)
	await tutorial_popup.closed
	
	tutorial_popup.queue_free()
	tutorial_popup = null
	get_tree().paused = false
	
	if not is_completed:
		start_game()

func start_game():
	swap_count = 0
	start_time = Time.get_ticks_msec()
	feedback_label.text = "Sort"

	Notify.info("Расставьте числа в правильном порядке!", 3.0)

func get_objects():
	var result = []
	for child in $"../PuzzleContainer".get_children():
		if child.has_method("get_value"):
			result.append(child)
	return result

func increment_swap():
	swap_count += 1
	print("Перестановок сделано: ", swap_count)

func check_answer(is_correct: bool):
	if is_correct:
		feedback_label.text = "Correct!"
		feedback_label.modulate = Color.GREEN
	else:
		attempts += 1
		feedback_label.text = "Incorrect!"
		feedback_label.modulate = Color.RED
		Notify.error("Неправильный порядок! Попробуйте еще раз", 2.0)

	await get_tree().create_timer(2.0).timeout

	if not is_completed:
		Notify.info("Сортируй по возрастанию", 5.0)

func check_win():
	if is_completed:
		return 

	var objects = get_objects()
	var sorted = objects.duplicate()

	sorted.sort_custom(func(a, b):
		return a.global_position.x < b.global_position.x
	)

	for i in range(sorted.size() - 1):
		if sorted[i].get_value() > sorted[i + 1].get_value():
			check_answer(false)
			return

	is_completed = true
	check_answer(true)

	show_completion_window()

func show_completion_window():
	var main = get_node("/root/Main")
	if main and main.has_method("show_completion_window"):
		var time_spent = (Time.get_ticks_msec() - start_time) / 1000.0
		var minutes = floor(time_spent / 60)
		var seconds = int(time_spent) % 60 
		var time_string = str(minutes) + "м " + str(seconds) + "с"
		
		main.show_completion_window("sorting", {
			"attempts": attempts,
			"swap_count": swap_count,
			"min_swaps": calculate_min_swaps(),
			"time_spent": time_string,
			"completed": true,
			"next_level": "res://scenes/levels/level_02.tscn"
		})


func calculate_min_swaps() -> int:
	var objects = get_objects()
	if objects.is_empty():
		return 0
	
	var values = []
	for obj in objects:
		values.append(obj.get_value())

	var sorted_values = values.duplicate()
	var swaps = 0
	
	for i in range(sorted_values.size()):
		for j in range(0, sorted_values.size() - i - 1):
			if sorted_values[j] > sorted_values[j + 1]:
				var temp = sorted_values[j]
				sorted_values[j] = sorted_values[j + 1]
				sorted_values[j + 1] = temp
				swaps += 1
	
	return swaps
