extends CanvasLayer

var active = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc") and get_tree().current_scene.scene_file_path == "res://Scenes/main_2.tscn":
		pause()

func pause():
	active = !active
	visible = !visible
	layer *= -1
	get_tree().paused = !get_tree().paused



func _on_resume_pressed() -> void:
	pause()
func _on_resume_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($Control/VBoxContainer/Panel/Label,'scale',Vector2(1.5,1.5),.15)
func _on_resume_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($Control/VBoxContainer/Panel/Label,'scale',Vector2(1,1),.15)



func _on_settings_pressed() -> void:
	pass # Replace with function body.
func _on_settings_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($Control/VBoxContainer/Panel2/Label,'scale',Vector2(1.5,1.5),.15)
func _on_settings_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($Control/VBoxContainer/Panel2/Label,'scale',Vector2(1,1),.15)



func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	pause()
func _on_exit_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($Control/VBoxContainer/Panel4/Label,'scale',Vector2(1.5,1.5),.15)
func _on_exit_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($Control/VBoxContainer/Panel4/Label,'scale',Vector2(1,1),.15)
