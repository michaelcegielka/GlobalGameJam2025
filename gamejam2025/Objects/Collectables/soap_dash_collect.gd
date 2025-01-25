extends Node3D

const GroundOffset = 1.0

@onready var ray_cast_3d : RayCast3D = $RayCast3D

func _physics_process(_delta):
	if self.ray_cast_3d.is_colliding():
		self.global_position.y = self.ray_cast_3d.get_collision_point().y + GroundOffset
		self.set_physics_process(false)


func _on_area_3d_body_entered(_body):
	PlayerStats.soap_amount += PlayerStats.SoapIncrease
	self.queue_free()
