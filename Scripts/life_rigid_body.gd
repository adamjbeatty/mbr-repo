extends RigidBody2D

var teleport = false
var target_pos

	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if teleport:
		state.transform.origin = target_pos
		
		state.transform.x = Vector2(cos(0), sin(0))
		state.transform.y = Vector2(-sin(0), cos(0))
		
		teleport = false
