extends Node2D

var layout = []
var rows = 0
var collumns = 0
var cur_row = 0
var cur_collumn = 0
var current_hbox
var choices = []
var path = ''
var first_level = true
var first_spawn = true
var following_player = false
var zoomed = true


@onready var player = $Runner
@onready var mask = $Mask
@onready var para = $Mask/Parallax2D
@onready var rect = $ColorRect
@onready var cam = $Camera2D2
@onready var timer = $LevelTimer

#---Tile-Map-Layers-------------------------------------------------------------

@onready var hazards: TileMapLayer = $TileMapLayers/Hazards
@onready var ground: TileMapLayer = $TileMapLayers/Ground
@onready var ground_fill: TileMapLayer = $TileMapLayers/GroundFill
@onready var pits: TileMapLayer = $TileMapLayers/Pits

@onready var play_space_bg = $Mask/Parallax2D/Node2D/ColorRect
@onready var primary_bg1 = $Mask/Parallax2D/Node2D/BG
@onready var primary_bg2 = $Mask/Parallax2D/Node2D/BG2
@onready var bg_fill = $Mask/Parallax2D/Node2D/BG/BGFill

signal swap_to_map()
#signal swap_to_shop()
signal retrieve_life()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.sprite.visible = false
	cam.zoom = Vector2(.5,.5)
	timer.wait_time = Global.level_time
	first_level = true
	_generate_new_level(Global.difficulty,null,null,null,null,null,null)
	var top_left = ground_fill.get_used_rect().position * 16
	var bottom_right = ground_fill.get_used_rect().size * 16
	cam.global_position = top_left + (bottom_right / 2) + Vector2i(100,20)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if following_player:
		cam.global_position = player.global_position

		
		if Input.is_action_just_released("shift"):
			if zoomed:
				var tween = create_tween()
				tween.tween_property(cam,'zoom',Vector2(1,1),.5)
				tween.parallel().tween_property(cam,'offset',Vector2(80,62),.5)
				zoomed = false
			else:
				var tween = create_tween()
				tween.tween_property(cam,'zoom',Vector2(2,2),.5)
				tween.parallel().tween_property(cam,'offset',Vector2(40,31),.5)
				zoomed = true
		
	

func _generate_new_level(difficulty: String, bg_decal_color, bg_decal_fill_color, bg_color, ground_color, ground_fill_color, hazard_color) -> void:
	
	ground.clear()
	ground_fill.clear()
	hazards.clear()
	pits.clear()
	
	var ground_colors = []
	var hazard_colors = []
	
	match difficulty:
		'easy':
			layout = Global.easyLayouts.pick_random()
			ground_colors = Global.easy_colors
			hazard_colors = Global.easy_hazard
		'medium':
			layout = Global.mediumLayouts.pick_random()
			ground_colors = Global.med_colors
			hazard_colors = Global.med_hazard
		'hard':
			layout = Global.hardLayouts.pick_random()
			ground_colors = Global.hard_colors
			hazard_colors = Global.hard_hazard
		'overClocked':
			layout = Global.overclockedLayouts.pick_random()
			ground_colors = Global.oc_colors
			hazard_colors = Global.oc_hazard
	
	rows = len(layout)
	collumns = len(layout[0])
	
	
	for i in range(rows):
		cur_row = i
		for j in range(collumns):
			cur_collumn = j
			_add_room(layout[i][j])
	
	await get_tree().process_frame
	
	var temp_color
	
	temp_color = ground_colors.pick_random()
	rect.modulate = temp_color
	ground_fill.modulate = temp_color
	ground.modulate = ground_colors.pick_random()
	
	temp_color = ground_colors.pick_random()
	primary_bg1.modulate = temp_color
	primary_bg2.modulate = temp_color
	bg_fill.modulate = Color(0.662, 0.662, 0.662)
	play_space_bg.modulate = ground_colors.pick_random()
	
	hazards.modulate = hazard_colors.pick_random()
	
	
	mask.size = Vector2(ground_fill.get_used_rect().size.x,ground_fill.get_used_rect().size.y) * Vector2(16,16)
	
	
	var y = (ground_fill.get_used_rect().position + ground_fill.get_used_rect().size).y - 1
	for x in range((ground_fill.get_used_rect().position + ground_fill.get_used_rect().size).x):
		if ground_fill.get_cell_source_id(Vector2i(x,y)) == -1:
			for i in range(9):
				pits.set_cell(Vector2i(x,y+1+i),0,Vector2i(20,8),0)
			pits.set_cell(Vector2i(x,y),0,Vector2i(17,4),0)
			
	
	var in_pit = false
	for x in range((ground_fill.get_used_rect().position + ground_fill.get_used_rect().size).x):
		if in_pit:
			if pits.get_cell_source_id(Vector2i(x,y)) == -1:
				in_pit = false
				for i in range(9):
					ground.set_cell(Vector2i(x,y+1+i),0,Vector2i(0,1))
				
		else:
			if pits.get_cell_source_id(Vector2i(x,y)) != -1:
				in_pit = true
				for i in range(9):
					ground.set_cell(Vector2i(x-1,y+1+i),0,Vector2i(2,1))
				

	
	var map_end_points = ground.get_used_cells_by_id(0, Vector2i(11,0))
	var end_points = []
	
	for i in range(map_end_points.size()):
		end_points.append(ground.to_global(ground.map_to_local(map_end_points[i])))
	
	var start_USB = end_points.pop_at(randi() % end_points.size())
	Global.start_pos = start_USB
	Global.end_pos = end_points[0]
	
	if not first_level:
		_on_runner_respawn_player()
	
	#var top_left = (ground_fill.get_used_rect().position) * Vector2i(16,16)
	#var bottom_right = (ground_fill.get_used_rect().position + ground.get_used_rect().size) * Vector2i(16,16)
	
	#cam.limit_left = top_left.x - 75
	#cam.limit_top = top_left.y - 75
	#cam.limit_right = bottom_right.x + 75
	#cam.limit_bottom = bottom_right.y + 75
			

