extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

var selected_object = null
var is_passing_through = false

const ONE_WAY_LAYER = 2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var input_handler = get_node("../InputHandler")
@onready var interaction_area = get_node_or_null("InteractionArea")

func _ready():
	floor_max_angle = deg_to_rad(75)
	floor_stop_on_slope = false
	floor_snap_length = 5.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_passing_through:
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("move_down") and is_on_floor() and not is_passing_through:
		pass_through_one_way_platform()

	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0: 
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# ВЗАИМОДЕЙСТВИЕ С БАШНЕЙ
	if Input.is_action_just_pressed("interact"):
		interact_with_tower()

	move_and_slide()

func interact_with_tower():
	# Находим LevelLogic и вызываем взаимодействие с текущим колышком
	var level_logic = get_tree().root.find_child("LevelLogic", true, false)
	if level_logic and level_logic.has_method("interact_with_current_peg"):
		level_logic.interact_with_current_peg()
	else:
		# Старая логика для других объектов
		interact()

func pass_through_one_way_platform():
	var layer_bit = 1 << (ONE_WAY_LAYER - 1)  
	collision_mask &= ~layer_bit  
	is_passing_through = true
	velocity.y = 40
	
	await get_tree().create_timer(0.2).timeout
	collision_mask |= layer_bit
	is_passing_through = false

func interact():
	if interaction_area == null:
		print("InteractionArea НЕ НАЙДЕН!")
		return

	var areas = interaction_area.get_overlapping_areas()

	if areas.size() == 0:
		return

	for area in areas:
		var obj = area
		
		if obj.get_parent().has_method("interact"):
			obj.get_parent().interact()
			return

		while obj != null and not obj.has_method("get_value"):
			obj = obj.get_parent()
		
		if obj != null:
			print("Выбрал:", obj.name)
			if input_handler and input_handler.has_method("handle_interact"):
				input_handler.handle_interact(obj)
			return

	print("PuzzleObject не найден")
