extends CharacterBody3D
class_name Player

const HealParticles = preload("res://Objects/PLayer/heal_particles.tscn")

enum States {JUMPING, FALLING, GROUNDED, FAST, DEAD, GRINDING}

const WallAngleMin = PI/8
const WallAngleMax = PI/2.5
const WallAngleStep = (WallAngleMax - WallAngleMin) / 2.0

const WallAngleSlide = PI/6.0
const SlideAmount = 25.0

const Acceleration = 40.0
const DashAcceleration = 80.0
const AirAcceleration = 20.0

const Friction = 2.0
const AirFriction = 0.5
const GrindFriction = 1.0

const MaxVelocity = 50.0
const DashVelocity = 70.0
const JumpStrength = 25.0
const CoyoteTime = 0.1

const Gravity = -80.0
const AirGravity = -40.0

const CamSpeedRot = 5.0
const MinCamAngle = 0.5 # min angle for camera up
const MaxCamAngle = -1.0 # max angle for camera down
const MaxCamRotDifference = -PI/8.0

const MinArmDistance = 8.0
const MaxArmDistance = 6.0
const VelocityScale = 10.0
const UnderVelocityAngle = 10.0
### Make soap smaller
const OriginalShiftSoapY = -0.28
const FinalShiftSoapY = -0.49
const OriginalShiftBoyY = 0.0
const FinalShiftBoyY = -0.745
const OriginalShiftParticleY = -0.4
const FinalShiftParticleY = -0.75
const FinalScaleY = 0.02
### Head location
const OriginalHeadPos = Vector3(0.0, 2.6, 0.0)
const DeadHeadPos = Vector3(0.0, 0.5, 11.0)
### Controll sutff
var current_dir := Vector3.ZERO
var current_floor_normal := Vector3.UP
var current_state := States.FALLING

var was_dashing_before := false
### Combo stuff
var start_angle_jump := 0.0
var prev_angle := 0.0

### Attacks:
@onready var dash_shape = $HurtBox/DashShape


@onready var coyote_timer : Timer = $CoyoteTimer
@onready var particle_cool_down_timer : Timer = $ParticleCoolDownTimer

### Camera
@onready var spring_arm_3d : SpringArm3D = $SpringArm3D
@onready var camera_3d : Camera3D = $SpringArm3D/Node3D/Camera3D

### Model:
@onready var model = $Model
@onready var soap = $Model/player/Player/Skeleton3D/Soap
@onready var bubble_boy = $Model/player/Player/Skeleton3D/BubbleBoy

@onready var head_marker = $Model/HeadMarker
@onready var soap_bubbles : GPUParticles3D = $Model/SoapBubbles
@onready var animation_player : AnimationPlayer = $Model/player/AnimationPlayer



func _ready():
	PlayerStats.connect("got_soap", self.show_heal_particles)
	self.soap_bubbles.emitting = false
	self.set_physics_process(false)


func reset():
	self.soap_bubbles.emitting = false
	self.current_state = States.FALLING
	self.velocity = Vector3.ZERO
	self.model.rotation = Vector3.ZERO
	self.current_dir = Vector3.ZERO
	self.camera_3d.current = true
	self.animation_player.play("IdleMove")
	self.head_marker.position = self.OriginalHeadPos
	self.update_soap_thickness()

