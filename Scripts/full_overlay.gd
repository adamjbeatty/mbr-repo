extends CanvasLayer

@onready var timer_box = $VBoxContainer/NinePatchRect/TimerBox

func _create_popup(pos,width,height,opacity,name,top_layer) -> void:
	var nine_patch = NinePatchRect.new()
	var fill = NinePatchRect.new()
	var current_object
	for i in range(2):
		if i == 1:
			current_object = nine_patch
			nine_patch.texture = load("res://Assets/Tab_Box_Outline.tres")
			nine_patch.modulate = Color(1.0, 1.0, 1.0, opacity)
		else:
			current_object = fill
			fill.texture = load("res://Assets/Tab_Box_Fill.tres")
			fill.modulate = Color(0.478, 0.478, 0.478, opacity)
	
		current_object.patch_margin_left = 16
		current_object.patch_margin_top = 16
		current_object.patch_margin_right = 16
		current_object.patch_margin_bottom = 16
		
		current_object.position = pos
		current_object.custom_minimum_size = Vector2(width,height)
		
		current_object.name = name
		if top_layer:
			current_object.z_index = 3
		else:
			current_object.z_index = -1
		
		add_child(current_object,true)


func _clear_popup(_name) -> void:
	for object in get_children():
		if object.name.substr(0,name.length()) == _name:
			object.queue_free()
	
	
