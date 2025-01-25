extends Node3D

@export var player : Player

var is_grinding := false

@onready var path_3d = $Path3D

func jump_after_grind():
	if self.is_grinding:
		self.player.velocity.y += 0.5*self.player.JumpStrength
		self.player.current_state = self.player.States.JUMPING
		self.player.global_position.y += 0.1

func _on_grind_area_body_exited(_body):
	if self.is_grinding:
		self.jump_after_grind()
		PlayerStats.emit_signal("show_pop_up")
	self.is_grinding = false


func _on_grind_area_body_entered(_body):
	if self.player.global_position.y > self.global_position.y:
		var grind_dir = self.transform.basis.z
		var grind_dir_normal = self.transform.basis.x
		
		var amount_x = grind_dir_normal.dot(self.player.velocity)
		var amount_z = grind_dir.dot(self.player.velocity)
		if abs(amount_z) > abs(amount_x):
			self.is_grinding = true
			var non_y_speed = Vector2(self.player.velocity.x, self.player.velocity.z).length()
			self.player.velocity = sign(amount_z) * max(non_y_speed, 2.0) * grind_dir
			self.player.current_state = self.player.States.GRINDING
			# set position onto rail:
			var local_pos = self.player.global_position - self.path_3d.global_position
			var point_on_path = self.path_3d.curve.get_closest_point(local_pos)
			self.player.set_deferred("global_position", 
				local_pos + self.path_3d.global_position)
		
