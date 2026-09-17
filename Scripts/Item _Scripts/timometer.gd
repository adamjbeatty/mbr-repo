extends "res://Scripts/item_parent.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	item_name = 'Timometer'
	description = "Pretty sure that's just what a clock is, lose less bits from getting lower times"
	rarity = 'uncommon'
	file = "res://Scenes/Item Scenes/taillight.tscn"
	ID = 7
	radius = 30
