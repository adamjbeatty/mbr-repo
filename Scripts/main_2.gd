extends Control


@onready var map_scene = $SubViewportContainer2/SubViewport/Map
@onready var runner_scene: Node2D
@onready var shop_scene: Control
@onready var mini_viewport = $SubViewportContainer2/SubViewport
@onready var level_timer
@onready var overlay_scene = $SubViewportContainer/SubViewport/CanvasLayer
@onready var upload = $UploadAnimation
@onready var life1 = $DraggableSprites/LifeObject
@onready var life2 = $DraggableSprites/LifeObject2
@onready var life3 = $DraggableSprites/LifeObject3
@onready var drag_parent = $DraggableSprites
@onready var upload_hotspot = $HotSpots/UploadMarker
@onready var upload_bg = $UploadBG
@onready var global_timer = $GTimerLabel
@onready var level_timer_label = $TimerLabel
@onready var level_timer_title = $Text/Label3
@onready var bit_counter = $BitLabel
@onready var inventory = $InventoryItems
@onready var popup_pos = $PopupPositioner
@onready var popup = $PopupPositioner/Popup
@onready var popup_text = $PopupPositioner/Popup/MarginContainer/Label
@onready var tt_title = $ToolTitleLabel
@onready var tt_body = $ToolTitleBody
@onready var transition_box = $Panel
@onready var transition = $AnimationPlayer
@onready var hint_timer = $HintTimer


enum game_states {
	LEVEL,
	UPLOAD,
	RETRIEVE,
	MAP,
	SHOP
}

var state = game_states.MAP
var popup_active = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	give_item("res://Scenes/Item Scenes/fan.tscn")
	
	_on_hint_timer_timeout()
	overlay_scene.timer_box.visible = false
	level_timer_label.visible = false
	level_timer_title.visible = false
	update_bits()
	map_scene.connect('swap_to_runner',_on_map_swap_to_runner)
	Global.game_active = true
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Click"):
		if popup_active:
			popup_pos.visible = false
			popup_active = false
	
	if level_timer != null:
		var minutes = int(level_timer.time_left / 60)
		var seconds = int(level_timer.time_left) % 60
		var sub_seconds = snapped(fmod(level_timer.time_left,1.0),.01)
		
		if minutes < 10:
			minutes = '0' + str(minutes)
		else:
			minutes = str(minutes)
		
		if seconds < 10:
			seconds = '0' + str(seconds)
		else:
			seconds = str(seconds)
		
		sub_seconds = ('%.2f' % sub_seconds).substr(2) 
	
		
		level_timer_label.text = minutes + ':' + seconds + '.' + sub_seconds
	else:
		level_timer_label.text = '00:00.00'
	
	var minutes = int(Global.global_time / 60)
	var seconds = int(Global.global_time) % 60
	var sub_seconds = snapped(fmod(Global.global_time,1.0),.01)
	
	if minutes < 10:
		minutes = '0' + str(minutes)
	else:
		minutes = str(minutes)
		
	if seconds < 10:
		seconds = '0' + str(seconds)
	else:
		seconds = str(seconds)
		
	sub_seconds = ('%.2f' % sub_seconds).substr(2) 
	
	global_timer.text = minutes + ':' + seconds# + '.' + sub_seconds
	

func _on_map_swap_to_runner() -> void:
	transition.play("fade")
	await transition.animation_finished
	
	level_timer_label.visible = true
	level_timer_title.visible = true
	overlay_scene.timer_box.visible = true
	state = game_states.UPLOAD
	var level = load("res://Scenes/Main.tscn")
	var new_level = level.instantiate()
	mini_viewport.add_child(new_level)
	runner_scene = new_level
	level_timer = runner_scene.get_child(-1)
	map_scene.queue_free()
	runner_scene.connect('swap_to_map',_on_runner_swap_to_map)
	runner_scene.connect('retrieve_life',retrieve_life)
	Global.calculate_stats()
	
	upload_bg.visible = true
	upload.visible = true
	
	transition.play_backwards("fade")

func _on_map_swap_to_shop() -> void:
	transition.play("fade")
	await transition.animation_finished
	
	state = game_states.SHOP
	var shop = load('res://Scenes/shop.tscn')
	var new_shop = shop.instantiate()
	#mini_viewport.add_child(new_shop)
	$".".add_child(new_shop)
	new_shop.z_index = -1
	shop_scene = new_shop
	map_scene.queue_free()
	shop_scene.connect('swap_to_map',_on_shop_swap_to_map)
	shop_scene.connect('add_item',give_item)
	
	for item in shop_scene.items.get_children():
		item.connect('inspected',_text_popup)
	
	transition.play_backwards("fade")
	