#################################################################
### Camera
func control_cam(delta):
	var cam_rot_y = Input.get_action_strength("CamRight") - Input.get_action_strength("CamLeft")
	if cam_rot_y == 0 and self.is_on_floor() and self.velocity.length() > self.UnderVelocityAngle:
		self.spring_arm_3d.rotation.y = lerp_angle(self.spring_arm_3d.rotation.y, 
					PI + self.model.rotation.y, delta)
	else:
		self.spring_arm_3d.rotation.y = lerp_angle(self.spring_arm_3d.rotation.y, 
							self.spring_arm_3d.rotation.y + cam_rot_y * self.CamSpeedRot, 
							delta)
	

	var cam_rot_x = Input.get_action_strength("CamUp") - Input.get_action_strength("CamDown")
	cam_rot_x = clamp(self.spring_arm_3d.rotation.x + cam_rot_x, self.MaxCamAngle, self.MinCamAngle)
	self.spring_arm_3d.rotation.x = lerp_angle(
		self.spring_arm_3d.global_rotation.x, cam_rot_x, delta)
		
	self.camera_3d.look_at(self.head_marker.global_position)
	
		
	var horizontal_velocity = Vector3(self.velocity.x, 0, self.velocity.z)
	var velocity_scale = (horizontal_velocity.length() - self.UnderVelocityAngle) / self.VelocityScale
	var distance_step = (self.MaxArmDistance - self.MinArmDistance) / 5.0
	self.spring_arm_3d.spring_length = clamp(
		self.MinArmDistance + distance_step * velocity_scale, 
		self.MinArmDistance, self.MaxArmDistance
	)

	self.camera_3d.fov = min(90 + velocity_scale * 9, 150)

#################################################################
### Model and visual stuff
func tilt_model(up_vector):
	var damping_factor = 0.1
	var target_up
	
	if self.current_state == States.GROUNDED:
		var input_direction = Input.get_action_strength("Right") - Input.get_action_strength("Left")
		
		var horizontal_velocity = Vector3(self.velocity.x, 0, self.velocity.z)
		var velocity_scale = clamp(horizontal_velocity.length() / self.MaxVelocity, 0, 1)
		
		var tilt_direction_local = Vector3.LEFT * input_direction
		
		var player_rotation = self.model.transform.basis
		var tilt_direction_global = player_rotation * tilt_direction_local
		
		var tilt_amount = velocity_scale * 0.65 
		var target_tilt = tilt_direction_global * tilt_amount
		
		target_up = (up_vector + target_tilt).normalized()
	else:
		target_up = up_vector
		damping_factor = 0.2
	
	var current_up = self.model.transform.basis.y
	var new_up = current_up.lerp(target_up, damping_factor).normalized()
	
	var rotation_axis = current_up.cross(new_up).normalized()
	var rotation_angle = current_up.angle_to(new_up)
	
	if rotation_axis.length() > 0 and not is_nan(rotation_angle):
		var new_rotation = Basis(rotation_axis.normalized(), rotation_angle)
		self.model.transform.basis = new_rotation * self.model.transform.basis

func rot_y_model(delta, angle_accel):
	### Rotate y so model looks into walk direction:
	var angle = 0.0
	if not self.current_dir == Vector3.ZERO:
		angle = Vector2(self.current_dir.x, self.current_dir.z).angle()
	else:
		angle = Vector2(self.velocity.x, self.velocity.z).angle()
	self.model.rotation.y = lerp_angle(self.model.rotation.y, 
										PI/2.0 - angle,
										angle_accel/10.0 * delta)

func show_heal_particles():
	if self.particle_cool_down_timer.time_left <= 0.0:
		var heal_part = self.HealParticles.instantiate()
		self.model.add_child(heal_part)
		self.particle_cool_down_timer.start()

func update_soap_thickness():
	var life_percent = PlayerStats.soap_amount / PlayerStats.MaxDashMeter
	self.soap.scale.y = lerp(self.FinalScaleY, 1.0, life_percent)
	self.soap.position.y = lerp(self.FinalShiftSoapY, self.OriginalShiftSoapY, life_percent)
	self.bubble_boy.position.y = lerp(self.FinalShiftBoyY, self.OriginalShiftBoyY, life_percent)
	self.soap_bubbles.position.y = lerp(self.FinalShiftParticleY, self.OriginalShiftParticleY, life_percent)
