extends Node3D

@export var have_coll := true

func _ready():
	if not self.have_coll:
		$StaticBody3D.queue_free()
