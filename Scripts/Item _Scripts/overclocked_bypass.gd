extends "res://Scripts/item_parent.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	item_name = 'Overclocked Bypass'
	description = "I hope you know what you're doing, interact with on the map to enter an overclocked stage, afterwards your next move ignores paths"
	rarity = 'rare'
	file = "res://Scenes/Item Scenes/taillight.tscn"
	ID = 8
	radius = 30
