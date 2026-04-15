# Scripts/GraphManager.gd
extends Node

var current_node = null
var all_nodes = []
var total_value: int = 0
var player_path: Array = []

signal node_reached(node)
signal travel_failed(reason)

func _ready():
	randomize()
	await get_tree().process_frame
	find_all_nodes()
	
	for node in all_nodes:
		if node.has_signal("player_entered"):
			node.player_entered.connect(_on_player_reached_node)

func find_all_nodes():
	all_nodes = get_tree().get_nodes_in_group("travel_nodes")
	print("Найдено узлов: ", all_nodes.size())

func _on_player_reached_node(node):
	print("🚶 Игрок достиг узла: ", node.node_name)
	
	var old_node = current_node
	current_node = node
	
	# Проверяем переход
	if old_node and not can_travel(old_node, node):
		print("❌ Переход невозможен!")
		current_node = old_node
		travel_failed.emit("Путь закрыт")
		return
	
	# 👉 ДОБАВЛЯЕМ В СУММУ
	total_value += node.node_value
	player_path.append(node)
	
	node_reached.emit(node)
	print("✅ Текущий узел: ", node.node_name, 
		" (значение: ", node.node_value, 
		") | Общая сумма: ", total_value)

func can_travel(from_node, to_node) -> bool:
	# Можно перейти только если узлы связаны
	if from_node == null:
		return true  # первый узел
	
	var is_connected = to_node in from_node.connected_nodes
	if not is_connected:
		print("⚠️ Узлы ", from_node.node_name, " и ", to_node.node_name, " не связаны!")
		return false
	
	# Дополнительные условия (например, нужно иметь определённую сумму)
	# if from_node.node_value < 5:
	#     print("⚠️ Нужно набрать 5 очков!")
	#     return false
	
	return true
	
func get_total_value() -> int:
	return total_value
	
func reset_total():
	total_value = 0

func get_current_value() -> int:
	return current_node.node_value if current_node else 0

func add_to_current_value(amount: int):
	if current_node:
		current_node.add_value(amount)
		
func find_shortest_path(start_node, end_node):
	var distances = {}
	var previous = {}
	var unvisited = []

	# Инициализация
	for node in all_nodes:
		distances[node] = INF
		previous[node] = null
		unvisited.append(node)

	distances[start_node] = 0

	while unvisited.size() > 0:
		# Находим узел с минимальной дистанцией
		var current = unvisited[0]
		for node in unvisited:
			if distances[node] < distances[current]:
				current = node

		# Если дошли до цели — выходим
		if current == end_node:
			break

		unvisited.erase(current)

		# Проверяем соседей
		for neighbor in current.connected_nodes:
			var new_dist = distances[current] + neighbor.node_value
			
			if new_dist < distances[neighbor]:
				distances[neighbor] = new_dist
				previous[neighbor] = current

	# Восстанавливаем путь
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
	
	print("🧍 Путь игрока: ", player_cost)
	print("🤖 Кратчайший путь: ", optimal_cost)
	
	if player_cost == optimal_cost:
		print("🏆 Идеально!")
	elif player_cost <= optimal_cost * 1.2:
		print("👍 Почти оптимально")
	else:
		print("😬 Можно лучше")
		
func check_win():
	compare_with_optimal(player_path[0], player_path[-1])
	
func check_answer(is_correct: bool):
	return true
