extends Area2D

@onready var sprite = $Sprite2D
var is_player_near = false

func _ready():
	add_to_group("check_buttons")
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		is_player_near = true
		print("Игрок рядом с кнопкой!")
		if sprite:
			sprite.modulate = Color.YELLOW

func _on_body_exited(body):
	if body.name == "Player":
		is_player_near = false
		print("Игрок отошел от кнопки")
		if sprite:
			sprite.modulate = Color.WHITE

# Этот метод вызывается из player.gd
func interact():
	if not is_player_near:
		return


	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.1)
	await tween.finished
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
	await tween.finished
	
	var level_logic = get_node("/root/Main/LevelContainer/Level/LevelLogic")
	if not level_logic:
		level_logic = get_node("../LevelLogic")
	if not level_logic:
		level_logic = get_tree().root.find_child("LevelLogic", true, false)
	
	if level_logic and level_logic.has_method("check_win"):
		print("LevelLogic найден, вызываем check_win()")
		level_logic.check_win()
	else:
		print("LevelLogic НЕ НАЙДЕН!")
