extends Area2D

signal player_killed

@onready var timer: Timer = $Timer

func _ready():
	add_to_group("killzones")
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"): 
		print("Игрок выпал")
		timer.start()

func _on_timer_timeout() -> void:
	player_killed.emit()