func _add_room(type) -> void:
	
	var room
	
	if type != null:
		match type:
			'horizontal':
				path = "res://Rooms/Horizontal/"
			'vertical':
				path = "res://Rooms/Vertical/"
			'cross':
				path = "res://Rooms/Cross/"
			'elbow_br':
				path = "res://Rooms/BR_Elbow/"
			'elbow_bl':
				path = "res://Rooms/BL_Elbow/"
			'elbow_tr':
				path = "res://Rooms/TR_Elbow/"
			'elbow_tl':
				path = "res://Rooms/TL_Elbow/"
			'T_right':
				path = "res://Rooms/T_Right/"
			'T_bottom':
				path = "res://Rooms/T_Bottom/"
			'T_left':
				path = "res://Rooms/T_Left/"
			'T_top':
				path = "res://Rooms/T_Top/"
			'right_end':
				path = "res://Rooms/R_End/"
			'bottom_end':
				path = "res://Rooms/B_End/"
			'left_end':
				path = "res://Rooms/l_End/"
			'top_end':
				path = "res://Rooms/T_End/"
		
		choices = DirAccess.get_files_at(path)
		choices = Array(choices)
		
		var pick = path + choices.pick_random()
		
		room = load(pick)
		
	else:
		room = load("res://Rooms/Blank.tscn")
		
		
	
	var new_room = room.instantiate()
	
	var hazard_set = new_room.get_child(0)
	var g_fill_set = new_room.get_child(1)
	var ground_set = new_room.get_child(2)
		
	merge_layers(hazard_set, hazards)
	merge_layers(g_fill_set, ground_fill)
	merge_layers(ground_set, ground)
	
	new_room.queue_free()
		

func _on_runner_respawn_player() -> void:
	player.spawn_start(Global.start_pos)
	if first_spawn:
		var tween = create_tween()
		tween.tween_property(cam,'zoom',Vector2(2,2),2)
		tween.parallel().tween_property(cam,'global_position',player.global_position,2)
		first_spawn = false


func _on_runner_new_level() -> void:
	first_level = false
	Global.rooms_to_finish -= 1
	if Global.rooms_to_finish <= 0:
		timer.paused = true
		emit_signal('retrieve_life')
	else:
		_generate_new_level(Global.difficulty,null,null,null,null,null,null)


func merge_layers(source, target) -> void:
	var used_tiles = source.get_used_cells()
	
	for cell in used_tiles:
		var source_id = source.get_cell_source_id(cell)
		var atlas_coords = source.get_cell_atlas_coords(cell)
		var alternative_tile = source.get_cell_alternative_tile(cell)
		
		target.set_cell(Vector2i(cell.x + 8 * cur_collumn, cell.y + 8 * cur_row), source_id, atlas_coords, alternative_tile)
	

func pause_timer() -> void:
	timer.paused = true
	
	
func resume_timer() -> void:
	timer.paused = false


func _on_level_timer_timeout() -> void:
	Global.lives -= 1
	emit_signal('swap_to_map')


func _on_runner_spawn_complete() -> void:
	resume_timer()
	following_player = true
	player.sprite.visible = true
