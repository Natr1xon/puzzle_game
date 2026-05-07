extends Node2D
class_name Peg

@export var index: int = -1
var level_logic = null

func _ready():
	await get_tree().process_frame
	find_level_logic()
	
	var detection_area = Area2D.new()
	detection_area.name = "DetectionArea"
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(80, 80)
	collision.shape = shape
	
	detection_area.add_child(collision)
	add_child(detection_area)
	
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func find_level_logic():
	var level_logics = get_tree().get_nodes_in_group("level_logic")
	if level_logics.size() > 0:
		level_logic = level_logics[0]
		print("LevelLogic найден через группу для пега ", index)
		return level_logic
	
	print("LevelLogic НЕ НАЙДЕН для пега ", index)
	return null

func refresh_level_logic():
	if not level_logic or not is_instance_valid(level_logic):
		find_level_logic()

func _on_body_entered(body):
	if body.name == "Player":
		print("Игрок вошел в зону колышка ", index)
		if level_logic and level_logic.has_method("on_player_entered_peg_zone"):
			level_logic.on_player_entered_peg_zone(index)
		else:
			print("Не удалось вызвать on_player_entered_peg_zone для пега ", index)

func _on_body_exited(body):
	if body.name == "Player":
		print("Игрок покинул зону колышка ", index)
		if level_logic and level_logic.has_method("on_player_exited_peg_zone"):
			level_logic.on_player_exited_peg_zone(index)
		else:
			print("Не удалось вызвать on_player_exited_peg_zone для пега ", index)
