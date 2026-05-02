extends Node2D
class_name Peg

@export var index: int = -1

func _ready():
	print("Peg ", index, " (", name, ") создан в позиции: ", global_position)
	
	# Добавляем Area2D для обнаружения игроком (без кликов мышкой)
	var detection_area = Area2D.new()
	detection_area.name = "DetectionArea"
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(80, 80)  # Увеличенная зона обнаружения
	collision.shape = shape
	
	detection_area.add_child(collision)
	add_child(detection_area)
	
	# Подключаем сигналы для обнаружения игрока
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		print("Игрок вошел в зону колышка ", index)
		var level_logic = get_tree().root.find_child("LevelLogic", true, false)
		if level_logic and level_logic.has_method("on_player_entered_peg_zone"):
			level_logic.on_player_entered_peg_zone(index)

func _on_body_exited(body):
	if body.name == "Player":
		print("Игрок покинул зону колышка ", index)
		var level_logic = get_tree().root.find_child("LevelLogic", true, false)
		if level_logic and level_logic.has_method("on_player_exited_peg_zone"):
			level_logic.on_player_exited_peg_zone(index)
