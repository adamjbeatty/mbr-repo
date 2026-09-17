extends Node2D


@onready var grab_point = $CursorPoint
@onready var life = $RigidBody2D
@onready var sprite = $RigidBody2D/Sprite2D
@onready var marker = $Marker2D
@onready var pin = $CursorPoint/PinJoint2D

signal dropped

enum states {
	DOCKED,
	ACTIVE,
	RETRIEVABLE,
	LOST
}

var state = states.DOCKED
var is_held = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	life.freeze = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	$Label.global_position = life.global_position + Vector2(-100,75)
	
	if is_held:
		grab_point.global_position = get_global_mouse_position()
	else:
		pass

		
		
	#if Input.is_action_just_released('Click') and is_held == true:
		#z_index = 0
		#emit_signal('dropped')
		#is_held = false
		#pin.node_a = NodePath("")
		#grab_point.global_position = marker.global_position
		#await get_tree().physics_frame
		#life.freeze = true
		#
	#
	#
	#if Input.is_action_just_pressed("Click") and get_global_mouse_position().distance_to(life.global_position) < 80 and state in [states.DOCKED,states.RETRIEVABLE]:
		#z_index = 1
		#life.freeze = false
		#grab_point.global_position = get_global_mouse_position()
		#pin.node_a = life.get_path()
		#get_viewport().set_input_as_handled()
		#is_held = true
		
func go_to(pos):
	life.teleport = true
	life.target_pos = pos


func _on_button_l_click() -> void:
	if state in [states.DOCKED,states.RETRIEVABLE]:
		z_index = 1
		life.freeze = false
		grab_point.global_position = get_global_mouse_position()
		pin.node_a = life.get_path()
		get_viewport().set_input_as_handled()
		is_held = true


func _on_button_r_click() -> void:
	pass # Replace with function body.


func _on_button_release() -> void:
	if is_held:
		z_index = 0
		emit_signal('dropped')
		is_held = false
		pin.node_a = NodePath("")
		grab_point.global_position = marker.global_position
		await get_tree().physics_frame
		life.freeze = true
