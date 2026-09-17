extends "res://Scripts/item_parent.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	item_name = 'Fan'
	description = 'A little chilly, makes you fall slower'
	rarity = 'common'
	file = "res://Scenes/Item Scenes/fan.tscn"
	ID = 3
	radius = 30
