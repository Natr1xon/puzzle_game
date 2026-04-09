extends Node2D

@export var value: int = 0
@onready var label = $Label

func update_label():
	label.text = str(value)

func _ready():
	update_label()
	print("Я появился:", value)
	
func get_value():
	return value
	
func set_value(new_value):
	value = new_value
	update_label()
