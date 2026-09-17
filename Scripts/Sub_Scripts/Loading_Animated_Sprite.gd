extends AnimatedSprite2D


var waiting = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if not waiting:
		waiting = true
		
		await get_tree().create_timer(randf_range(2,7)).timeout
		self.animation = 'Jump'
		var tween = create_tween()
		
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self,'position:y',randi_range(-75,-200),.5)
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(self,'position:y',0,.5)
		tween.tween_callback(tween_finished)


func tween_finished() -> void:
	waiting = false
	self.animation = 'default'
