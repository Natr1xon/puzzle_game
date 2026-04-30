extends Node2D

var pegs = [[], [], []]
var selected_peg = -1

var DiskScene = preload("res://scenes/objects/disk.tscn")

func _ready():
	init_game()
	print($"../Disks".get_child_count())
	for p in $"../Pegs".get_children():
		print(p.name, p.position)

func init_game():
	for i in range(5, 0, -1):
		var disk = create_disk(i)
		$"../Disks".add_child(disk)
		pegs[0].append(disk)

	update_view() # сразу правильная раскладка
		
func can_move(from_peg, to_peg):
	if pegs[from_peg].is_empty():
		return false

	var disk = pegs[from_peg].back()

	if pegs[to_peg].is_empty():
		return true

	return disk < pegs[to_peg].back()
	
func move_disk(from_peg, to_peg):
	if pegs[from_peg].is_empty():
		return

	var disk = pegs[from_peg].back()

	if not pegs[to_peg].is_empty():
		if disk.disk_size > pegs[to_peg].back().disk_size:
			return

	pegs[from_peg].pop_back()
	pegs[to_peg].append(disk)

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

			var center_x = peg.global_position.x
			var y = 300 - i * 25

			# 🔥 ВАЖНО: ширина диска
			var width = disk.disk_size * 20

			# центрируем диск
			var x = center_x - width / 2

			disk.position = Vector2(x, y)

func get_peg_under_mouse(mouse_pos: Vector2) -> int:
	for i in range($"../Pegs".get_child_count()):
		var peg = $"../Pegs".get_child(i)

		# ширина зоны клика
		var zone_width = 80

		if abs(mouse_pos.x - peg.global_position.x) < zone_width:
			return i

	return -1

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var peg = get_peg_under_mouse(get_global_mouse_position())
		print(peg)

		if peg == -1:
			return

		if selected_peg == -1:
			selected_peg = peg
		else:
			move_disk(selected_peg, peg)
			selected_peg = -1
			
