extends Control

signal window_closed
signal next_level_requested
signal restart_level_requested
signal menu_requested

@onready var panel = $Panel
@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var info_label = $Panel/VBoxContainer/InfoLabel
@onready var status_label = $Panel/VBoxContainer/StatusLabel
@onready var buttons_container = $Panel/VBoxContainer/ButtonsContainer
@onready var stars_container = $Panel/VBoxContainer/StarsContainer 

var current_level = ""
var next_level_path = ""
var can_advance = false

func _ready():
	hide()
	process_mode = PROCESS_MODE_ALWAYS

func show_summary(level: String, data: Dictionary):
	current_level = level
	next_level_path = data.get("next_level", "")
	
	var earned_stars = calculate_stars_for_level(level, data)
	data["stars"] = earned_stars 
	
	show_stars(earned_stars)
	
	can_advance = earned_stars >= 1
	
	style_buttons(data.get("completed", false) and can_advance)

	match level:
		"sorting":
			show_sorting_summary(data)
		"graph":
			show_graph_summary(data)
		"tower":
			show_tower_summary(data)

	await resize_panel_to_content()
	
	scale = Vector2(0.8, 0.8)
	show()
	
	var final_scale = Vector2(1, 1)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", final_scale, 0.25)
	
	get_tree().paused = true
	
func calculate_stars_for_level(level: String, data: Dictionary) -> int:
	match level:
		"sorting":
			var swap_count = data.get("swap_count", 0)
			var min_swaps = data.get("min_swaps", 0)
			if min_swaps > 0 and swap_count > 0:
				var efficiency = float(min_swaps) / float(swap_count)
				if efficiency >= 0.9: return 3
				if efficiency >= 0.7: return 2
				if efficiency >= 0.5: return 1
			return 0
		
		"graph":
			var total_sum = data.get("total_sum", 0)
			var optimal_sum = data.get("optimal_sum", 0)
			if optimal_sum > 0:
				var diff_percent = float(total_sum - optimal_sum) / float(optimal_sum)
				if diff_percent <= 0.1: return 3
				if diff_percent <= 0.2: return 2
				if diff_percent <= 0.4: return 1
			return 0
		
		"tower":
			var moves = data.get("moves", 0)
			var optimal_moves = data.get("optimal_moves", 31)
			var extra_moves = moves - optimal_moves
			if extra_moves <= 0: return 3
			if extra_moves <= 5: return 2
			if extra_moves <= 10: return 1
			return 0
	
	return 0

func show_stars(count: int):
	if not stars_container:
		return
	
	for child in stars_container.get_children():
		child.queue_free()
	
	for i in range(3):
		var star = Label.new()
		star.text = "⭐" if i < count else "☆"
		star.add_theme_font_size_override("font_size", 32)
		star.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stars_container.add_child(star)

func show_sorting_summary(data: Dictionary):
	title_label.text = "📊 УРОВЕНЬ 1: СОРТИРОВКА"
	
	var attempts = data.get("attempts", 1)
	var swap_count = data.get("swap_count", 0)
	var min_swaps = data.get("min_swaps", 0)
	
	var info_text = ""
	info_text += "📋 Попыток: " + str(attempts) + "\n"
	info_text += "🔄 Перестановок: " + str(swap_count) + "\n"
	
	if min_swaps > 0:
		info_text += "🎯 Минимум: " + str(min_swaps) + "\n"
		
		var efficiency = float(min_swaps) / float(swap_count) * 100
		if swap_count == min_swaps:
			info_text += "⭐ ИДЕАЛЬНО! Оптимальное решение!\n"
		elif efficiency >= 80:
			info_text += "👍 Отличный результат! (" + str(round(efficiency)) + "%)\n"
		elif efficiency >= 60:
			info_text += "📚 Хорошо, но можно лучше (" + str(round(efficiency)) + "%)\n"
		else:
			info_text += "💪 Слишком много перестановок. Попробуйте найти более эффективное решение.\n"
	
	info_label.text = info_text
	
	if not can_advance:
		status_label.text = "❌ УРОВЕНЬ НЕ ПРОЙДЕН!"
		status_label.add_theme_color_override("font_color", Color.RED)
	else:
		status_label.text = "✅ УРОВЕНЬ ПРОЙДЕН!"
		status_label.add_theme_color_override("font_color", Color.GREEN)
		

func show_graph_summary(data: Dictionary):
	title_label.text = "🗺 УРОВЕНЬ 2: ГРАФЫ"
	
	var visited = data.get("visited_nodes", 0)
	var total_visited = data.get("total_visited", 5)
	var total_sum = data.get("total_sum", 0)
	var optimal_sum = data.get("optimal_sum", 0)
	
	var info_text = ""
	info_text += "📍 Посещено узлов: " + str(visited) + " / " + str(total_visited) + "\n"
	info_text += "🔢 Сумма значений: " + str(total_sum) + "\n"
	
	if optimal_sum > 0:
		var diff = total_sum - optimal_sum
		var diff_percent = float(diff) / float(optimal_sum) * 100
		
		info_text += "🎯 Оптимальная сумма: " + str(optimal_sum) + "\n"
		info_text += "📊 Разница: " + str(diff) + " (+" + str(round(diff_percent)) + "%)\n"

		if diff == 0:
			info_text += "⭐ ИДЕАЛЬНО! Вы нашли кратчайший путь!\n"
		elif diff_percent <= 20:
			info_text += "👍 ОТЛИЧНО! Путь близок к оптимальному\n"
		elif diff_percent <= 50:
			info_text += "📚 ХОРОШО, но можно найти путь короче\n"
		else:
			info_text += "💪 Слишком большой перебор. Попробуйте найти более короткий маршрут\n"
	
	info_label.text = info_text
	
	if not can_advance:
		status_label.text = "❌ УРОВЕНЬ НЕ ПРОЙДЕН!"
		status_label.add_theme_color_override("font_color", Color.RED)
	else:
		status_label.text = "✅ УРОВЕНЬ ПРОЙДЕН!"
		status_label.add_theme_color_override("font_color", Color.GREEN)

