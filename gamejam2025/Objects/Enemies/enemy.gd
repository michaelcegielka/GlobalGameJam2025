extends CharacterBody3D

@onready var weapon_mesh: MeshInstance3D = $Model/WeaponMesh

var weapon_swing_speed = 100.0
var weapon_swing_strength = 5.0

var speed = 6.0
var rotation_speed = 1.0

@onready var player: CharacterBody3D = $"../Player"
var surface_normal = Vector3.UP

func _ready():
	if not player:
		print("Player nicht gefunden")

func _process(delta):
	if player:
		update_surface_normal()
		rotate_towards_player(delta)
		move_forward(delta)
		randomize_weapon_rotation(delta)

func randomize_weapon_rotation(delta):
	var random_rotation_x = randf_range(-weapon_swing_strength, weapon_swing_strength)
	var random_rotation_z = randf_range(-weapon_swing_strength, weapon_swing_strength)
	weapon_mesh.rotation.x = lerp_angle(weapon_mesh.rotation.x, random_rotation_x, weapon_swing_speed * delta)
	weapon_mesh.rotation.z = lerp_angle(weapon_mesh.rotation.z, random_rotation_z, weapon_swing_speed * delta)

func move_forward(delta):
	var move_direction = -transform.basis.z
	velocity = move_direction * speed
	move_and_slide()

func rotate_towards_player(delta):
	var player_position = player.global_transform.origin
	var enemy_position = global_transform.origin
	var direction = (player_position - enemy_position).normalized()
	direction = direction - direction.project(surface_normal)
	direction = direction.normalized()
	var target_basis = Basis().looking_at(direction, surface_normal)
	transform.basis = transform.basis.slerp(target_basis, rotation_speed * delta)

func update_surface_normal():
	if is_on_floor() or is_on_wall():
		surface_normal = get_floor_normal() if is_on_floor() else get_wall_normal()
