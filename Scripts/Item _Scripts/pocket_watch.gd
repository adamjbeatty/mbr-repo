extends "res://Scripts/item_parent.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	item_name = 'Pocket Watch'
	description = "Always on time, gives a little extra time to finish level after timing out"
	rarity = 'uncommon'
	file = "res://Scenes/Item Scenes/pocket_watch.tscn"
	ID = 4
	radius = 30
