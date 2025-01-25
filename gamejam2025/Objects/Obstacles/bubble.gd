extends Node3D

const MinRadius = 2.5
const MaxRadius = 3.5
const YOffSet = 0.25 # for jump when land on top
const MovementRange = 4.0
const Velocity = 3.5

@onready var mesh : MeshInstance3D = $Mesh
@onready var collision_shape_3d : CollisionShape3D = $Hitbox/CollisionShape3D
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var current_dir := -1
var start_y := 0.0
func _ready():
	var random_radius = randf_range(self.MinRadius, self.MaxRadius)
	self.mesh.mesh.radius = random_radius
	self.mesh.mesh.height = 2*random_radius
	self.collision_shape_3d.shape.radius = random_radius + 0.25
	self.start_y = self.global_position.y


func _physics_process(delta):
	self.global_position.y += self.Velocity * self.current_dir * delta
	if self.start_y - self.global_position.y < -self.MovementRange:
		self.current_dir = -1
	elif -self.start_y + self.global_position.y < self.MovementRange:
		self.current_dir = 1
		
func _on_hitbox_body_entered(body : Player):
	PlayerStats.soap_amount += PlayerStats.SoapIncrease / 2.0
	self.animation_player.play("Pop")
	if body.global_position.y >= self.global_position.y + self.YOffSet:
		body.velocity.y = 2.0*body.JumpStrength
	