func show_tower_summary(data: Dictionary):
	title_label.text = "🗼 УРОВЕНЬ 3: ХАНОЙСКАЯ БАШНЯ"
	
	var moves = data.get("moves", 0)
	var optimal_moves = data.get("optimal_moves", 31)
	var time_spent = data.get("time_spent", "0с")
	var extra_moves = moves - optimal_moves

	var info_text = ""
	info_text += "🎮 Сделано ходов: " + str(moves) + "\n"
	info_text += "🏆 Оптимально ходов: " + str(optimal_moves) + "\n"

	if moves <= optimal_moves:
		info_text += "⭐ ИДЕАЛЬНО! Минимальное количество ходов!\n"
	elif extra_moves <= 5:
		info_text += "👍 Отлично! Всего +" + str(extra_moves) + " ход(ов)\n"
	elif extra_moves <= 15:
		info_text += "📚 Хорошо, но можно лучше (+" + str(extra_moves) + ")\n"
	else:
		info_text += "💪 Слишком много лишних ходов (+" + str(extra_moves) + "). Попробуйте найти оптимальную стратегию.\n"

	info_text += "\n⏱ Время: " + time_spent + "\n"
	info_label.text = info_text
	
	if not can_advance:
		status_label.text = "❌ УРОВЕНЬ НЕ ПРОЙДЕН!"
		status_label.add_theme_color_override("font_color", Color.RED)
	else:
		status_label.text = "✅ УРОВЕНЬ ПРОЙДЕН!"
		status_label.add_theme_color_override("font_color", Color.GREEN)

func style_buttons(completed: bool):
	for child in buttons_container.get_children():
		child.queue_free()
	
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.3, 0.4)
	button_style.corner_radius_top_left = 5
	button_style.corner_radius_top_right = 5
	button_style.corner_radius_bottom_left = 5
	button_style.corner_radius_bottom_right = 5
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.3, 0.4, 0.5)
	hover_style.corner_radius_top_left = 5
	hover_style.corner_radius_top_right = 5
	hover_style.corner_radius_bottom_left = 5
	hover_style.corner_radius_bottom_right = 5
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	
	var restart_btn = Button.new()
	restart_btn.text = "Заново"
	restart_btn.custom_minimum_size = Vector2(120, 40)
	restart_btn.add_theme_stylebox_override("normal", button_style)
	restart_btn.add_theme_stylebox_override("hover", hover_style)
	restart_btn.pressed.connect(_on_restart_pressed)
	hbox.add_child(restart_btn)
	
	var menu_btn = Button.new()
	menu_btn.text = "Главное меню"
	menu_btn.custom_minimum_size = Vector2(140, 40)
	menu_btn.add_theme_stylebox_override("normal", button_style.duplicate())
	menu_btn.add_theme_stylebox_override("hover", hover_style.duplicate())
	menu_btn.pressed.connect(_on_menu_pressed)
	hbox.add_child(menu_btn)
	
	if completed and next_level_path != "":
		var next_btn = Button.new()
		next_btn.text = "Следующий уровень →"
		next_btn.custom_minimum_size = Vector2(160, 40)
		next_btn.add_theme_stylebox_override("normal", button_style.duplicate())
		next_btn.add_theme_stylebox_override("hover", hover_style.duplicate())
		next_btn.add_theme_color_override("font_color", Color.YELLOW)
		next_btn.pressed.connect(_on_next_level_pressed)
		hbox.add_child(next_btn)
	elif next_level_path != "":
		var warning_btn = Button.new()
		warning_btn.text = "🔒"
		warning_btn.custom_minimum_size = Vector2(160, 40)
		warning_btn.disabled = true
		warning_btn.add_theme_color_override("font_color", Color.GRAY)
		warning_btn.add_theme_stylebox_override("normal", button_style.duplicate())
		hbox.add_child(warning_btn)
	
	buttons_container.add_child(hbox)

func resize_panel_to_content():
	await get_tree().process_frame
	
	var vbox = $Panel/VBoxContainer
	var content_size = vbox.get_combined_minimum_size()
	
	var padding = 40
	var new_panel_size = content_size + Vector2(padding, padding)
	
	panel.custom_minimum_size = new_panel_size
	panel.size = new_panel_size
	
	var viewport_size = get_viewport().get_visible_rect().size
	panel.position = (viewport_size - new_panel_size) / 2

func _on_restart_pressed():
	get_tree().paused = false
	hide()
	restart_level_requested.emit()
	window_closed.emit()

func _on_menu_pressed():
	get_tree().paused = false
	hide()
	menu_requested.emit()
	window_closed.emit()

func _on_next_level_pressed():
	get_tree().paused = false
	hide()
	next_level_requested.emit()  
	window_closed.emit()

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		_on_restart_pressed()
