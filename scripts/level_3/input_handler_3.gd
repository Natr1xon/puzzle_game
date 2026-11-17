extends Node

var selected_peg: int = -1
var is_moving: bool = false
var selected_disk = null

@onready var level_logic = get_node("../LevelLogic")

func handle_peg_clicked(peg_index: int) -> void:
	if not level_logic:
		return
	
	if is_moving:
		Notify.warn("Подождите, диск перемещается...")
		return

	if selected_peg == -1:
		if not level_logic.pegs[peg_index].is_empty():
			selected_peg = peg_index
			level_logic.highlight_peg(selected_peg, true)

			selected_disk = level_logic.pegs[selected_peg].back()
			if selected_disk and selected_disk.has_method("highlight"):
				selected_disk.highlight(true)
			
			Notify.info("Выбран колышек " + str(selected_peg + 1))
		else:
			Notify.warn("На этом колышке нет дисков!")

		return

	if selected_peg == peg_index:
		Notify.warn("Нельзя переместить диск \n на тот же колышек!")
		clear_selection()
		return

	is_moving = true
	await level_logic.move_disk(selected_peg, peg_index)
	is_moving = false
	clear_selection()

func clear_selection() -> void:
	if selected_disk and is_instance_valid(selected_disk) and selected_disk.has_method("highlight"):
		selected_disk.highlight(false)

	if selected_peg >= 0:
		level_logic.highlight_peg(selected_peg, false)

	selected_disk = null
	selected_peg = -1
