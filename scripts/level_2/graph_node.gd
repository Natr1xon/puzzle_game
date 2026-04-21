extends Area2D

@export var node_name: String = "Node"
@export var node_value: int = 0
@export var connected_nodes: Array[Node] = []  # соседние узлы

@onready var sprite: Sprite2D = $Sprite2D
@onready var value_label: Label = $ValueLabel

@export var min_value: int = 1
@export var max_value: int = 9

signal player_entered(node)

func _ready():
	node_value = randi_range(min_value, max_value)
	
	update_display()
	add_to_group("travel_nodes")
	body_entered.connect(_on_body_entered)

func update_display():
	if value_label:
		value_label.text = str(node_value)

func _on_body_entered(body):
	if body.name == "Player":
		player_entered.emit(self)

func get_connections() -> Array:
	return connected_nodes

func add_value(amount: int):
	node_value += amount
	update_display()
