extends CharacterBody3D

@onready var player: CharacterBody3D = $"../Player"
@onready var bomb_scene: PackedScene = preload("res://Objects/Enemies/bomb.tscn")
@onready var propeller: MeshInstance3D = $Model/Propeller

var speed = 3
var rotation_speed = 1
var bomb_drop_interval = 3
var time_since_last_bomb = 0

func _ready():
	if not player:
		print("Player nicht gefunden")

func _process(delta):
	if player:
		rotate_towards_player(delta)
		move_forward(delta)
		spin_propeller(delta)
		
		time_since_last_bomb += delta
		if time_since_last_bomb >= bomb_drop_interval:
			drop_bomb()
			time_since_last_bomb = 0

func rotate_towards_player(delta):
	var player_position = player.global_transform.origin
	var enemy_position = global_transform.origin
	var direction = (player_position - enemy_position).normalized()
	direction.y = 0
	var target_basis = Basis().looking_at(direction, Vector3.UP)
	transform.basis = transform.basis.slerp(target_basis, rotation_speed * delta)

func move_forward(delta):
	var move_direction = -transform.basis.z
	velocity = move_direction * speed
	move_and_slide()

func spin_propeller(delta):
	propeller.rotate_y(40 * delta)

func drop_bomb():
	var bomb = bomb_scene.instantiate()
	bomb.global_transform.origin = global_transform.origin
	get_parent().add_child(bomb)
