extends Node

var selected_object = null

func try_swap(a, b) -> bool:
	if can_swap(a, b):
		var temp = a.global_position
		a.global_position = b.global_position
		b.global_position = temp
		print("swap")
		return true
	else:
		print("can't swap")
		return false

func can_swap(a, b) -> bool:
	if not a.has_method("get_value") or not b.has_method("get_value"):
		return false
	
	var distance = a.global_position.distance_to(b.global_position)
	
	if distance > 25:
		print("Слишком далеко")
		return false
	
	return true
	
func handle_interact(obj):
	if not is_instance_valid(obj):
		print("Объект невалиден")
		return

	if not obj.has_method("get_value"):
		print("Не puzzle object")
		return

	# первый выбор
	if selected_object == null:
		selected_object = obj
		print("Первый объект выбран:", obj.name)
		return

	# клик по тому же объекту
	if selected_object == obj:
		print("Тот же объект — отмена выбора")
		selected_object = null
		return

	print("Пытаемся свапнуть:", selected_object.name, obj.name)

	if try_swap(selected_object, obj):
		print("Свап успешен")
	else:
		print("Свап запрещён")

	selected_object = null
