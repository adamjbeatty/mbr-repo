extends Node2D


var cam_velocity = 0.0

var walkers = []
var destination
var can_move = true

var line: TileMapPattern

@onready var node_parent = $PathNodes
@onready var camera = $Camera2D
@onready var bg_color = $Parallax2D/Node2D/ColorRect
@onready var bg_icon_color1 = $Parallax2D/Node2D/BG
@onready var bg_icon_color2 = $Parallax2D/Node2D/BG2
@onready var bg_icon_fill = $Parallax2D/Node2D/BG/BGFill

@onready var path1 = $Path1
@onready var path2 = $Path2
@onready var path3 = $Path3
@onready var path4 = $Path4
@onready var path5 = $Path5
@onready var path6 = $Path6
@onready var path7 = $Path7

@onready var player_path = $PathMask/TakenPath
@onready var mask = $PathMask

signal swap_to_runner()
signal swap_to_shop()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	walkers = Global.walkers
	
	bg_color.modulate = Color(0.482, 0.482, 0.482)
	bg_icon_color1.modulate = Color(0.708, 0.0, 0.148)
	bg_icon_color2.modulate = Color(0.708, 0.0, 0.148)
	
	camera.position.x = (Global.taken_path.size() + 3) * 16 * 5
	
	
	if Global.map_tile_data == []:
		_generate_new_map()
	else:
		print(Global.map_tile_data[0])
		path1.tile_map_data = Global.map_tile_data[0]
		path2.tile_map_data = Global.map_tile_data[1]
		path3.tile_map_data = Global.map_tile_data[2]
		path4.tile_map_data = Global.map_tile_data[3]
		path5.tile_map_data = Global.map_tile_data[4]
		path6.tile_map_data = Global.map_tile_data[5]
		path7.tile_map_data = Global.map_tile_data[6]
		
		player_path.tile_map_data = Global.map_tile_data[7]
		mask.custom_minimum_size.x = (player_path.get_used_rect().size.x + player_path.get_used_rect().position.x) * 16
		
		var next_nodes = Global.path_nodes[Global.taken_path[Global.taken_path.size() - 1]]
		for node in Global.path_nodes.keys():
			draw_node(node)
			if not node in next_nodes:
				get_node('PathNodes/' + str(node)).get_child(0).self_modulate = Color(0.34, 0.34, 0.34)
			else:
				get_node('PathNodes/' + str(node)).get_child(0).self_modulate = Color(1.0, 1.0, 1.0)
				get_node('PathNodes/' + str(node)).selectable = true
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	var direction = Input.get_axis("left","right")
	if direction:
		cam_velocity += direction * .1
		camera.position.x += cam_velocity
	else:
		cam_velocity = 0
	
	camera.global_position = round(camera.global_position)
	camera.global_position.x = clamp(camera.global_position.x,450,camera.limit_right)


func _generate_new_map() -> void:
	var collumn = 1
	var node_id = []
	
	while true:
		var row = randi() % 9 + 1
		node_id = [collumn, row]
		
		walkers[Global.path_nodes.size()] = node_id
		walkers[3] = walkers[1]
		walkers[4] = walkers[2]
		walkers[5] = walkers[0]
		walkers[6] = walkers[0]

		Global.path_nodes[node_id] = []
		Global.trail_nodes[node_id] = []
		Global.node_types[node_id] = 'easy'
		if Global.path_nodes.size() > 2:
			break
			

	for node in Global.path_nodes.keys():
		draw_node(node)
		path1.set_cell(Vector2i(node[0]*5,node[1]*2),1,Vector2i(0,2))
		path1.set_cell(Vector2i(node[0]*5 - 1,node[1]*2),1,Vector2i(0,2))
		get_node('PathNodes/' + str(node)).selectable = true
	
	for i in range(14):
		_generate_next_collumn()
	
	Global.map_tile_data = [path1.tile_map_data,path2.tile_map_data,path3.tile_map_data,path4.tile_map_data,path5.tile_map_data,path6.tile_map_data,path7.tile_map_data,player_path.tile_map_data,]
	
	





