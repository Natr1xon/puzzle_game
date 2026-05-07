extends Node

var current_node = null
var all_nodes = []
var total_value: int = 0
var player_path: Array = []
var drawn_connections = {}
var tutorial_popup = null
var start_time = 0 
var is_completed = false

signal node_reached(node)
signal travel_failed(reason)

@onready var connection_container = $"../Connections"
@onready var main = get_tree().root.get_node("Main")

func _ready():
	add_to_group("level_logic")
	await get_tree().process_frame
	show_tutorial()

func show_tutorial():
	show_tutorial_again(true)

func show_tutorial_again(first_time = false):
	if tutorial_popup:
		return
	
	get_tree().paused = true
	
	tutorial_popup = CanvasLayer.new()
	tutorial_popup.set_script(preload("res://scripts/ui/tutorial_popup.gd"))
	add_child(tutorial_popup)
	
	var pages = [
		{
			"title": "🗺 ТЕОРИЯ: ЧТО ТАКОЕ ГРАФ?",
			"text": "Граф — это математическая структура, состоящая из вершин (узлов) и рёбер (связей).
			\nГрафы используются для описания сетей, маршрутов, связей между объектами и моделирования сложных систем.
			\nВ этой задаче каждая вершина содержит число, которое добавляется к общей сумме при посещении."
		},
		{
			"title": "🧠 НАУЧНОЕ ПРИМЕНЕНИЕ",
			"text": "Теория графов активно применяется:
			\n• в навигационных системах
			\n• в компьютерных сетях
			\n• в социальных сетях
			\n• в логистике и транспорте
			\n• в искусственном интеллекте
			\nАлгоритмы графов помогают находить кратчайшие и наиболее эффективные пути."
		},
		{
			"title": "🎮 КАК ПУТЕШЕСТВОВАТЬ?",
			"text": "1. Проходите через вершины (таблички), чтобы отметить их посещение
			\n2. Перемещаться можно только по существующим рёбрам
			\n3. Посещённые узлы подсвечиваются зелёным
			\n4. Необходимо посетить 5 узлов
			\n5. Постарайтесь выбрать оптимальный маршрут"
		},
		{
			"title": "💡 ОПТИМИЗАЦИЯ МАРШРУТА",
			"text": "• Пройденный путь отображается яркой линией
			\n• В конце уровень оценит эффективность маршрута
			\n• Узлы с меньшими значениями позволяют уменьшить итоговую сумму
			\n🎯 Исследуйте граф и найдите наиболее выгодный путь!
			\n\nНажмите T, чтобы снова открыть справку."
		}
	]
	
	tutorial_popup.setup_tutorial(pages, first_time)
	await tutorial_popup.closed
	
	tutorial_popup.queue_free()
	tutorial_popup = null
	get_tree().paused = false
	
	if not is_completed and all_nodes.is_empty():
		start_game()

func start_game():
	start_time = Time.get_ticks_msec()
	find_all_nodes()
	reset_total()
	
	for node in all_nodes:
		if node.has_signal("player_entered"):
			node.player_entered.connect(_on_player_reached_node)
	
	Notify.info("Исследуйте граф! Посетите 5 узлов!", 3.0)

func find_all_nodes():
	all_nodes = get_tree().get_nodes_in_group("travel_nodes")
	print("Найдено узлов: ", all_nodes.size())

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
		Notify.warn("Переход невозможен!", 3.0)
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
	
	var is_connected_node = to_node in from_node.connected_nodes
	if not is_connected_node:
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
		var current_node_path = unvisited[0]
		for node in unvisited:
			if distances[node] < distances[current_node_path]:
				current_node_path = node
				
		if current_node_path == end_node:
			break

		unvisited.erase(current_node_path)

		for neighbor in current_node_path.connected_nodes:
			var new_dist = distances[current_node_path] + neighbor.node_value
			
			if new_dist < distances[neighbor]:
				distances[neighbor] = new_dist
				previous[neighbor] = current_node_path

	var path = []
	var current_path_node = end_node
	
	while current_path_node != null:
		path.insert(0, current_path_node)
		current_path_node = previous[current_path_node]

	return path

func calculate_path_cost(path: Array) -> int:
	var sum = 0
	for node in path:
		sum += node.node_value
	return sum

func compare_with_optimal(start_node, end_node):
	var optimal_path = find_shortest_path(start_node, end_node)
	
	return calculate_path_cost(optimal_path)

func check_win():
	if player_path.size() == 5:
		is_completed = true
		show_completion_window()
	else:
		var remaining = 5 - player_path.size()
		Notify.info("Осталось посетить узлов: " + str(remaining), 2.0)

func show_completion_window():
	if main and main.has_method("show_completion_window"):
		var time_spent = (Time.get_ticks_msec() - start_time) / 1000.0
		var minutes = floor(time_spent / 60)
		var seconds = int(time_spent) % 60 
		var time_string = str(minutes) + "м " + str(seconds) + "с"
		
		var optimal_path_sum = compare_with_optimal(player_path[0], player_path[-1])
		
		main.show_completion_window("graph", {
			"time_spent": time_string,
			"visited_nodes": player_path.size(),
			"total_visited": 5,
			"total_sum": total_value,
			"optimal_sum": optimal_path_sum,
			"completed": true,
			"next_level": "res://scenes/levels/level_03.tscn"
		})
