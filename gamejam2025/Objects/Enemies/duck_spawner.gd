extends Node3D

@export var DuckScene : PackedScene

const SpawnRange = 20.0

func spawn_ducks(player, idx):
	for i in range(idx):
		var new_duck = DuckScene.instantiate()
		GlobalSignals.emit_signal("add_enemy", new_duck)
		new_duck.global_position = self.global_position
		new_duck.set_player(player)
		new_duck.global_position.x += randf_range(-SpawnRange, SpawnRange)
		new_duck.global_position.z += randf_range(-SpawnRange, SpawnRange)
