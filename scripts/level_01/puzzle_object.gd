extends Node2D

@export var value: int = 0
@onready var label = $Label
@onready var sprite = $Sprite2D

var is_highlighted = false
var original_modulate = Color.WHITE

func update_label():
	label.text = str(value)

func _ready():
	update_label()
	print("Я появился:", value)
	
func highlight(enable: bool):
	is_highlighted = enable
	modulate = Color.YELLOW if enable else original_modulate

	if sprite:
		sprite.modulate = Color.YELLOW if enable else Color.WHITE
	
func get_value():
	return value
	
func set_value(new_value):
	value = new_value
	update_label()
