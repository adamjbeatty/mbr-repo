extends Button

signal l_click
signal r_click
signal release

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal('l_click')
		else:
			emit_signal('r_click')
	elif event is InputEventMouseButton and event.is_released():
		if event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal('release')
