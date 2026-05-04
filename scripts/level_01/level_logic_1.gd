extends Node

var is_completed = false
var tutorial_popup = null

@onready var feedback_label = $"../FeedbackLabel"

func _ready():
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
			\n\nЧтобы снова открыть это окно можете воспользоваться клавишей T"
		}
	]
	
	tutorial_popup.setup_tutorial(pages, first_time)
	await tutorial_popup.closed
	
	tutorial_popup.queue_free()
	tutorial_popup = null
	get_tree().paused = false
	
	if not is_completed and not feedback_label.text == "Sort":
		start_game()

func start_game():
	feedback_label.text = "Sort"
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for child in $"../PuzzleContainer".get_children():
		if child.has_method("set_value"):
			child.set_value(rng.randi_range(0, 9))
	
	Notify.info("Расставьте числа в правильном порядке!", 3.0)

func get_objects():
	var result = []
	for child in $"../PuzzleContainer".get_children():
		if child.has_method("get_value"):
			result.append(child)
	return result

func check_answer(is_correct: bool):
	if is_correct:
		feedback_label.text = "Correct!"
		feedback_label.modulate = Color.GREEN
		Notify.success("Правильно! Уровень пройден!", 2.0)
	else:
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
