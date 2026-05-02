extends Node2D

var pegs = [[], [], []]
var DiskScene = preload("res://scenes/objects/disk.tscn")
var current_near_peg = -1

var message_timer = null
var input_handler = null

func _ready():
	input_handler = get_node("../InputHandler")
	if not input_handler:
		print("InputHandler не найден!")

	var pegs_list = $"../Pegs".get_children()
	for i in range(pegs_list.size()):
		pegs_list[i].index = i
		print("Назначен индекс ", i, " для ", pegs_list[i].name)
	
	init_game()
	print_pegs_info()

func on_player_entered_peg_zone(peg_index: int):
	current_near_peg = peg_index
	print("Игрок рядом с колышком ", peg_index)


	message_timer = get_tree().create_timer(1.5)
	await message_timer.timeout

	if current_near_peg == peg_index:
		Notify.info("Нажмите E для взаимодействия с колышком ", 2.0)

func on_player_exited_peg_zone(peg_index: int):
	if current_near_peg == peg_index:
		current_near_peg = -1
		print("Игрок отошел от колышка ", peg_index)

func interact_with_current_peg():
	if current_near_peg == -1:
		Notify.warn("Подойдите к колышку!")
		return false

	if input_handler:
		input_handler.handle_peg_clicked(current_near_peg)
	else:
		Notify.error("Ошибка: InputHandler не найден!")
	
	return true

func highlight_peg(peg_index: int, highlight: bool):
	var peg = $"../Pegs".get_child(peg_index)
	var sprite = peg.get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = Color.RED if highlight else Color.WHITE

func init_game():
	for child in $"../Disks".get_children():
		child.queue_free()
	
	pegs = [[], [], []]

	for i in range(5, 0, -1):
		var disk = create_disk(i)
		$"../Disks".add_child(disk)
		pegs[0].append(disk)
	
	update_view()

func create_disk(size: int):
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
			
			disk.position = Vector2(x, y)

func print_pegs_info():
	print("=== Текущее состояние ===")
	for i in range(3):
		var sizes = []
		for disk in pegs[i]:
			sizes.append(str(disk.disk_size))
		print("Колышек ", i, ": ", sizes)
