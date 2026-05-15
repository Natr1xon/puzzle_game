extends Node2D
class_name Peg

@export var index: int = -1
var level_logic = null
var timer: Timer = null
var is_player_near = false

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
	return null

func _on_body_entered(body):
	if body.name == "Player":
		is_player_near = true
		if level_logic:
			level_logic.on_player_entered_peg_zone(index)

func _on_body_exited(body):
	if body.name == "Player":
		print("exit")
		is_player_near = false
		if level_logic:
			level_logic.on_player_exited_peg_zone(index)
