extends Node3D

const CheckTime = 0.5

@onready var timer : Timer = $Timer


func _on_area_1_body_entered(body : Player):
	self.timer.start(self.CheckTime)
	#body.velocity = 1.6*body.velocity.length() * Vector3.FORWARD

func _on_area_2_body_entered(body : Player):
	if self.timer.time_left > 0:
		body.velocity = 1.6*body.velocity.length() * Vector3.UP
		body.current_state = body.States.JUMPING
		body.global_position.y += 1
		GlobalSignals.emit_signal("perform_trick", "ramp")
