extends CanvasLayer

signal finished

var progress = []
var loading_screen: PackedScene = preload('uid://cue72soq3uipn')
var loaded_scene: PackedScene
var scene_path: String

func _ready() -> void:
	set_process(false)

func load_scene(path) -> void:
	scene_path = path
	
	var new_load_screen = loading_screen.instantiate()
	add_child(new_load_screen)
	finished.connect(new_load_screen._on_load_finished)
	
	await new_load_screen.loading_screen_ready
	
	start_load()

func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, '', true)
	if state == OK:
		set_process(true)
		
func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(scene_path,progress)
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_scene = ResourceLoader.load_threaded_get(scene_path)
			get_tree().change_scene_to_packed(loaded_scene)
			finished.emit()
