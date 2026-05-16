extends CanvasLayer

var pages = []
var current_page = 0
var background = null
var panel = null
var is_first_time = true 

signal closed

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	layer = 200
	hide()

func setup_tutorial(tutorial_pages: Array, first_time: bool = true):
	pages = tutorial_pages
	current_page = 0
	is_first_time = first_time
	show_page()

func _input(event):
	if visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("open_tutorial")):
		close()
		get_viewport().set_input_as_handled()

func show_page():
	if background:
		background.queue_free()
	if panel:
		panel.queue_free()
	
	background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.85)
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	add_child(background)

	panel = Panel.new()
	panel.size = Vector2(600, 500)
	var viewport_size = get_viewport().get_visible_rect().size
	panel.position = Vector2(viewport_size.x / 2 - 300, viewport_size.y / 2 - 250)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color("33334df2")
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	panel.add_theme_stylebox_override("panel", style)

	# Заголовок
	var title = Label.new()
	title.text = pages[current_page]["title"]
	title.position = Vector2(50, 30)
	title.size = Vector2(500, 40)
	title.add_theme_color_override("font_color", Color.YELLOW)
	title.add_theme_font_size_override("font_size", 24)
	panel.add_child(title)

	# Текст
	var text = RichTextLabel.new()
	text.text = pages[current_page]["text"]
	text.position = Vector2(50, 80)
	text.size = Vector2(500, 340) 
	text.fit_content = true 
	text.autowrap_mode = TextServer.AUTOWRAP_WORD
	text.add_theme_color_override("default_color", Color.WHITE)
	text.add_theme_font_size_override("normal_font_size", 16)
	panel.add_child(text)

	var button_y = 430
	
	if current_page > 0:
		var back_button = Button.new()
		back_button.text = "← НАЗАД"
		back_button.position = Vector2(50, button_y)
		back_button.size = Vector2(120, 40)
		back_button.pressed.connect(_on_back_pressed)
		panel.add_child(back_button)
	
	if current_page == 0 and pages.size() > 1:
		var skip_button = Button.new()
		skip_button.text = "ПРОПУСТИТЬ"
		skip_button.position = Vector2(50, button_y)
		skip_button.size = Vector2(120, 40)
		skip_button.pressed.connect(_on_skip_pressed)
		panel.add_child(skip_button)
	
	var page_indicator = Label.new()
	page_indicator.text = str(current_page + 1) + " / " + str(pages.size())
	page_indicator.position = Vector2(260, button_y + 8)
	page_indicator.size = Vector2(80, 30)
	page_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page_indicator.add_theme_color_override("font_color", Color.GRAY)
	page_indicator.add_theme_font_size_override("font_size", 16)
	panel.add_child(page_indicator)
	
	var next_button = Button.new()
	if current_page == pages.size() - 1:
		if is_first_time:
			next_button.text = "▶ НАЧАТЬ ИГРУ"
		else:
			next_button.text = "▶ ПРОДОЛЖИТЬ"
		next_button.position = Vector2(430, button_y)
	else:
		next_button.text = "ДАЛЕЕ →"
		next_button.position = Vector2(430, button_y)
	
	next_button.size = Vector2(120, 40)
	next_button.pressed.connect(_on_next_pressed)
	panel.add_child(next_button)
	
	add_child(panel)
	show()
	get_tree().paused = true

func _on_back_pressed():
	current_page -= 1
	if current_page >= 0:
		show_page()

func _on_next_pressed():
	current_page += 1
	if current_page < pages.size():
		show_page()
	else:
		close()

func _on_skip_pressed():
	close()

func close():
	if background:
		background.queue_free()
	if panel:
		panel.queue_free()
	hide()
	get_tree().paused = false
	closed.emit()
