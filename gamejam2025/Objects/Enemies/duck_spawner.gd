extends Node3D

const BasicDuck = preload("res://Objects/Enemies/enemy.tscn")
const DroneDuck = preload("res://Objects/Enemies/drone_duck.tscn")
const SwordDuck = preload("res://Objects/Enemies/sword_duck.tscn")

const SpawnRange = 20.0

func spawn_ducks(player, idx, duck_type : int):
	for i in range(idx):
		var new_duck = null
		if duck_type == 0:
			new_duck = BasicDuck.instantiate()
		elif duck_type == 1:
			new_duck = DroneDuck.instantiate()
		else:
			new_duck = SwordDuck.instantiate()
		GlobalSignals.emit_signal("add_enemy", new_duck)
		new_duck.global_position = self.global_position
		new_duck.set_player(player)
		new_duck.global_position.x += randf_range(-SpawnRange, SpawnRange)
		new_duck.global_position.z += randf_range(-SpawnRange, SpawnRange)
		
