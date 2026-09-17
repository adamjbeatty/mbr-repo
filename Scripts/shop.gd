extends Control

@onready var marker_list = [$ShopMarkers/Marker2D,$ShopMarkers/Marker2D2,$ShopMarkers/Marker2D3,
							$ShopMarkers/Marker2D4,$ShopMarkers/Marker2D5,$ShopMarkers/Marker2D6,
							$ShopMarkers/Marker2D7,$ShopMarkers/Marker2D8,$ShopMarkers/Marker2D9]
@onready var label_list = [$Menu/Labels/Label,$Menu/Labels/Label2,$Menu/Labels/Label3,
							$Menu/Labels/Label4,$Menu/Labels/Label5,$Menu/Labels/Label6,
							$Menu/Labels/Label7,$Menu/Labels/Label8,$Menu/Labels/Label9]
@onready var items = $Items
@onready var cart = $Cart
@onready var menu = $Menu

var shop_items = []
var hardware = []
var items_in_cart = []
var next_free_marker = 0
var dropped = false

signal swap_to_map
signal add_item(file)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	menu.global_position = floor(menu.global_position)
	
	
	
	var common = []
	var uncommon = []
	var rare = []
	for i in range(8):
		var rand = randi() % 10 + 1
		if rand <= 5:
			common.append(Global.common_items.pick_random())
		elif rand <= 9:
			uncommon.append(Global.uncommon_items.pick_random())
		else:
			rare.append(Global.rare_items.pick_random())
	
	for list in [common, uncommon, rare]:
		for item in list:
			shop_items.append(load(item))
	
	
	hardware = Global.hardware.pick_random()
	
	for item in shop_items:
		if not item is String:
			var new_item = item.instantiate()
			new_item.connect('dropped',item_dropped)
			new_item.global_position = marker_list[next_free_marker].global_position
			items.add_child(new_item,true)
			var cost = 0
			match new_item.rarity:
				'common':
					cost = int(8000 * randf_range(1.3,.8))
				'uncommon':
					cost = int(14000 * randf_range(1.3,.8))
				'rare':
					cost = int(25000 * randf_range(1.3,.8))
			new_item.price = cost
			new_item.shop_slot = next_free_marker
			label_list[next_free_marker].text = str(cost)
			next_free_marker += 1
			new_item.show_behind_parent = true
			
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func item_dropped():
	var active_item
	for item in items.get_children():
		if item.is_held:
			active_item = item
	
	if get_global_mouse_position().distance_to(cart.global_position) < 50:
		await get_tree().physics_frame
		if Global.bits > active_item.price:
			Global.bits -= active_item.price
			emit_signal('add_item',active_item.file)
			var label = label_list[active_item.shop_slot]
			label.text = 'Sold'
			label.position.y -= 15
			label.scale = Vector2(1.75,1.75)
			label.rotation_degrees += randi_range(-15,15)
			active_item.queue_free()
		else:
			active_item.item.freeze = true
			active_item.item.global_position = active_item.global_position
			active_item.item.rotation = 0
	else:
		active_item.item.freeze = true
		active_item.item.global_position = active_item.global_position
		active_item.item.rotation = 0
			


func _on_texture_button_pressed() -> void:
	emit_signal('swap_to_map')
