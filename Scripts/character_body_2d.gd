extends CharacterBody2D

var direction = 0
var facing = 0
var control = false
enum state {
	IDLE,
	RUNNING,
	JUMPING,
	FALLING,
	SLIDING,
	DEATH
}
var current_state = state.DEATH
var state_this_frame = ''

@onready var animation = $PlayerAnimator
@onready var jumpTime = $JumpTimer
@onready var sprite = $Sprite2D
@onready var cast = $ShapeCast2D
@onready var wallTime = $WallTimer

signal respawn_player()
signal game_over()
signal new_level()
signal pause_timer()
signal spawn_complete()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	
	
	if current_state != state.DEATH:
		#---Horizontal-Movement-------------------------------------------------
		if control:
			direction = Input.get_axis("left","right")
		velocity.x = direction * Global.speed
		
		if direction != 0 and is_on_floor_only():
			facing = direction
			state_this_frame = 'Running'
		elif direction == 0 and is_on_floor():
			state_this_frame = 'Idle'

		#---jumping-------------------------------------------------------------
		if Input.is_action_just_pressed("jump") and is_on_floor() and control or Input.is_action_just_pressed("jump") and is_on_wall() and control:
			velocity.y = -120
			jumpTime.start(Global.jump_time)
			state_this_frame = 'Jumping'
			
			if is_on_wall_only():
				wallTime.start()
				control = false
				if cast.is_colliding():
					direction = -1
				else:
					direction = 1
				facing = direction
		
		if Input.is_action_just_pressed("down"):
			set_collision_mask_value(2, false) 
		if Input.is_action_just_released("down"):
			set_collision_mask_value(2, true) 

		
		if Input.is_action_just_released("jump"):
			jumpTime.stop()
			_on_jump_timer_timeout()
		
		if current_state == state.JUMPING and is_on_ceiling():
			jumpTime.stop()
			_on_jump_timer_timeout()
		
		if current_state == state.FALLING and is_on_wall() and not Input.is_action_pressed("down"):
			velocity.y = 0
			state_this_frame = 'Sliding'
		
		if current_state == state.SLIDING and not is_on_wall() or current_state in [state.IDLE, state.RUNNING] and not is_on_floor():
			state_this_frame = 'Falling'
		
		#---Gravity-------------------------------------------------------------
		#regular
		if not is_on_floor() and not is_on_wall() and current_state != state.JUMPING:
			velocity.y += 10
		#wall_sliding
		if is_on_wall_only() and current_state == state.SLIDING and not Input.is_action_pressed("down"):
			velocity.y += Global.wall_slide
		#holding down
		elif is_on_wall_only() and Input.is_action_pressed("down"):
			velocity.y += 10
			state_this_frame = 'Falling'
			
		
		
		if is_on_floor() and current_state in [state.FALLING, state.SLIDING]:
			velocity.y = 0
			state_this_frame = 'Idle'

		match state_this_frame:
			'Running':
				current_state = state.RUNNING
				state_this_frame = ''
			'Jumping':
				current_state = state.JUMPING
				state_this_frame = ''
			'Idle':
				current_state = state.IDLE
				state_this_frame = ''
			'Sliding':
				current_state = state.SLIDING
				state_this_frame = ''
			'Falling':
				current_state = state.FALLING
				state_this_frame = ''

	#---Animation---------------------------------------------------------------
		match current_state:
			state.RUNNING:
				if facing == 1:
					animation.play("Run_R")
				else:
					animation.play("Run_L")
			state.IDLE:
				animation.stop()
				if facing == 1:
					sprite.frame = 10
				else:
					sprite.frame = 11
			state.JUMPING:
				animation.stop()
				if facing == 1:
					sprite.frame = 3
				else:
					sprite.frame = 8
			state.FALLING:
				animation.stop()
				if facing == 1:
					sprite.frame = 3
				else:
					sprite.frame = 8
			state.SLIDING:
				animation.stop()
				if cast.is_colliding():
					sprite.frame = 4
				else:
					sprite.frame = 9
					
	#---End-Collision-----------------------------------------------------------
	
		if global_position.distance_to(Global.end_pos) < 10:
			current_state = state.DEATH
			velocity = Vector2(0,0)
			control = false
			animation.stop()
			animation.play("Esc")
			emit_signal('pause_timer')
			
	#---Hazard-Collision--------------------------------------------------------
	for i in range(get_slide_collision_count()):
		if get_slide_collision(i).get_collider() != null:
			var collider = get_slide_collision(i).get_collider().name
			if collider == 'Hazards' and current_state != state.DEATH or collider == 'Pits' and current_state != state.DEATH:
				current_state = state.DEATH
				wallTime.stop()
				control = false
				direction = 0
				velocity = Vector2(0,0)
				animation.stop()
				animation.play("Death")
				emit_signal('pause_timer')
	
	var fall_cap = 160
	if Input.is_action_pressed("down"):
		fall_cap = Global.fast_fall_cap
	else:
		fall_cap = Global.slow_fall_cap
	velocity.y = clamp(velocity.y, -500, fall_cap)
	velocity.x = clamp(velocity.x, -400, 400)
	
	move_and_slide()


func _on_jump_timer_timeout() -> void:
	if current_state == state.JUMPING:
		if is_on_wall_only():
			current_state = state.SLIDING
			velocity.y = -5
		else:
			current_state = state.FALLING
			velocity.y = -40


func _on_wall_timer_timeout() -> void:
	control = true
	
func _reset() -> void:
	#if Global.lives > 1:
	#	Global.lives -= 1
	emit_signal('respawn_player')
	animation.play("Spawn")
	#else:
	#	emit_signal('game_over')

func spawn_start(pos: Vector2) -> void:
	global_position = pos
	animation.stop()
	animation.play('Spawn')
	emit_signal('pause_timer')
	

func _spawn_done() -> void:
	control = true
	self.set_collision_mask_value(2, true) 
	current_state = state.IDLE
	animation.stop()
	animation.play('RESET')
	emit_signal('spawn_complete')


func next_level() -> void:
	emit_signal("new_level")
