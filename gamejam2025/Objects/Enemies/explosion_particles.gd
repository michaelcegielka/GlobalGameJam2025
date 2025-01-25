extends Node3D


func _ready():
	$GPUParticles3D.emitting = true

func _on_gpu_particles_3d_finished():
	self.queue_free()
