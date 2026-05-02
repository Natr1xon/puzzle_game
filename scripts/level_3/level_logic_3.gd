extends Node2D

var pegs = [[], [], []]
var selected_peg = -1
var player_near_peg = -1

var DiskScene = preload("res://scenes/objects/disk.tscn")

# Для управления сообщениями
var current_message = null
var message_queue = []
var is_showing_message = false

func _ready():
	var pegs_list = $"../Pegs".get_children()
	for i in range(pegs_list.size()):
		pegs_list[i].index = i
		print("Назначен индекс ", i, " для ", pegs_list[i].name)
	
	init_game()
	print_pegs_info()

func on_player_entered_peg_zone(peg_index: int):
	player_near_peg = peg_index
	print("Игрок рядом с колышком ", peg_index)
	show_interaction_hint()

func on_player_exited_peg_zone(peg_index: int):
	if player_near_peg == peg_index:
		player_near_peg = -1
		print("Игрок отошел от колышка ", peg_index)
		hide_interaction_hint()

func show_interaction_hint():
	var hint = get_node_or_null("../UI/Hint")
	if not hint:
		var label = Label.new()
		label.name = "Hint"
		label.text = "Нажмите E чтобы " + ("выбрать диск" if selected_peg == -1 else "положить диск")
		label.position = Vector2(100, 100)
		label.add_theme_color_override("font_color", Color.YELLOW)
		label.add_theme_font_size_override("font_size", 20)
		get_node("..").add_child(label)

func hide_interaction_hint():
	var hint = get_node_or_null("../UI/Hint")
	if hint:
		hint.queue_free()

func interact_with_current_peg():
	if player_near_peg == -1:
		queue_message("Нет колышка рядом!")
		return false
	
	print("Взаимодействие с колышком ", player_near_peg)
	
	if selected_peg == -1:
		if not pegs[player_near_peg].is_empty():
			selected_peg = player_near_peg
			highlight_peg(selected_peg, true)
			print("✅ ВЫБРАН колышек ", selected_peg)
			queue_message("Выбран колышек " + str(selected_peg + 1) + ". Подойдите к другому и нажмите E")
			show_interaction_hint()  # Обновляем подсказку
			return true
		else:
			print("❌ На этом колышке нет дисков!")
			queue_message("На этом колышке нет дисков!")
			return false
	else:
		if selected_peg != player_near_peg:
			move_disk(selected_peg, player_near_peg)
		else:
			print("❌ Нельзя переместить диск на тот же колышек!")
			queue_message("Нельзя переместить диск на тот же колышек!")
		
		highlight_peg(selected_peg, false)
		selected_peg = -1
		show_interaction_hint()  # Обновляем подсказку
		return true

func highlight_peg(peg_index: int, highlight: bool):
	var peg = $"../Pegs".get_child(peg_index)
	var sprite = peg.get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = Color.YELLOW if highlight else Color.WHITE

# Новая система очереди сообщений
func queue_message(text: String):
	message_queue.append(text)
	if not is_showing_message:
		show_next_message()

func show_next_message():
	if message_queue.is_empty():
		is_showing_message = false
		return
	
	is_showing_message = true
	var text = message_queue.pop_front()
	
	# Создаем новое сообщение
	var canvas = CanvasLayer.new()
	canvas.name = "MessageLayer"
	
	var panel = Panel.new()
	panel.size = Vector2(400, 60)
	panel.position = Vector2(get_viewport().size.x / 2 - 200, 50)
	panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	
	var label = Label.new()
	label.text = text
	label.size = Vector2(380, 50)
	label.position = Vector2(10, 5)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 18)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	panel.add_child(label)
	canvas.add_child(panel)
	add_child(canvas)
	
	# Анимация появления
	panel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.2)
	
	# Ждем 2 секунды
	await get_tree().create_timer(2.0).timeout
	
	# Анимация исчезновения
	tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), 0.2)
	await tween.finished
	
	canvas.queue_free()
	
	# Показываем следующее сообщение
	await get_tree().create_timer(0.1).timeout
	show_next_message()

func init_game():
	for child in $"../Disks".get_children():
		child.queue_free()
	
	pegs = [[], [], []]
	
	for i in range(5, 0, -1):
		var disk = create_disk(i)
		$"../Disks".add_child(disk)
		pegs[0].append(disk)
	
	update_view()
	print("Игра инициализирована: 5 дисков на колышке 0")

func move_disk(from_peg, to_peg):
	print("🔄 Попытка переместить диск с ", from_peg, " на ", to_peg)
	
	if pegs[from_peg].is_empty():
		print("❌ Нет дисков для перемещения!")
		return
	
	var disk = pegs[from_peg].back()
	print("Диск размером ", disk.disk_size)
	
	if not pegs[to_peg].is_empty():
		var top_disk = pegs[to_peg].back()
		if disk.disk_size > top_disk.disk_size:
			print("❌ Нельзя положить большой диск на маленький!")
			queue_message("Нельзя положить большой диск на маленький!")
			return
	
	pegs[from_peg].pop_back()
	pegs[to_peg].append(disk)
	update_view()
	
	print("✅ Диск перемещен!")
	queue_message("Диск перемещен на колышек " + str(to_peg + 1))
	
	if pegs[2].size() == 5 or pegs[1].size() == 5:
		print("🏆 ПОБЕДА! 🏆")
		queue_message("ПОБЕДА! 🎉")

func print_pegs_info():
	print("=== Текущее состояние ===")
	for i in range(3):
		var sizes = []
		for disk in pegs[i]:
			sizes.append(str(disk.disk_size))
		print("Колышек ", i, ": ", sizes)

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
			var y = -25 - i * 25
			var width = disk.disk_size * 20
			var x = center_x - width / 2
			disk.position = Vector2(x, y)
			disk.visible = true
