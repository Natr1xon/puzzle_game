extends Node2D

@export var value: int = 0
@onready var label = $Label
@onready var sprite = $Sprite2D

var is_highlighted = false
var message_timer = null
var original_modulate = Color.WHITE

func _ready():
	update_label()
	
	add_to_group("puzzle_objects")
	
	if sprite:
		original_modulate = sprite.modulate

func update_label():
	if label:
		label.text = str(value)
	else:
		print("Ошибка: Label не найден в ", name)

func highlight(enable: bool):
	is_highlighted = enable
	if sprite:
		sprite.modulate = Color.GREEN if enable else original_modulate

func get_value():
	return value

func set_value(new_value):
	value = new_value
	update_label()
