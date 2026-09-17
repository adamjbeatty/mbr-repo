extends "res://Scripts/item_parent.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	item_name = 'Broken Taillight'
	description = "Should've checked their mirrors, move faster when moving backwards in the air"
	rarity = 'uncommon'
	file = "res://Scenes/Item Scenes/taillight.tscn"
	ID = 6
	radius = 30
