extends Node2D

var selectable = false

signal go_to(pos)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.name = '[2,4]'


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_2d_mouse_entered() -> void:
	if selectable:
		var tween = create_tween()
		tween.tween_property(self,'scale',Vector2(1.5,1.5),.1)


func _on_area_2d_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self,'scale',Vector2(1,1),.1)


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if selectable:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				emit_signal("go_to", JSON.parse_string(self.name).map(func(value): return int(value)))
