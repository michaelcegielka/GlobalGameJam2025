extends CharacterBody3D

const ExplosionParticle = preload("res://Objects/Enemies/ExplosionParticles.tscn")

func _ready():
	self.velocity.y = -9.81

func _physics_process(_delta):
	self.move_and_slide()
	if self.is_on_floor():
		var explo = self.ExplosionParticle.instantiate()
		GlobalSignals.emit_signal("add_particle", explo)
		explo.global_position = self.global_position
		GlobalSignals.emit_signal("put_dirt_local", self.global_position)
		self.queue_free()


func _on_area_3d_body_entered(body):
	PlayerStats.soap_amount -= PlayerStats.HitCost / 2.0
	body.velocity += PlayerStats.HitKnockBack / 3.0 * self.current_dir
