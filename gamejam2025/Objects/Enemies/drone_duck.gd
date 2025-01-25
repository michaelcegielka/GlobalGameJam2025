extends "res://Objects/Enemies/enemy.gd"

@onready var bomb_scene: PackedScene = preload("res://Objects/Enemies/bomb.tscn")

const BombDropTime := 3

@onready var bomb_timer = $BombTimer
@onready var propeller: MeshInstance3D = $Model/Propeller

func _ready():
	super._ready()
	self.bomb_timer.start(self.BombDropTime)
	

func _physics_process(delta):
	if player:
		rotate_towards_player(delta)
		move_forward(delta)
		spin_propeller(delta)

func rotate_towards_player(delta):
	var player_position = player.global_transform.origin
	var enemy_position = global_transform.origin
	var direction = (player_position - enemy_position).normalized()
	direction.y = 0
	var target_basis = Basis.looking_at(direction, Vector3.UP)
	transform.basis = transform.basis.slerp(target_basis, rotation_speed * delta)

func move_forward(delta):
	var move_direction = -transform.basis.z
	velocity = move_direction * speed
	move_and_slide()

func spin_propeller(delta):
	propeller.rotate_y(40 * delta)

func _on_bomb_timer_timeout():
	var bomb = bomb_scene.instantiate()
	GlobalSignals.emit_signal("add_enemy", bomb)
	bomb.global_transform.origin = global_transform.origin
