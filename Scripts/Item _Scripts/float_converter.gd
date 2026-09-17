extends "res://Scripts/item_parent.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	item_name = 'Float Converter'
	description = 'Turns numbered variables into floats, makes you jump higher'
	rarity = 'common'
	file = "res://Scenes/Item Scenes/float_converter.tscn"
	ID = 1
	radius = 10
