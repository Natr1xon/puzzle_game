extends Node

var is_completed = false


@onready var feedback_label = $"../FeedbackLabel"

func _ready():
	feedback_label.text = "Sort"
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for child in $"../PuzzleContainer".get_children():
		if child.has_method("set_value"):
			child.set_value(rng.randi_range(0, 9))

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
	else:
		feedback_label.text = "Incorrect!"
		feedback_label.modulate = Color.RED

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
