extends Node2D

@onready var area = $Area2D

func interact():
	print("Check")
	scale = Vector2(0.9, 0.9)
	await get_tree().create_timer(0.1).timeout
	scale = Vector2(1, 1)

	var result = get_node("../LevelLogic").check_win()
	get_node("../LevelLogic").check_answer(result)
