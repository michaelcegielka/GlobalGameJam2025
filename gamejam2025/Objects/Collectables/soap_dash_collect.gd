extends Node3D

const GroundOffset = 1.5
const HideTime = 20.0

@onready var ray_cast_3d : RayCast3D = $RayCast3D
@onready var area_3d = $Area3D
@onready var timer = $Timer

@export var snap_to_ground := true

func _ready():
	self.set_physics_process(self.snap_to_ground)

func _physics_process(_delta):
	if self.ray_cast_3d.is_colliding():
		self.global_position.y = self.ray_cast_3d.get_collision_point().y + GroundOffset
		self.set_physics_process(false)


func _on_area_3d_body_entered(_body):
	PlayerStats.soap_amount += PlayerStats.SoapIncrease
	self.visible = false
	self.area_3d.set_deferred("monitoring", false)
	self.timer.start(self.HideTime)


func _on_timer_timeout():
	self.visible = true
	self.area_3d.set_deferred("monitoring", true)


func reset():
	self.timer.stop()
	self._on_timer_timeout()