func _generate_next_collumn() -> void:
	for i in range(walkers.size()):
		var prior_node = walkers[i]
		var dir = ''
		var path
		
		var cross_check = false
		for sub_array in Global.path_nodes.values():
			if [walkers[i][0] + 1,walkers[i][1]] in sub_array:
				cross_check = true
				walkers[i] = [walkers[i][0] + 1,walkers[i][1]]
				dir = 'straight'
		
		if not cross_check:
			if walkers[i][1] == 1:
				var choice = randi() % 2
				
				if choice == 0:
					walkers[i] = [walkers[i][0] + 1,1]
					dir = 'straight'
				else:
					walkers[i] = [walkers[i][0] + 1,2]
					dir = 'down'
					
			elif walkers[i][1] == 9:
				var choice = randi() % 2
				
				if choice == 0:
					walkers[i] = [walkers[i][0] + 1,9]
					dir = 'straight'
				else:
					walkers[i] = [walkers[i][0] + 1,8]
					dir = 'up'
			else:
				var choice = randi() % 3
				
				if choice == 0:
					walkers[i] = [walkers[i][0] + 1,walkers[i][1] - 1]
					dir = 'up'
				elif choice == 1:
					walkers[i] = [walkers[i][0] + 1,walkers[i][1]]
					dir = 'straight'
				else:
					walkers[i] = [walkers[i][0] + 1,walkers[i][1] + 1]
					dir = 'down'
		
		
		var after_shop = false
		var after_oc = false
		var node_type = ''
		

		
		
		Global.path_nodes[walkers[i]] = []
		Global.path_nodes[prior_node].append(walkers[i])
		
		if not walkers[i] in Global.trail_nodes.keys():
			Global.trail_nodes[walkers[i]] = []
		Global.trail_nodes[walkers[i]].append(prior_node)
		
		
		if (walkers[i][0] + 1) % 7 == 0 or (walkers[i][0] - 1) % 7 == 0:
			after_shop = true
		
		if walkers[i][0] % 7 == 0:
			node_type = 'shop'
		
		else:
			for node in Global.trail_nodes[walkers[i]]:
				if Global.node_types[node] == 'shop':
					after_shop = true
				elif Global.node_types[node] == 'overClocked':
					after_oc = true

				var rand = randi_range(1,70)
				if rand < 21:
					node_type = 'easy'
				elif rand < 41:
					node_type = 'medium'
				elif rand < 51:
					node_type = 'hard'
				elif rand < 61 and not after_oc:
					node_type = 'overClocked'
				elif rand < 71 and not after_shop:
					node_type = 'shop'
				else:
					node_type = 'easy'
					
		
		
		
		
		Global.node_types[walkers[i]] = node_type
		
		match i:
			0:
				path = path1
			1:
				path = path2
			2:
				path = path3
			3:
				path = path4
			4:
				path = path5
			5:
				path = path6
			6: 
				path = path7
				
		draw_path(dir,prior_node,path)
		
	
	for node in Global.node_types.keys():
		if not has_node('PathNodes/' + str(node)):
			draw_node(node)
	
func draw_node(pos: Array):
	var node = load("res://Scenes/map_node.tscn")
	var new_node = node.instantiate()
	new_node.name = str(pos)
	new_node.global_position = Vector2(pos[0] * 80 + 16,pos[1] * 32 + 8)
	
	match Global.node_types[pos]:
		'easy':
			new_node.modulate = Color(0.22, 0.945, 0.0)
		'medium':
			new_node.modulate = Color(0.898, 0.494, 0.0)
		'hard':
			new_node.modulate = Color(0.867, 0.031, 0.0)
		'overClocked':
			new_node.modulate = Color(0.588, 0.0, 0.937)
		'shop':
			new_node.modulate = Color(0.133, 0.722, 1.0)
	
	$PathNodes.add_child(new_node)
	new_node.connect('go_to',_go_to)
	new_node.name = str(pos)

