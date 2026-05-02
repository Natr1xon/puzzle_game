extends Node2D
class_name Peg

@export var index: int = -1
var level_logic = null

func _ready():
	level_logic = find_level_logic()
	
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
	var node = get_parent()
	while node:
		if node.has_method("on_player_entered_peg_zone"):
			return node
		node = node.get_parent()

	return get_tree().root.find_child("LevelLogic", true, false)

func _on_body_entered(body):
	if body.name == "Player":
		print("Игрок вошел в зону колышка ", index)
		if level_logic and level_logic.has_method("on_player_entered_peg_zone"):
			level_logic.on_player_entered_peg_zone(index)

func _on_body_exited(body):
	if body.name == "Player":
		print("Игрок покинул зону колышка ", index)
		if level_logic and level_logic.has_method("on_player_exited_peg_zone"):
			level_logic.on_player_exited_peg_zone(index)
