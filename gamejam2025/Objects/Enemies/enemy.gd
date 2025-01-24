extends CharacterBody3D

var speed = 6.0

var rotation_speed = 1.0

@onready var player: CharacterBody3D = $"../Player"

var surface_normal = Vector3.UP

func _ready():
	if not player:
		print("Player nicht gefunden")

func _process(delta):
	if player:
		var player_position = player.global_transform.origin
		var enemy_position = global_transform.origin
		var direction = (player_position - enemy_position).normalized()
		
		direction = direction - direction.project(surface_normal)
		direction = direction.normalized()
		
		velocity = direction * speed
		move_and_slide()
		
		update_surface_normal()
		
		rotate_towards_player(delta, direction)

func update_surface_normal():
	if is_on_floor() or is_on_wall():
		surface_normal = get_floor_normal() if is_on_floor() else get_wall_normal()

func rotate_towards_player(delta, direction: Vector3):
	var current_forward = -transform.basis.z
	var new_forward = current_forward.lerp(direction, rotation_speed * delta).normalized()
	
	transform.basis = Basis.looking_at(new_forward, surface_normal)