func draw_path(direction,node_coords,path) -> void:
	var coords = [node_coords[0]*5,node_coords[1]*2]
	path.set_cell(Vector2i(coords[0] + 1,coords[1]),1,Vector2i(0,2))
	if direction == 'up':
		path.set_cell(Vector2i(coords[0] + 2,coords[1]),1,Vector2i(1,2))
		path.set_cell(Vector2i(coords[0] + 3,coords[1]),1,Vector2i(2,2))
		path.set_cell(Vector2i(coords[0] + 2,coords[1] - 1),1,Vector2i(1,1))
		path.set_cell(Vector2i(coords[0] + 3,coords[1] - 1),1,Vector2i(2,1))
		path.set_cell(Vector2i(coords[0] + 4,coords[1] - 1),1,Vector2i(3,1))
		path.set_cell(Vector2i(coords[0] + 3,coords[1] - 2),1,Vector2i(2,0))
		path.set_cell(Vector2i(coords[0] + 4,coords[1] - 2),1,Vector2i(3,0))
		path.set_cell(Vector2i(coords[0] + 5,coords[1] - 2),1,Vector2i(0,2))
	elif direction == 'straight':
		path.set_cell(Vector2i(coords[0] + 2,coords[1]),1,Vector2i(0,2))
		path.set_cell(Vector2i(coords[0] + 3,coords[1]),1,Vector2i(0,2))
		path.set_cell(Vector2i(coords[0] + 4,coords[1]),1,Vector2i(0,2))
		path.set_cell(Vector2i(coords[0] + 5,coords[1]),1,Vector2i(0,2))
	elif direction == 'down':
		path.set_cell(Vector2i(coords[0] + 2,coords[1]),1,Vector2i(4,0))
		path.set_cell(Vector2i(coords[0] + 3,coords[1]),1,Vector2i(5,0))
		path.set_cell(Vector2i(coords[0] + 2,coords[1] + 1),1,Vector2i(4,1))
		path.set_cell(Vector2i(coords[0] + 3,coords[1] + 1),1,Vector2i(5,1))
		path.set_cell(Vector2i(coords[0] + 4,coords[1] + 1),1,Vector2i(6,1))
		path.set_cell(Vector2i(coords[0] + 3,coords[1] + 2),1,Vector2i(5,2))
		path.set_cell(Vector2i(coords[0] + 4,coords[1] + 2),1,Vector2i(6,2))
		path.set_cell(Vector2i(coords[0] + 5,coords[1] + 2),1,Vector2i(0,2))
		

func _go_to(pos) -> void:
	if can_move:
		Global.taken_path.append(pos)
		_generate_next_collumn()
		var next_nodes = Global.path_nodes[Global.taken_path[-1]]
		for node in Global.path_nodes.keys():
			if not node in next_nodes:
				get_node('PathNodes/' + str(node)).selectable = false
				get_node('PathNodes/' + str(node)).get_child(0).self_modulate = Color(0.34, 0.34, 0.34)
			else:
				get_node('PathNodes/' + str(node)).selectable = true
				get_node('PathNodes/' + str(node)).get_child(0).self_modulate = Color(1.0, 1.0, 1.0)
		
		if Global.taken_path.size() > 1:
			var direction = ''
			if Global.taken_path[-2][1] > Global.taken_path[-1][1]:
				direction = 'up'
			elif Global.taken_path[-2][1] < Global.taken_path[-1][1]:
				direction = 'down'
			else:
				direction = 'straight'
			draw_path(direction,Global.taken_path[-2],player_path)
		else:
			player_path.set_cell(Vector2i(Global.taken_path[0][0]*5,Global.taken_path[0][1]*2),1,Vector2i(0,2))
			player_path.set_cell(Vector2i(Global.taken_path[0][0]*5 - 1,Global.taken_path[0][1]*2),1,Vector2i(0,2))
		
		Global.map_tile_data = [path1.tile_map_data,path2.tile_map_data,path3.tile_map_data,path4.tile_map_data,path5.tile_map_data,path6.tile_map_data,path7.tile_map_data,player_path.tile_map_data,]
		
		var tween = create_tween()
		tween.tween_property(mask,'custom_minimum_size',Vector2(player_path.get_used_rect().size.x + player_path.get_used_rect().position.x,0) * 16, 1.5)
		$Timer.start()
		can_move = false
		
		destination = 'runner'
		Global.rooms_to_finish = 0
		Global.level_time = 0
		match Global.node_types[pos]:
			'easy':
				Global.rooms_to_finish = 1
				Global.level_time = 25
				Global.difficulty = 'easy'
			'medium':
				Global.rooms_to_finish = 2
				Global.level_time = 60
				Global.difficulty = 'medium'
			'hard':
				Global.rooms_to_finish = 3
				Global.level_time = 80
				Global.difficulty = 'hard'
			'overClocked':
				Global.rooms_to_finish = 4
				Global.level_time = 120
				Global.difficulty = 'overclocked'
			'shop':
				destination = 'shop'
		
		Global.difficulty = Global.node_types[pos]
	


func _on_timer_timeout() -> void:
	can_move = true
	if destination == 'runner':
		emit_signal('swap_to_runner')
	elif destination == 'shop':
		emit_signal('swap_to_shop')
