extends Node3D

func _ready():
	$ExplodeParticle.emitting = true

func _on_explode_particle_finished():
	self.queue_free()


func set_material(new_material):
	$ExplodeParticle.material_override = new_material
