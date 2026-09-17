extends "res://Scripts/item_parent.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	item_name = 'Tungsten Cube'
	description = 'Rediculously heavy, fall faster when holding down'
	rarity = 'common'
	file = "res://Scenes/Item Scenes/tungston_cube.tscn"
	ID = 2
	radius = 18
