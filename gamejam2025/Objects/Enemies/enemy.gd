extends CharacterBody3D

const Bubble = preload("res://Objects/Obstacles/bubble.tscn")
const ExploderParticles = preload("res://Objects/Enemies/Particles/duck_explode_particle.tscn")

@onready var weapon_mesh: MeshInstance3D = $Model/WeaponMesh

var weapon_swing_speed = 100.0
var weapon_swing_strength = 5.0

var speed = 6.0
var rotation_speed = 1.0

@export var bubbles_on_death := 2
@export var body_material : StandardMaterial3D

@export var player : Player
var surface_normal = Vector3.UP


func _ready():
	pass

func _physics_process(delta):
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

func move_forward(_delta):
	var move_direction = -transform.basis.z
	velocity = move_direction * speed
	move_and_slide()

func rotate_towards_player(delta):
	var player_position = player.global_transform.origin
	var enemy_position = global_transform.origin
	var direction = (player_position - enemy_position).normalized()
	direction = direction - direction.project(surface_normal)
	direction = direction.normalized()
	var target_basis = Basis.looking_at(direction, surface_normal)
	transform.basis = transform.basis.slerp(target_basis, rotation_speed * delta)

func update_surface_normal():
	if is_on_floor() or is_on_wall():
		surface_normal = get_floor_normal() if is_on_floor() else get_wall_normal()


func _on_hitbox_area_entered(_area):
	# bubbles
	for i in range(self.bubbles_on_death):
		var new_bubble = self.Bubble.instantiate()
		GlobalSignals.emit_signal("add_object", new_bubble)
		new_bubble.global_position = self.global_position
		new_bubble.global_position.y += randf_range(1.0, 3.0)
		new_bubble.global_position.x += randf_range(-5.0, 5.0)
		new_bubble.global_position.z += randf_range(-5.0, 5.0)
	
	# explosion:
	var new_explo = self.ExploderParticles.instantiate()
	GlobalSignals.emit_signal("add_particle", new_explo)
	new_explo.global_position = self.global_position
	new_explo.set_material(self.body_material)
	self.queue_free()
