extends Node

var selected_peg = -1
var is_moving = false

var level_logic = null

func _ready():
	level_logic = get_node("../LevelLogic")
	if not level_logic:
		print("LevelLogic не найден!")

func handle_peg_clicked(peg_index: int):
	if not level_logic:
		return
	
	if is_moving:
		Notify.warn("Подождите, диск перемещается...")
		return
	
	if selected_peg == -1:
		if not level_logic.pegs[peg_index].is_empty():
			selected_peg = peg_index
			level_logic.highlight_peg(selected_peg, true)
			Notify.info("Выбран колышек " + str(selected_peg + 1))
		else:
			Notify.warn("На этом колышке нет дисков!")
	else:
		if selected_peg != peg_index:
			await move_disk(selected_peg, peg_index)
		else:
			Notify.warn("Нельзя переместить диск на тот же колышек!")
		
		level_logic.highlight_peg(selected_peg, false)
		selected_peg = -1

func move_disk(from_peg: int, to_peg: int):
	is_moving = true
	
	if level_logic.pegs[from_peg].is_empty():
		is_moving = false
		return
	
	var disk = level_logic.pegs[from_peg].back()

	if not level_logic.pegs[to_peg].is_empty():
		if disk.disk_size > level_logic.pegs[to_peg].back().disk_size:
			Notify.error("Нельзя положить большой диск на маленький!")
			is_moving = false
			return
	
	var end_peg = get_node("../Pegs").get_child(to_peg)
	
	var final_y = -25 - level_logic.pegs[to_peg].size() * (disk.size.y + 2)
	var final_x = end_peg.global_position.x - disk.size.x / 2
	var target_position = Vector2(final_x, final_y)
	
	var start_position = disk.position
	var lift_position = Vector2(start_position.x, start_position.y - 50)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(disk, "position", lift_position, 0.25)
	
	await tween.finished
	
	level_logic.pegs[from_peg].pop_back()
	level_logic.pegs[to_peg].append(disk)

	if level_logic and level_logic.has_method("increment_moves"):
		level_logic.increment_moves()
	
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
	
	level_logic.update_view()
	
	is_moving = false

func interact_with_current_peg(peg_index: int):
	handle_peg_clicked(peg_index)
