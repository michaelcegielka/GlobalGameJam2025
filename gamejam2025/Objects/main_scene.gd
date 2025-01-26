extends Node3D

#######
### Sounds
const DUCK_SLAYER_MAIN_THEME = preload("res://Objects/InGame/DuckSlayer_MainTheme_cut.wav")
const DUCK_QUACK = preload("res://Objects/Enemies/Sounds/duck_quack.wav")
#######


const IncreaseDifficultyTime = 120.0
const IncreaseDifficultyTime2 = 300.0
const DefaultEnemyLimit = 5
const EnemyLimit1 = 9
const EnemyLimit2 = 14

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
@onready var duck_animation_player = $CanvasLayer/DuckAnimationPlayer
@onready var end_screen_ui = $EndScreen


### Enemies
@export var SpawnTime = 30.0
@onready var spawn_timer = $SpawnTimer
var start_spawn_time

@onready var all_spawner := $Spawner

var first_spawn := true
var current_enemy_limit := 10.0
var current_difficulty = 0

var original_player_pos := Vector3.ZERO

var cam_tween : Tween



func _ready():
	start_spawn_time = spawn_timer.get("wait_time")
	GlobalSignals.connect("add_enemy", self.add_enemy)
	GlobalSignals.connect("add_collectable", self.add_collectable)
	GlobalSignals.connect("add_object", self.add_object)
	GlobalSignals.connect("add_particle", self.add_particle)
	PlayerStats.connect("player_died", self.end_screen)
	self.end_screen_ui.connect("restart_game", self.reset)
	self.original_player_pos = self.player.global_position
	self.set_process(false)
	self.start_game()
	

func start_game():
	AudioHandler.set_bgm(self.DUCK_SLAYER_MAIN_THEME)
	self.screen_animation_player.play("FadeBlackIn")

func done_fading():
	self.player.set_physics_process(true)
	self.set_process(true)

func end_screen():
	self.player.set_physics_process(false)
	self.set_process(false)
	self.tween_cams(self.get_viewport().get_camera_3d(), self.final_cam, 2.0)
	await self.cam_tween.finished
	PlayerStats.emit_signal("compute_score")
	self.end_screen_ui.show_end_screen()
	spawn_timer.stop()

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
		i.reset()

func reset():
	self.screen_animation_player.play("FadeBlackOut")
	await self.screen_animation_player.animation_finished
	
	self.clear_all()
	self.first_spawn = true
	self.player.global_position = self.original_player_pos
	PlayerStats.reset()
	GlobalSignals.emit_signal("reset_bathub")
	self.player.reset()
	
	spawn_timer.wait_time = start_spawn_time
	spawn_timer.start()
	
	self.start_game()



func _on_spawn_timer_timeout():
	self.spawn_timer.start(self.SpawnTime)
	### comput difficulty
	if PlayerStats.current_time > self.IncreaseDifficultyTime2:
		self.current_difficulty = 2
		self.current_enemy_limit = self.EnemyLimit2
	elif PlayerStats.current_time > self.IncreaseDifficultyTime:
		self.current_difficulty = 1
		self.current_enemy_limit = self.EnemyLimit1
	else:
		self.current_difficulty = 0
		self.current_enemy_limit = self.DefaultEnemyLimit
	### Check if we need to show something or we have already enough enemies
	if self.first_spawn:
		self.first_spawn = false
		self.duck_animation_player.play("ShowText")
	
	var current_enemies = self.enemies.get_child_count()
	if current_enemies < self.current_enemy_limit:
		AudioHandler.add_sound_everwhere(self.DUCK_QUACK, 0.5)
	### spawn ducks
	for spawner in self.all_spawner.get_children():
		if current_enemies > self.current_enemy_limit:
			return
		current_enemies += 1
		spawner.spawn_ducks(self.player, 1, randi_range(0, self.current_difficulty))
