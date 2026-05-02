extends Node2D

@export var value: int = 0
@onready var label = $Label
@onready var sprite = $Sprite2D

var is_highlighted = false
var message_timer = null
var original_modulate = Color.WHITE

func update_label():
	if label:
		label.text = str(value)
	else:
		print("Ошибка: Label не найден в ", name)

func _ready():
	update_label()
	print("Я появился:", value)
	
	add_to_group("puzzle_objects")
	
	if sprite:
		original_modulate = sprite.modulate
	
	if not get_node_or_null("CollisionShape2D"):
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.extents = Vector2(32, 32)
		collision.shape = shape
		add_child(collision)
	
	var area = Area2D.new()
	area.name = "InteractionArea"
	var area_collision = CollisionShape2D.new()
	area_collision.shape = RectangleShape2D.new()
	area_collision.shape.extents = Vector2(40, 40)
	area.add_child(area_collision)
	add_child(area)

func highlight(enable: bool):
	is_highlighted = enable
	if sprite:
		sprite.modulate = Color.YELLOW if enable else original_modulate

func get_value():
	return value

func set_value(new_value):
	value = new_value
	update_label()
