extends CharacterBody3D

var speed = 3.0
@onready var player: CharacterBody3D = $"../Player"

func _ready():
	if not player:
		print("Player not found")

func _process(delta):
	if player:
		var direction = (player.global_transform.origin - global_transform.origin).normalized()
		
		velocity = direction * speed
		move_and_slide()
		
		look_at(player.global_transform.origin, Vector3.UP)
