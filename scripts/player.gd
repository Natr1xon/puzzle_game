extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

var selected_object = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var input_handler = get_node("../InputHandler")
@onready var interaction_area = get_node_or_null("InteractionArea")

func _ready():
	print("interaction_area valid:", is_instance_valid(interaction_area))
	print("InputHandler:", input_handler)
	print("interaction_area:", interaction_area)
	print("Дети Player:")
	for child in get_children():
		print(child.name)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
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
		interact()

	move_and_slide()
	
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

		# поднимаемся вверх по дереву
		while obj != null and not obj.has_method("get_value"):
			obj = obj.get_parent()
		
		if obj != null:
			print("Выбрал:", obj.name)
			input_handler.handle_interact(obj)
			return

	print("PuzzleObject не найден")
