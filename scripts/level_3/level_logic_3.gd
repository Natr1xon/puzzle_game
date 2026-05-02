extends Node2D

var pegs = [[], [], []]
var selected_peg = -1
var player_near_peg = -1
var is_moving = false

var DiskScene = preload("res://scenes/objects/disk.tscn")

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

func on_player_exited_peg_zone(peg_index: int):
	if player_near_peg == peg_index:
		player_near_peg = -1
		print("Игрок отошел от колышка ", peg_index)

func interact_with_current_peg():
	if is_moving:
		queue_message("Подождите, диск перемещается...")
		return false
		
	if player_near_peg == -1:
		queue_message("Нет колышка рядом!")
		return false
	
	if selected_peg == -1:
		if not pegs[player_near_peg].is_empty():
			selected_peg = player_near_peg
			highlight_peg(selected_peg, true)
			return true
		else:
			queue_message("На этом колышке нет дисков!")
			return false
	else:
		if selected_peg != player_near_peg:
			await move_disk_with_animation(selected_peg, player_near_peg)
		else:
			queue_message("Тот же колышек")
		
		highlight_peg(selected_peg, false)
		selected_peg = -1
		return true

func move_disk_with_animation(from_peg, to_peg):
	is_moving = true
	
	if pegs[from_peg].is_empty():
		is_moving = false
		return
	
	var disk = pegs[from_peg].back()
	
	if not pegs[to_peg].is_empty():
		if disk.disk_size > pegs[to_peg].back().disk_size:
			queue_message("Данный диск больше!")
			is_moving = false
			return
	
	var end_peg = $"../Pegs".get_child(to_peg)

	var final_y = -25 - pegs[to_peg].size() * (disk.size.y + 2)
	var final_x = end_peg.global_position.x - disk.size.x / 2
	var target_position = Vector2(final_x, final_y)
	
	var lift_height = -50
	var start_position = disk.position
	var lift_position = Vector2(start_position.x, start_position.y + lift_height)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(disk, "position", lift_position, 0.25)
	
	await tween.finished
	
	pegs[from_peg].pop_back()
	pegs[to_peg].append(disk)
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(disk, "position:x", target_position.x, 0.35)
	
	await tween.finished
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(disk, "position", target_position, 0.25)
	
	await tween.finished
	
	update_view()
	is_moving = false
	
	if pegs[2].size() == 5:
		queue_message("ПОБЕДА! 🎉")

func highlight_peg(peg_index: int, highlight: bool):
	var peg = $"../Pegs".get_child(peg_index)
	var sprite = peg.get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = Color.GREEN if highlight else Color.WHITE

func queue_message(text: String):
	message_queue.append(text)
	if not is_showing_message:
		show_next_message()

func show_next_message():
	if message_queue.is_empty():
		is_showing_message = false
		return
	
	is_showing_message = true
	var message_text = message_queue.pop_front()
	
	var canvas = CanvasLayer.new()
	canvas.name = "MessageLayer"
	canvas.layer = 100
	
	var panel = Panel.new()
	
	panel.custom_minimum_size = Vector2(400, 60)
	panel.size = Vector2(400, 60)
	
	await get_tree().process_frame  
	var viewport_size = get_viewport().get_visible_rect().size
	panel.position = Vector2(viewport_size.x / 2 - 200, 50)
	
	var label = Label.new()
	label.text = message_text
	label.custom_minimum_size = Vector2(380, 50)
	label.size = Vector2(380, 50)
	label.position = Vector2(10, 5)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 18)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.8)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	
	panel.add_theme_stylebox_override("panel", style)
	panel.add_child(label)
	canvas.add_child(panel)
	add_child(canvas)

	panel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.2)
	
	await get_tree().create_timer(2.0).timeout

	tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), 0.2)
	await tween.finished
	
	canvas.queue_free()
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
			var y = -25 - i * (disk.size.y + 2)  
			var x = center_x - disk.size.x / 2
			
			if not disk.is_animating:
				disk.position = Vector2(x, y)

func print_pegs_info():
	print("=== Текущее состояние ===")
	for i in range(3):
		var sizes = []
		for disk in pegs[i]:
			sizes.append(str(disk.disk_size))
		print("Колышек ", i, ": ", sizes)