#################################################################
### Controlls
func _physics_process(delta):
	match self.current_state:
		self.States.GROUNDED:
			self.ground_move(delta)
		self.States.JUMPING:
			self.jump_move(delta)
		self.States.FALLING:
			self.fall_move(delta)
		self.States.DEAD:
			self.dead_move(delta)
		self.States.GRINDING:
			self.grind_move(delta)

	# set current wall angle to enable drive on walls
	var velocity_scale = (self.velocity.length() - self.UnderVelocityAngle) / self.VelocityScale
	var new_angle = clamp(
		self.WallAngleMin + velocity_scale * WallAngleStep, 
		self.WallAngleMin, self.WallAngleMax)
	if self.is_on_floor(): new_angle = max(new_angle, self.get_floor_angle())
	self.set_deferred("floor_max_angle", new_angle)
	
	self.update_soap_thickness()
	
	if PlayerStats.soap_amount <= 0.0:
		self.velocity.x = 0.0
		self.velocity.z = 0.0
		self.current_state = self.States.DEAD
		self.animation_player.play("Death_Ground")

func get_player_input(max_velo, accel, delta):
	self.current_dir.x = -Input.get_action_strength("Left") + Input.get_action_strength("Right")
	self.current_dir.z = -Input.get_action_strength("Forward") + Input.get_action_strength("Backward")
	var dir_len = self.current_dir.length()
	self.current_dir = self.current_dir.rotated(Vector3.UP, self.spring_arm_3d.rotation.y)
	if dir_len > 1:
		self.current_dir /= dir_len
	if dir_len > 0.1:
		self.velocity = self.velocity.move_toward(max_velo * self.current_dir, 
													accel * delta)

	self.check_dash(delta)


func check_dash(delta):
	if Input.is_action_pressed("Dash") and PlayerStats.soap_amount > 0 and not self.current_dir == Vector3.ZERO:
		if not self.was_dashing_before:
			self.animation_player.play("Boost_Start")
			self.animation_player.queue("Boost_active")
			self.was_dashing_before = true
		elif len(self.animation_player.get_queue()) == 0:
			self.animation_player.play("Boost_active")
		PlayerStats.soap_amount -= PlayerStats.DashCost * delta
		self.dash_shape.set_deferred("disabled", false)
		var y_velo = self.velocity.y
		self.velocity = self.velocity.move_toward( 
			self.DashVelocity*self.current_dir, 
			self.DashAcceleration*delta)
		self.velocity.y = y_velo
	else:
		if self.was_dashing_before:
			self.was_dashing_before = false
			self.animation_player.play("Boost_end")
		self.dash_shape.set_deferred("disabled", true)

func ground_move(delta):
	self.soap_bubbles.emitting = (self.velocity.length() > 3)
	self.get_player_input(self.MaxVelocity, self.Acceleration, delta)
	PlayerStats.soap_amount -= PlayerStats.WalkCost
	self.velocity.y = self.Gravity * delta
	
	if self.get_floor_angle() >= self.WallAngleSlide:
		var slide_accel = 3.0*Vector3(0 ,self.Gravity, 0.0).slide(self.get_floor_normal())
		self.velocity += delta * slide_accel
	
	var none_rotated_velo = self.velocity
	var basis_rot = Quaternion(self.transform.basis.y, self.get_floor_normal()).normalized()
	self.velocity = basis_rot * self.velocity
	
	self.move_and_slide()
	self.velocity = none_rotated_velo
	
	self.rot_y_model(delta, self.Acceleration)
	
	self.velocity = self.velocity.move_toward(Vector3.ZERO, self.Friction * delta)
	
	self.control_cam(delta)
	self.current_floor_normal = self.get_floor_normal()
	self.tilt_model(self.get_floor_normal())
	
	if Input.is_action_just_pressed("Jump"):
		self.start_jump()
		if self.get_floor_angle() <= PI/8.0:
			self.velocity += 2.0*self.JumpStrength * self.current_floor_normal
		else:
			self.velocity = basis_rot * self.velocity
			self.velocity += self.JumpStrength * self.current_floor_normal
		self.global_position += 0.1 * self.current_floor_normal
	elif not self.is_on_floor():
		self.coyote_timer.start(self.CoyoteTime)
		self.current_state = self.States.FALLING


