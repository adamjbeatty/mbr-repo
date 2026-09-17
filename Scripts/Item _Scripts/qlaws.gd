extends "res://Scripts/item_parent.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	item_name = 'Qlaws'
	description = "Always thought they looked a little pointy, greatly reduces wall sliding gravity, can go negative"
	rarity = 'uncommon'
	file = "res://Scenes/Item Scenes/taillight.tscn"
	ID = 5
	radius = 30
