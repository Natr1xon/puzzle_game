extends Node

var current_node = null
var all_nodes = []
var total_value: int = 0
var player_path: Array = []
var drawn_connections = {}

signal node_reached(node)
signal travel_failed(reason)

@onready var feedback_label = $"../Player/FeedbackLabel"
@onready var connection_container = $"../Connections"
@onready var main = get_tree().root.get_node("Main")

func _ready():
	feedback_label.text = ' '
	randomize()
	await get_tree().process_frame
	find_all_nodes()
	
	for node in all_nodes:
		if node.has_signal("player_entered"):
			node.player_entered.connect(_on_player_reached_node)

func find_all_nodes():
	all_nodes = get_tree().get_nodes_in_group("travel_nodes")
	print("Найдено узлов: ", all_nodes.size())

func show_feedback(text: String, duration: float = 1.0):
	feedback_label.text = text
	feedback_label.modulate.a = 1.0
	
	await get_tree().create_timer(duration).timeout
	
	var tween = create_tween()
	tween.tween_property(feedback_label, "modulate:a", 0.0, 0.5)

func draw_connection(a, b):
	var key = str(a.get_instance_id()) + "_" + str(b.get_instance_id())
	var reverse_key = str(b.get_instance_id()) + "_" + str(a.get_instance_id())
	
	if key in drawn_connections or reverse_key in drawn_connections:
		return
	
	var line = Line2D.new()
	
	line.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(line, "modulate:a", 1.0, 0.3)
	
	line.width = 1.5
	line.default_color = Color(0.7, 0.7, 1)
	line.antialiased = true
	
	line.add_point(a.global_position)
	line.add_point(b.global_position)
	
	connection_container.add_child(line)
	
	drawn_connections[key] = line
	
func highlight_connection(a, b):
	var key = str(a.get_instance_id()) + "_" + str(b.get_instance_id())
	var reverse_key = str(b.get_instance_id()) + "_" + str(a.get_instance_id())
	
	var line = drawn_connections.get(key, drawn_connections.get(reverse_key))
	
	if line:
		line.default_color = Color(0.102, 1.0, 0.302, 0.816) 

func _on_player_reached_node(node):
	print("🚶 Игрок достиг узла: ", node.node_name)
	
	var old_node = current_node
	current_node = node
	
	if old_node and not can_travel(old_node, node):
		show_feedback("❌ Переход невозможен!")
		current_node = old_node
		travel_failed.emit("Путь закрыт")
		return

	for neighbor in node.connected_nodes:
		draw_connection(node, neighbor)
	
	if old_node:
		highlight_connection(old_node, node)
	
	total_value += node.node_value
	player_path.append(node)
	
	node.set_visited()

	if main:
		main.update_hud_sum(total_value)
	
	node_reached.emit(node)
	print("✅ Текущий узел: ", node.node_name, 
		" (значение: ", node.node_value, 
		") | Общая сумма: ", total_value)

func can_travel(from_node, to_node) -> bool:
	if from_node == null:
		return true 
	
	var is_connected = to_node in from_node.connected_nodes
	if not is_connected:
		print("⚠️ Узлы ", from_node.node_name, " и ", to_node.node_name, " не связаны!")
		return false
	
	return true
	
func get_total_value() -> int:
	return total_value
	
func reset_total():
	total_value = 0
	
	if main:
		main.update_hud_sum(0)

func get_current_value() -> int:
	return current_node.node_value if current_node else 0

func add_to_current_value(amount: int):
	if current_node:
		current_node.add_value(amount)
		
func find_shortest_path(start_node, end_node):
	var distances = {}
	var previous = {}
	var unvisited = []

	for node in all_nodes:
		distances[node] = INF
		previous[node] = null
		unvisited.append(node)

	distances[start_node] = 0

	while unvisited.size() > 0:
		var current = unvisited[0]
		for node in unvisited:
			if distances[node] < distances[current]:
				current = node
				
		if current == end_node:
			break

		unvisited.erase(current)

		for neighbor in current.connected_nodes:
			var new_dist = distances[current] + neighbor.node_value
			
			if new_dist < distances[neighbor]:
				distances[neighbor] = new_dist
				previous[neighbor] = current

	var path = []
	var current = end_node
	
	while current != null:
		path.insert(0, current)
		current = previous[current]

	return path

func calculate_path_cost(path: Array) -> int:
	var sum = 0
	for node in path:
		sum += node.node_value
	return sum
	
func compare_with_optimal(start_node, end_node):
	var optimal_path = find_shortest_path(start_node, end_node)
	
	var player_cost = calculate_path_cost(player_path)
	var optimal_cost = calculate_path_cost(optimal_path)
	
	var format_string = "🧍 Ваш путь: {player_cost} \n 🤖 Кратчайший путь: {optimal_cost}"
	var actual_string = format_string.format(
		{"player_cost": player_cost, "optimal_cost": optimal_cost}
	)
	
	show_feedback(actual_string)
	
func check_win():
	compare_with_optimal(player_path[0], player_path[-1])
