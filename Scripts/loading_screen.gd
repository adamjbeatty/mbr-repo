extends CanvasLayer

signal loading_screen_ready

@export var animation: AnimationPlayer

func _ready() -> void:
	await animation.animation_finished
	loading_screen_ready.emit()

func _on_load_finished() -> void:
	animation.play_backwards('Fade')
	await animation.animation_finished
	queue_free()
