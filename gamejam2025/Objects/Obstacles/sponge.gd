extends Node3D

const YOffSet = 0.2 # for jump when land on top

@onready var animation_player : AnimationPlayer = $AnimationPlayer


func _on_player_detect_body_entered(body : Player):
	self.animation_player.play("HitTop")
	if body.global_position.y > self.global_position.y + YOffSet:
		body.velocity.y += 2.0*body.JumpStrength
		body.current_state = body.States.JUMPING
	else:
		var dir = -self.global_position.direction_to(body.global_position)
		var velo_amount = dir.dot(body.velocity)
		if velo_amount > 5.0:
			body.velocity.x *= -1
			body.velocity.z *= -1
