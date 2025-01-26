extends CharacterBody3D

const DeathY = -100
const DUCK_DEATH = preload("res://Objects/Enemies/Sounds/duck_death.wav")
const DUCK_QUACK = preload("res://Objects/Enemies/Sounds/duck_quack.wav")

const Bubble = preload("res://Objects/Obstacles/bubble.tscn")
const ExploderParticles = preload("res://Objects/Enemies/Particles/duck_explode_particle.tscn")

@onready var weapon_mesh: MeshInstance3D = $Model/WeaponMesh
@onready var helmets = $Model/Helmets


var weapon_swing_speed = 100.0
var weapon_swing_strength = 5.0

@export var speed = 6.0
@export var rotation_speed = 0.25
var current_dir := Vector3.FORWARD

@export var bubbles_on_death := 2
@export var body_material : StandardMaterial3D

@export var player : Player
var surface_normal = Vector3.UP

func _ready():
	var rand_idx = randi_range(0, self.helmets.get_child_count())
	if rand_idx < self.helmets.get_child_count():
		self.helmets.get_child(rand_idx).visible = true

func set_player(player_unit):
	self.player = player_unit
	self.current_dir = self.global_position.direction_to(self.player.global_position)
	self.current_dir.y = 0.0

func _physics_process(delta):
	if randf() < 0.01:
		AudioHandler.add_sound_effect(self.DUCK_QUACK, self.global_position)
	update_surface_normal()
	rotate_towards_player(delta)
	move_forward(delta)
	if self.global_position.y < self.DeathY:
		self.queue_free()

func randomize_weapon_rotation(delta):
	var random_rotation_x = randf_range(-weapon_swing_strength, weapon_swing_strength)
	var random_rotation_z = randf_range(-weapon_swing_strength, weapon_swing_strength)
	weapon_mesh.rotation.x = lerp_angle(weapon_mesh.rotation.x, random_rotation_x, weapon_swing_speed * delta)
	weapon_mesh.rotation.z = lerp_angle(weapon_mesh.rotation.z, random_rotation_z, weapon_swing_speed * delta)

func move_forward(_delta):
	var move_direction = self.current_dir # -transform.basis.z
	self.velocity = move_direction * speed
	if not self.is_on_floor():
		self.velocity.y = -20.0
	move_and_slide()

func rotate_towards_player(delta):
	var player_position = player.global_transform.origin
	var enemy_position = global_transform.origin
	var direction = (player_position - enemy_position).normalized()
	direction = direction - direction.project(surface_normal)
	direction.y = 0.0
	direction = direction.normalized()
	self.current_dir = lerp(self.current_dir, direction, rotation_speed*delta).normalized()
	var target_basis = Basis.looking_at(self.current_dir, surface_normal)
	transform.basis = target_basis #transform.basis.slerp(target_basis, rotation_speed * delta)

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
	trigger_explosion(self.global_position, 25)
	AudioHandler.add_sound_effect(self.DUCK_DEATH, self.global_position)
	var new_explo = self.ExploderParticles.instantiate()
	GlobalSignals.emit_signal("add_particle", new_explo)
	new_explo.global_position = self.global_position
	new_explo.set_material(self.body_material)
	PlayerStats.current_ducks -= 1
	self.queue_free()


func _on_hurt_box_body_entered(body : Player):
	PlayerStats.soap_amount -= PlayerStats.HitCost
	body.velocity += PlayerStats.HitKnockBack * self.current_dir


func _on_head_area_body_entered(body):
	body.velocity.y = 2.0*body.JumpStrength
	PlayerStats.emit_signal("show_pop_up")
	self._on_hitbox_area_entered(null)
	GlobalSignals.emit_signal("perform_trick", "enemy_jump")
	
func trigger_explosion(local_position: Vector3, radius: int):
	GlobalSignals.emit_signal("erase_dirt_local", local_position, radius)


func _on_visible_on_screen_notifier_3d_screen_entered():
	self.set_physics_process(true)


func _on_visible_on_screen_notifier_3d_screen_exited():
	self.set_physics_process(false)