func _on_shop_swap_to_map() -> void:
	transition.play("fade")
	await transition.animation_finished
	
	state = game_states.MAP
	var map = load("res://Scenes/map.tscn")
	var new_map = map.instantiate()
	mini_viewport.add_child(new_map)
	map_scene = new_map
	shop_scene.queue_free()
	map_scene.connect('swap_to_runner',_on_map_swap_to_runner)
	map_scene.connect('swap_to_shop',_on_map_swap_to_shop)
	
	transition.play_backwards("fade")
	
func _on_runner_swap_to_map() -> void:
	transition.play("fade")
	await transition.animation_finished
	
	level_timer_label.visible = false
	level_timer_title.visible = false
	overlay_scene.timer_box.visible = false
	state = game_states.MAP
	
	var reward = 0
	match Global.difficulty:
		'easy':
			reward = 1000 + int(level_timer.time_left * 100)
		'medium':
			reward = 1500 + int(level_timer.time_left * 150)
		'hard':
			reward = 3000 + int(level_timer.time_left * 250)
		'overClocked':
			reward = 10000 + int(level_timer.time_left * 500)
	Global.bits += reward
	update_bits()
	
	var map = load("res://Scenes/map.tscn")
	var new_map = map.instantiate()
	mini_viewport.add_child(new_map)
	map_scene = new_map
	runner_scene.queue_free()
	map_scene.connect('swap_to_runner',_on_map_swap_to_runner)
	map_scene.connect('swap_to_shop',_on_map_swap_to_shop)
	
	for object in drag_parent.get_children():
		if object.state == object.states.ACTIVE:
			object.queue_free()
	
	transition.play_backwards("fade")

func retrieve_life() -> void:
	state = game_states.RETRIEVE
	upload_bg.visible = true
	var active_object
	for object in drag_parent.get_children():
		if object.state == object.states.ACTIVE:
			active_object = object
			active_object.state = active_object.states.RETRIEVABLE
			active_object.visible = true
	
	
	


func _on_life_object_dropped() -> void:
	var active_object
	for object in drag_parent.get_children():
		if object.is_held:
			active_object = object
	
	match active_object.state:
		active_object.states.DOCKED:
			if state == game_states.UPLOAD and upload_hotspot.global_position.distance_to(get_global_mouse_position()) < 100:
				state = game_states.LEVEL
				runner_scene._on_runner_respawn_player()
				upload.visible = false
				upload_bg.visible = false
				active_object.visible = false
				active_object.state = active_object.states.ACTIVE
				active_object.marker.global_position = Vector2(577,301)
				active_object.go_to(active_object.marker.global_position)
				level_timer.start()
			else:
				active_object.go_to(active_object.global_position)
		active_object.states.RETRIEVABLE:
			if state == game_states.RETRIEVE and active_object.global_position.distance_to(get_global_mouse_position()) < 100:
				state = game_states.MAP
				_on_runner_swap_to_map()
				upload_bg.visible = false
				active_object.state = active_object.states.DOCKED
				active_object.go_to(active_object.global_position)
			else:
				active_object.go_to(active_object.marker.global_position)
				
		
func give_item(file):
	update_bits()
	var item = load(file)
	var new_item = item.instantiate()
	new_item.state = new_item.states.INVENTORY
	new_item.global_position = Vector2(1345,508)
	inventory.add_child(new_item)
	new_item.connect('inspected',_text_popup)
	Global.inventory.append(new_item.ID)
	new_item.go_to(new_item.global_position)

func _text_popup(name, text) -> void:
	hint_timer.start()
	
	#tt_title.visible_ratio = 0
	#tt_body.visible_ratio = 0
	
	tt_title.text = name
	tt_body.text = text
	
	var tween = create_tween()
	tween.tween_property(tt_title,'visible_ratio',1.0,.5).from(0.0)
	tween.parallel().tween_property(tt_body,'visible_ratio',1.0,3.0).from(0.0)
	
	

func update_bits():
	var tween = create_tween()
	tween.tween_method(set_bits,int(bit_counter.text),Global.bits,2.0)

func set_bits(value):
	bit_counter.text = str(value)


func _on_hint_timer_timeout() -> void:
	print('timeout')
	var random = randi_range(0,Global.hints.keys().size())
	
	var title = Global.hints.keys()[random]
	var text = Global.hints.values()[random]
	
	#tt_title.visible_ratio = 0
	#tt_body.visible_ratio = 0
	
	tt_title.text = title
	tt_body.text = text
	
	var tween = create_tween()
	tween.tween_property(tt_title,'visible_ratio',1.0,.5).from(0.0)
	tween.parallel().tween_property(tt_body,'visible_ratio',1.0,3.0).from(0.0)
