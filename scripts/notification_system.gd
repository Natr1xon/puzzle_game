extends CanvasLayer

var message_queue = []
var is_showing = false

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	layer = 100
	setup_ui()

	await get_tree().process_frame
	for child in get_tree().get_nodes_in_group("NotificationSystem"):
		if child != self:
			child.queue_free()
	
	add_to_group("NotificationSystem")

func setup_ui():
	var container = Control.new()
	container.name = "NotificationContainer"
	container.anchor_right = 1.0
	container.anchor_top = 0.0
	add_child(container)

func show_message(text: String, duration: float = 2.0):
	message_queue.append({
		"text": text,
		"duration": duration
	})
	
	if not is_showing:
		show_next_message()

func show_next_message():
	if message_queue.is_empty():
		is_showing = false
		return
	
	is_showing = true
	var msg = message_queue.pop_front()
	
	var notification = create_notification(msg.text)
	add_child(notification)
	
	notification.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(notification, "modulate", Color(1, 1, 1, 1), 0.2)
	
	await get_tree().create_timer(msg.duration).timeout
	
	if notification and is_instance_valid(notification):
		tween = create_tween()
		tween.tween_property(notification, "modulate", Color(1, 1, 1, 0), 0.2)
		await tween.finished
		notification.queue_free()
	
	await get_tree().create_timer(0.1).timeout
	show_next_message()

func create_notification(text: String) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(400, 60)
	panel.size = Vector2(400, 60)

	var viewport = get_viewport()
	if viewport:
		var viewport_size = viewport.get_visible_rect().size
		panel.position = Vector2(viewport_size.x / 2 - 200, 50)
	else:
		panel.position = Vector2(440, 50)
	
	var label = Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(380, 50)
	label.size = Vector2(380, 50)
	label.position = Vector2(10, 5)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 18)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.85)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	
	panel.add_theme_stylebox_override("panel", style)
	panel.add_child(label)
	
	return panel

func success(text: String, duration: float = 1.5):
	show_message("✅ " + text, duration)

func error(text: String, duration: float = 2.0):
	show_message("❌ " + text, duration)

func info(text: String, duration: float = 2.0):
	show_message("ℹ️ " + text, duration)

func warn(text: String, duration: float = 2.0):
	show_message("⚠️ " + text, duration)
