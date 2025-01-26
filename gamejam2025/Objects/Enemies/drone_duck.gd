extends "res://Objects/Enemies/enemy.gd"

const YMin = 14
const YMax = 22
const HeightRange = 2

@onready var bomb_scene: PackedScene = preload("res://Objects/Enemies/bomb.tscn")

const BombDropTime := 3

var height_goal = 0.0

@onready var bomb_timer = $BombTimer
@onready var propeller: MeshInstance3D = $Model/Propeller

func _ready():
	super._ready()
	self.bomb_timer.start(self.BombDropTime)
	self.rotation_speed = 1.5
	self.height_goal = randf_range(self.YMin, self.YMax)
	

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
	self.current_dir = lerp(self.current_dir, direction, self.rotation_speed*delta)
	self.current_dir = self.current_dir.normalized()
	transform.basis = Basis.looking_at(self.current_dir, Vector3.UP)

func move_forward(_delta):
	self.velocity = self.current_dir * speed
	if self.global_position.y < self.height_goal - self.HeightRange:
		self.velocity.y += 20
	elif self.global_position.y > self.height_goal + self.HeightRange:
		self.velocity.y -= 20
		
	move_and_slide()

func spin_propeller(_delta):
	propeller.rotate_y(40 * _delta)

func _on_bomb_timer_timeout():
	var bomb = bomb_scene.instantiate()
	GlobalSignals.emit_signal("add_object", bomb)
	bomb.global_transform.origin = global_transform.origin
