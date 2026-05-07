extends Node

var selected_object = null

func try_swap(a, b) -> bool:
	if can_swap(a, b):
		var tween = a.create_tween()
		tween.set_parallel(true)
		tween.tween_property(a, "global_position", b.global_position, 0.2)
		tween.tween_property(b, "global_position", a.global_position, 0.2)
		
		var level_logic = get_level_logic()
		if level_logic and level_logic.has_method("increment_swap"):
			level_logic.increment_swap()

		await tween.finished
		print("swap complete")
		return true
	
	return false

func can_swap(a, b) -> bool:
	if not a.has_method("get_value") or not b.has_method("get_value"):
		return false

	var distance = a.global_position.distance_to(b.global_position)
	if distance > 30:
		Notify.warn("Слишком далеко! Выберите ближе", 1.5)
		return false
	
	return true

func handle_interact(obj):
	if not is_instance_valid(obj):
		return

	if not obj.has_method("get_value"):
		return

	if selected_object == null:
		obj.highlight(true) 
		selected_object = obj
		print("Выбран:", obj.name)
		return

	if selected_object == obj:
		obj.highlight(false)  
		selected_object = null
		print("Отмена выбора")
		Notify.info("Выбор отменен", 1.0)
		return

	print("Свап между:", selected_object.name, obj.name)

	if await try_swap(selected_object, obj):
		print("Свап успешен")
		selected_object.highlight(false)  
	else:
		print("Свап невозможен")
		selected_object.highlight(false) 

	selected_object = null

func get_level_logic():
	var level_logics = get_tree().get_nodes_in_group("level_logic")
	if level_logics.size() > 0:
		return level_logics[0]

	var parent = get_parent()
	while parent:
		if parent.has_method("increment_swap") or parent.has_method("check_win"):
			return parent
		parent = parent.get_parent()
	
	return null
