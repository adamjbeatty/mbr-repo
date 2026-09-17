extends Node

var bits = 0
var lives = 3

#Variable player stats
var speed = 80
var jump_time = .35
var slow_fall_cap = 160
var fast_fall_cap = 160
var wall_slide = 1
var bonus_time = 0
var reverse_boost = 0



var start_pos
var end_pos

var runner: PackedScene = preload("res://Scenes/Runner.tscn")


var rooms_to_finish = 0
var difficulty = 'easy'
var level_time = 0
var game_active = false
var global_time = 0
var inventory = []

#-hint-popups-------------------------------------------------------------------
var hints = {
	'Falling':"certain items allow you to fall at two different speeds, a fast fall when you hold down, and a slower fall when you don't.",
	'Wall Sliding':"Want to go down but keep sticking to walls? Holding down will disable wall clinging allowing you to effortlessly free fall.",
	'Bits':"You get more bits the faster you finish a level!",
	'Lives':"There is no penalty to striking hazards outside of respawning at the start of the level, you only lose lives to timing out.",
	'Shops':"There will always be a shop every 7 nodes but you can encounter more outside of that pattern, make sure you have the bits for them!",
	'Level Count':'easy levels will always have 1 stage, medium 2, hard 3, and overclocked 4.',
	'Difficulty Scaling':"The farther you get into a run the less time you have for each level, make sure you have a good build to complete them in time.",
	'Global Timer':"In the default mode the global timer has almost no effect on gameplay, it simply serves to track the length of your run.",
	'Unique Items':"Some items can only be aquired once because their effect would not work when stacking or would be too strong to stack."
}


#---Map-Data--------------------------------------------------------------------
var map_tile_data = []

var taken_path = []
var path_nodes = {}
var trail_nodes = {}
var node_types = {}

var walkers = [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]]
#-Colors------------------------------------------------------------------------
var preset_colors = {
	'green':Color(0.0, 0.756, 0.192),
	'blue':Color(0.1, 0.338, 1.0),
	'teal':Color(0.0, 1.0, 1.0),
	'red':Color(0.843, 0.0, 0.0),
	'purple':Color(0.572, 0.0, 0.572),
	'yellow':Color(0.937, 0.855, 0.0),
	'orange':Color(1.0, 0.231, 0.0),
	'white':Color(1.0, 1.0, 1.0),
	'grey':Color(.25, .25, .25),
	'dark green':Color(0.0, 0.204, 0.0),
	'dark blue':Color(0.0, 0.0, 0.424),
	'dark red':Color(0.275, 0.0, 0.0),
	'dark purple':Color(0.221, 0.0, 0.221),
	'dark yellow':Color(0.216, 0.216, 0.0),
	'dark orange':Color(0.407, 0.071, 0.0)
	
	}

#-Easy-----
var easy_colors = [preset_colors['blue'],preset_colors['white'],preset_colors['green'],preset_colors['teal']]
var easy_hazard = [preset_colors['green'],preset_colors['red'],preset_colors['blue'],preset_colors['orange']]
#-Medium---
var med_colors = [preset_colors['blue'],preset_colors['dark green'],preset_colors['orange'],preset_colors['yellow']]
var med_hazard = [preset_colors['green'],preset_colors['red'],preset_colors['purple'],preset_colors['orange'],preset_colors['grey']]
#-hard-----
var hard_colors = [preset_colors['red'],preset_colors['dark orange'],preset_colors['purple'],preset_colors['grey'],preset_colors['dark red']]
var hard_hazard = [preset_colors['white'],preset_colors['red'],preset_colors['purple'],preset_colors['orange'],preset_colors['grey'],preset_colors['dark blue'],preset_colors['dark orange']]
#-Overclocked-
var oc_colors = [preset_colors['red'],preset_colors['purple'],preset_colors['dark blue'],preset_colors['grey'],preset_colors['dark red']]
var oc_hazard = [preset_colors['white'],preset_colors['dark red'],preset_colors['dark purple'],preset_colors['dark orange'],preset_colors['grey'],preset_colors['dark blue']]

#Possible room layouts and codes:
#                   |
#        ---        |  Horizontal
#                   |
#         |         |
#         |         |  Vertical
#         |         |
#                   |
#         |         |
#       --+--       |  Cross
#         |         |
#                   |
#         ---       |
#        |          |  Elbow_br
#        |          |  (bl,tr,tl)
#                   |
#      -----        |
#        |          |  T_bottom
#        |          |  (right,top,left)
#                   |
#       X--         |  left_end
#                   |  (top,left,bottom)
#                   |  



var easyLayouts = [
	[['left_end', 'T_bottom', 'horizontal', 'right_end',]],
	
	[['elbow_br', 'right_end'],
	 ['elbow_tr', 'elbow_bl'],
	 ['left_end', 'elbow_tl']],
	
	 [[null, null, 'elbow_br', 'right_end'],
	 ['left_end', 'T_bottom', 'elbow_tl', null]],
	
	[['top_end','top_end'],
	 ['elbow_tr','elbow_tl']],
	
	[['top_end'],
	 ['vertical'],
	 ['bottom_end']],
]

var mediumLayouts = [
	
	[['elbow_br','horizontal','horizontal','elbow_bl'],
	 ['bottom_end',null,'left_end','elbow_tl']]
	
]

var hardLayouts = [
	[['elbow_br','horizontal','elbow_bl'],
	 ['vertical','left_end','elbow_tl'],
	 ['elbow_tr','T_bottom','right_end']]
]

var overclockedLayouts = [
	[['top_end','elbow_br','horizontal','elbow_bl'],
	 ['T_right','elbow_tl','left_end','T_left'],
	 ['elbow_tr','T_bottom','horizontal','elbow_tl']]
]


var common_items = [
	'uid://barym6hhh5lof',
	'uid://cufngxptqkg8t',
	'uid://dydb4b6ejbujs',
	'uid://dr6u6alykmbiq'
	]
var uncommon_items = [
	'uid://bl5yrm1a1my41',
	'uid://ctoksruhbeg8e',
	'uid://bs4wes58m0hq0',
	'uid://ctgnpkcyy8ht2'
]
var rare_items = [
	'uid://cvgmth288y40b',
	]

var hardware = ['Hook Mouse','Fiber Optic Boots','Simplified Physics',"Point'n Click"]

func calculate_stats():
	var item_counter = [0,0,0,0,0,0,0,0,0,0,0,0]
	for ID in inventory:
		item_counter[ID] += 1
	
	print(item_counter)
	#-Speed-----------------------------------------------------------------------------------------
	#Flash Drive
	speed = 80 + (item_counter[0] * 10)
	#Taillight
	reverse_boost = 20 * item_counter[6]
	
	#-Jumping---------------------------------------------------------------------------------------
	#float converter
	jump_time = .35 + (item_counter[1] * .05)
	
	
	#-Gravity---------------------------------------------------------------------------------------
	#fan
	slow_fall_cap = clamp(160 - (item_counter[3] * 20),20,160)
	#tungsten cube
	fast_fall_cap = clamp(160 + (item_counter[2] * 20),160,300)
	#qlaw
	wall_slide = 1 - (0.3 * item_counter[5])
	
	#-Time------------------------------------------------------------------------------------------
	#pocket watch
	bonus_time = 5 * item_counter[4]

func _process(delta: float) -> void:
	if game_active:
		global_time += delta
