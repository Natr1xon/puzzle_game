extends Node2D

var pegs = [[], [], []]
var selected_peg = -1
var current_near_peg = -1
var tutorial_popup = null

var DiskScene = preload("res://scenes/objects/disk.tscn")
var input_handler = null

func _ready():
	await get_tree().process_frame
	show_tutorial()

func show_tutorial():
	show_tutorial_again(true)

func show_tutorial_again(first_time = false):
	if tutorial_popup:
		return
	
	get_tree().paused = true
	
	tutorial_popup = CanvasLayer.new()
	tutorial_popup.set_script(preload("res://scripts/ui/tutorial_popup.gd"))
	add_child(tutorial_popup)
	
	var pages = [
		{
			"title": "🗼 ЧТО ТАКОЕ ХАНОЙСКАЯ БАШНЯ?",
			"text": "Классическая головоломка!
			\n\nУ вас есть 3 стержня и 5 дисков разного размера.
			\n\nЦель - перенести все диски с левого стержня на правый."
		},
		{
			"title": "📏 ПРАВИЛА",
			"text": "• За один раз можно перемещать только один диск
			\n• Нельзя класть большой диск на маленький
			\n• Диски можно перемещать на любой стержень
			\n• Минимальное количество ходов для 5 дисков - 31"
		},
		{
			"title": "🎮 УПРАВЛЕНИЕ",
			"text": "1. Подойдите к стержню с диском и нажмите E
			\n   (стержень подсветится, диск выбран)
			\n2. Подойдите к другому стержню и нажмите E
			\n   (диск переместится)
			\n3. Соберите все диски на правом стержне"
		},
		{
			"title": "💡 СОВЕТ",
			"text": "Для решения используйте средний стержень как вспомогательный.
			\n\nПопробуйте найти самый эффективный способ!
			\n\n🎯 Удачи!
			\nЧтобы снова открыть это окно можете воспользоваться клавишей T"
		}
	]
	
	tutorial_popup.setup_tutorial(pages, first_time)
	await tutorial_popup.closed
	
	tutorial_popup.queue_free()
	tutorial_popup = null
	get_tree().paused = false

	if pegs[0].is_empty() and pegs[1].is_empty() and pegs[2].is_empty():
		start_game()

func start_game():
	input_handler = get_node("../InputHandler")
	
	var pegs_list = $"../Pegs".get_children()
	for i in range(pegs_list.size()):
		pegs_list[i].index = i
	
	init_game()
	
	Notify.info("Переместите все диски на правый стержень!", 3.0)

func on_player_entered_peg_zone(peg_index: int):
	current_near_peg = peg_index

func on_player_exited_peg_zone(peg_index: int):
	if current_near_peg == peg_index:
		current_near_peg = -1

func interact_with_current_peg():
	if current_near_peg == -1:
		Notify.warn("Подойдите к колышку!")
		return false
	
	if input_handler:
		input_handler.handle_peg_clicked(current_near_peg)
	return true

func highlight_peg(peg_index: int, highlight: bool):
	var peg = $"../Pegs".get_child(peg_index)
	var sprite = peg.get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = Color.YELLOW if highlight else Color.WHITE

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
			
			disk.position = Vector2(x, y)
