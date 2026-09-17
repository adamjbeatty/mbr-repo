extends CanvasLayer

@onready var animation = $AnimationPlayer

func _on_start_pressed() -> void:
	LoadingTool.load_scene('uid://ddpdou6icym4n')


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_encyclopedia_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_timer_timeout() -> void:
	animation.play("Slide_In")


func _on_start_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($Node2D/Control2/MarginContainer/VBoxContainer/Panel/Label,'scale',Vector2(1.5,1.5),.15)
func _on_start_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($Node2D/Control2/MarginContainer/VBoxContainer/Panel/Label,'scale',Vector2(1,1),.15)


func _on_settings_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($Node2D/Control2/MarginContainer/VBoxContainer/Panel2/Label,'scale',Vector2(1.5,1.5),.15)
func _on_settings_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($Node2D/Control2/MarginContainer/VBoxContainer/Panel2/Label,'scale',Vector2(1,1),.15)


func _on_encyclopedia_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($Node2D/Control2/MarginContainer/VBoxContainer/Panel3/Label,'scale',Vector2(1.5,1.5),.15)
func _on_encyclopedia_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($Node2D/Control2/MarginContainer/VBoxContainer/Panel3/Label,'scale',Vector2(1,1),.15)


func _on_quit_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($Node2D/Control2/MarginContainer/VBoxContainer/Panel5/Label,'scale',Vector2(1.5,1.5),.15)
func _on_quit_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($Node2D/Control2/MarginContainer/VBoxContainer/Panel5/Label,'scale',Vector2(1,1),.15)
