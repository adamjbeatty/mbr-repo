extends "res://Scripts/item_parent.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	item_name = 'Flash Drive'
	description = 'A device designed to store small amounts of data, makes you slightly faster'
	rarity = 'common'
	file = "res://Scenes/Item Scenes/flash_drive.tscn"
	ID = 0
	radius = 30
