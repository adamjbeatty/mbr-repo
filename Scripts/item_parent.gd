extends Node2D

@onready var grab_point = $CursorPoint
@onready var item = $Item
@onready var sprite = $Item/AnimatedSprite2D
@onready var pin = $CursorPoint/PinJoint2d
@onready var collider = $Item/CollisionShape2D
@onready var click_area = $Item/Button

signal dropped
signal inspected(name,desc)

var item_name: String
var description: String
var rarity: String
var file: String
var ID: int
var price: int
var shop_slot: int
var radius: int

var selectable = true

enum states {
	PICKABLE,
	INVENTORY,
}

var state = states.PICKABLE
var is_held = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = floor(global_position)
	
	if state == states.PICKABLE:
		sprite.scale = Vector2(1,1)
		collider.scale = Vector2(1,1)
		click_area.scale = Vector2(1,1)
		item.freeze = true
	else:
		pin.node_a = NodePath("")
		item.gravity_scale = 0
		sprite.scale = Vector2(4,4)
		collider.scale = Vector2(4,4)
		click_area.scale = Vector2(4,4)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if is_held:
		z_index = 1
		grab_point.global_position = get_global_mouse_position()
	else:
		z_index = 0
		
		

func go_to(pos):
	item.teleport = true
	item.target_pos = pos
	grab_point.global_position = pos





func _on_button_l_click() -> void:
	if selectable:
		item.set_collision_layer_value(6, false)
		item.set_collision_mask_value(6, false)
		item.freeze = false
		item.gravity_scale = 5
		grab_point.global_position = get_global_mouse_position()
		pin.node_a = item.get_path()
		is_held = true


func _on_button_r_click() -> void:
	emit_signal('inspected', item_name, description)


func _on_button_release() -> void:
	if is_held:
		item.set_collision_layer_value(6, true)
		item.set_collision_mask_value(6, true)
		item.gravity_scale = 0
		emit_signal('dropped')
		is_held = false
		if not state == states.PICKABLE:
			pin.node_a = NodePath("")
