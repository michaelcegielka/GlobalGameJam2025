extends Node3D

@onready var player = $Player

@onready var collectables = $Collectables
@onready var obstacles = $Obstacles
@onready var enemies = $Enemies
@onready var particles = $Particles

### End cam
@onready var final_cam = $FinalCam
var start_rot : Vector3 
var goal_rot : Vector3

### UI
@onready var screen_animation_player : AnimationPlayer = $BlackScreen/ScreenAnimationPlayer


var original_player_pos := Vector3.ZERO

var cam_tween : Tween


func _ready():
	GlobalSignals.connect("add_enemy", self.add_enemy)
	GlobalSignals.connect("add_collectable", self.add_collectable)
	GlobalSignals.connect("add_object", self.add_object)
	GlobalSignals.connect("add_particle", self.add_particle)
	PlayerStats.connect("player_died", self.end_screen)
	
	self.original_player_pos = self.player.global_position
	
	self.start_game()
	

func start_game():
	self.screen_animation_player.play("FadeBlackIn")

func done_fading():
	self.player.set_physics_process(true)

func end_screen():
	self.player.set_physics_process(false)
	self.tween_cams(self.get_viewport().get_camera_3d(), self.final_cam, 2.0)
	await self.cam_tween.finished
	
	self.screen_animation_player.play("FadeBlackOut")
	await self.screen_animation_player.animation_finished
	self.reset()
	self.start_game()
	


func tween_cams(current_cam : Camera3D, new_cam : Camera3D, tween_time : float = 1.5):
	var goal_pos = new_cam.global_position
	self.goal_rot = new_cam.global_rotation
	self.start_rot = current_cam.global_rotation
	
	new_cam.global_position = current_cam.global_position
	new_cam.global_rotation = current_cam.global_rotation

	if self.cam_tween: self.cam_tween.kill() # Abort the previous animation.
	self.cam_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
	self.cam_tween.tween_property(new_cam, "global_position", goal_pos, tween_time)
	self.cam_tween.tween_method(self.lerp_cam_angle, 0.0, 1.0, tween_time)
	new_cam.current = true

func lerp_cam_angle(weight):
	self.final_cam.global_rotation.x = lerp_angle(self.start_rot.x, 
														self.goal_rot.x, weight)
	self.final_cam.global_rotation.y = lerp_angle(self.start_rot.y, 
														self.goal_rot.y, weight)
	self.final_cam.global_rotation.z = lerp_angle(self.start_rot.z, 
														self.goal_rot.z, weight)

#################################################
func _process(delta):
	PlayerStats.current_time += delta

#################################################
func add_enemy(new_enemy):
	self.enemies.add_child(new_enemy)

func add_collectable(new_collectable):
	self.collectables.add_child(new_collectable)
	
func add_object(new_object):
	self.obstacles.add_child(new_object)
	
func add_particle(new_particle):
	self.particles.add_child(new_particle)


func clear_all():
	for i in self.enemies.get_children():
		i.queue_free()
	for i in self.particles.get_children():
		i.queue_free()
	for i in self.obstacles.get_children():
		i.queue_free()
	for i in self.collectables.get_children():
		i.queue_free()

func reset():
	self.clear_all()
	self.player.global_position = self.original_player_pos
	PlayerStats.reset()
	self.player.reset()