func start_jump():
	self.current_state = self.States.JUMPING
	PlayerStats.soap_amount -= PlayerStats.JumpCost
	self.start_angle_jump = fposmod(self.model.rotation.y - PI, 2*PI)
	if not Input.is_action_pressed("Dash"):
		self.animation_player.play("Jump")


func jump_move(delta):
	if self.velocity.y < 0: self.soap_bubbles.emitting = false
	
	self.get_player_input(self.MaxVelocity, self.AirAcceleration, delta)
	
	self.velocity.y += self.AirGravity * delta
	self.move_and_slide()
	self.prev_angle = self.model.rotation.y
	self.rot_y_model(delta, 4.0*self.Acceleration)

	self.trick_360(self.prev_angle, self.model.rotation.y)
	self.trick_360(self.model.rotation.y, self.prev_angle)
	
	self.velocity = self.velocity.move_toward(Vector3.ZERO, self.AirFriction * delta)
	
	self.control_cam(delta)
	self.current_floor_normal = self.current_floor_normal.move_toward(
		Vector3.UP, delta * self.AirAcceleration / 5.0
	)
	self.tilt_model(self.current_floor_normal)
	
	if self.is_on_floor():
		self.animation_player.play("IdleMove")
		self.current_state = self.States.GROUNDED


func trick_360(angle_1, angle_2):
	var mod_angle_1 = fposmod(angle_1 - self.start_angle_jump, 2*PI)
	var mod_angle_2 = fposmod(angle_2 - self.start_angle_jump, 2*PI)
	if mod_angle_1 < 2*PI and mod_angle_1 >= PI:
		if mod_angle_2 >= 0 and mod_angle_2 < PI:
			PlayerStats.soap_amount += PlayerStats.Trick360AirSoap

func fall_move(delta):
	self.soap_bubbles.emitting = false
	self.get_player_input(self.MaxVelocity, self.AirAcceleration / 2.0, delta)
	
	self.velocity.y += 2.0*self.AirGravity * delta
	self.move_and_slide()
	self.rot_y_model(delta, self.Acceleration)
	
	self.velocity = self.velocity.move_toward(Vector3.ZERO, self.AirFriction * delta)
	
	self.control_cam(delta)
	self.current_floor_normal = self.current_floor_normal.move_toward(
		Vector3.UP, delta * self.AirAcceleration / 5.0
	)
	self.tilt_model(self.current_floor_normal)
	
	if Input.is_action_just_pressed("Jump") and self.coyote_timer.time_left:
		self.start_jump()
		self.velocity -= self.JumpStrength * Vector3.UP
		self.global_position += 0.1 * self.current_floor_normal
	if self.is_on_floor():
		self.animation_player.play("IdleMove")
		self.current_state = self.States.GROUNDED


func dead_move(delta):
	self.soap_bubbles.emitting = false
	self.velocity += Vector3(0, self.Gravity, 0) * delta
	self.move_and_slide()
	self.head_marker.position = lerp(self.head_marker.position, 
		self.DeadHeadPos, 2.0*delta)
	self.control_cam(delta)
	
	if not self.animation_player.is_playing():
		PlayerStats.emit_signal("player_died")


func grind_move(delta):
	self.soap_bubbles.emitting = true
	self.velocity.y = self.Gravity * delta
	
	self.velocity *= (1.0 + 1.*delta)
	self.move_and_slide()
	
	var grind_angle = Vector2(self.velocity.x, self.velocity.z).angle()
	self.model.rotation.y = grind_angle
	
	self.velocity = self.velocity.move_toward(Vector3.ZERO, self.GrindFriction * delta)
	
	self.control_cam(delta)
	self.tilt_model(Vector3.UP)
	
	if Input.is_action_just_pressed("Jump"):
		self.start_jump()
		self.velocity += self.JumpStrength * self.current_floor_normal
		self.global_position += 0.1 * self.current_floor_normal
