extends Node

var is_completed = false

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for child in $"../PuzzleContainer".get_children():
		if child.has_method("set_value"):
			child.set_value(rng.randi_range(0, 9))

func _on_button_pressed():
	check_win()

func get_objects():
	var result = []
	
	for child in $"../PuzzleContainer".get_children():
		if child.has_method("get_value"):
			result.append(child)
	
	return result

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
			print("❌ НЕПРАВИЛЬНО")
			return false

	is_completed = true
	print("✅ ПОБЕДА 🎉")
	return true
