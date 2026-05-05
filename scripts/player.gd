extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

var selected_object = null
var is_passing_through = false
var spawn_position = Vector2.ZERO

const ONE_WAY_LAYER = 2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var input_handler = get_node("../InputHandler")
@onready var interaction_area = get_node_or_null("InteractionArea")

func _ready():
	floor_max_angle = deg_to_rad(75)
	floor_stop_on_slope = false
	floor_snap_length = 5.0
	
	spawn_position = global_position
	add_to_group("player")

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
	
	if Input.is_action_just_pressed("interact"):
		interact_with_button()
		interact_with_puzzle()
		interact_with_tower()

	move_and_slide()

func respawn():
	global_position = spawn_position

	velocity = Vector2.ZERO

	is_passing_through = false

	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)

func interact_with_tower():
	var level_logic = get_node("../LevelLogic")
	if level_logic and level_logic.has_method("interact_with_current_peg"):
		level_logic.interact_with_current_peg()
		
func interact_with_puzzle():
	if input_handler and input_handler.has_method("handle_interact"):		
		var nearest = find_nearest_puzzle_object()
		if nearest:
			input_handler.handle_interact(nearest)
		else:
			print("Нет puzzle object рядом")

func interact_with_button():
	var buttons = get_tree().get_nodes_in_group("check_buttons")
	for button in buttons:
		var distance = global_position.distance_to(button.global_position)
		if distance < 30:
			if button.has_method("interact"):
				button.interact()
			return

func find_nearest_puzzle_object():
	var puzzle_objects = get_tree().get_nodes_in_group("puzzle_objects")
	var nearest = null
	var min_distance = 10.0
	
	for obj in puzzle_objects:
		var distance = global_position.distance_to(obj.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest = obj
	
	return nearest

func pass_through_one_way_platform():
	var layer_bit = 1 << (ONE_WAY_LAYER - 1)  
	collision_mask &= ~layer_bit  
	is_passing_through = true
	velocity.y = 40
	
	await get_tree().create_timer(0.2).timeout
	collision_mask |= layer_bit
	is_passing_through = false
