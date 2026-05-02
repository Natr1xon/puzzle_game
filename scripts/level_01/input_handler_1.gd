extends Node

var selected_object = null

func try_swap(a, b) -> bool:
	if can_swap(a, b):
		var tween = a.create_tween()
		tween.set_parallel(true)
		tween.tween_property(a, "global_position", b.global_position, 0.2)
		tween.tween_property(b, "global_position", a.global_position, 0.2)

		await tween.finished
		print("swap complete")
		return true
	
	return false

func can_swap(a, b) -> bool:
	if not a.has_method("get_value") or not b.has_method("get_value"):
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
		Notify.info("Выбран объект: " + str(obj.get_value()), 1.0)
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
