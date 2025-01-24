extends CharacterBody3D

enum States {JUMPING, FALLING, GROUNDED, FAST, DEAD}

const WallAngleMin = PI/8
const WallAngleMax = PI/2.5
const WallAngleStep = (WallAngleMax - WallAngleMin) / 2.0

const WallAngleSlide = PI/6.0
const SlideAmount = 25.0

const Acceleration = 20.0
const DashAcceleration = 80.0
const AirAcceleration = 10.0

const Friction = 2.0
const AirFriction = 0.5

const MaxVelocity = 35.0
const DashVelocity = 50.0
const JumpStrength = 25.0
const CoyoteTime = 0.1

const Gravity = -80.0
const AirGravity = -40.0

const CamSpeedRot = 5.0
const MinCamAngle = 0.5 # min angle for camera up
const MaxCamAngle = -1.0 # max angle for camera down
const MaxCamRotDifference = -PI/8.0

const MinArmDistance = 8.0
const MaxArmDistance = 16.0
const VelocityScale = 10.0
const UnderVelocityAngle = 10.0
### Controll sutff
var current_dir := Vector3.ZERO
var current_floor_normal := Vector3.UP
var current_state := States.FALLING

@onready var coyote_timer : Timer = $CoyoteTimer

### Camera
@onready var spring_arm_3d : SpringArm3D = $SpringArm3D
@onready var camera_3d : Camera3D = $SpringArm3D/Node3D/Camera3D

### Model:
@onready var model = $Model
@onready var model_rot_y = $Model/ModelRotY
@onready var head_marker = $Model/ModelRotY/HeadMarker


func _ready():
	pass


func control_cam(delta):
	var cam_rot_y = Input.get_action_strength("CamLeft") - Input.get_action_strength("CamRight")
#	var angle_diff = abs(self.spring_arm_3d.global_rotation.y + self.model_rot_y.global_rotation.y) 
#	if cam_rot_y == 0 and angle_diff > self.MaxCamRotDifference:
#		self.spring_arm_3d.global_rotation.y = lerp_angle(
#			self.spring_arm_3d.global_rotation.y, 
	#		self.model_rot_y.global_rotation.y, 
	#		5.0*delta)
	#else:
	self.spring_arm_3d.rotation.y = lerp_angle(self.spring_arm_3d.rotation.y, 
						self.spring_arm_3d.rotation.y + cam_rot_y * self.CamSpeedRot, 
						delta)

	var cam_rot_x = Input.get_action_strength("CamUp") - Input.get_action_strength("CamDown")
	cam_rot_x = clamp(self.spring_arm_3d.rotation.x + cam_rot_x, self.MaxCamAngle, self.MinCamAngle)
	self.spring_arm_3d.rotation.x = lerp_angle(
		self.spring_arm_3d.global_rotation.x, cam_rot_x, delta)
		
	self.camera_3d.look_at(self.head_marker.global_position)
	
	var distance_step = (self.MaxArmDistance - self.MinArmDistance) / 3.0
	var velocity_scale = (self.velocity.length() - self.UnderVelocityAngle) / self.VelocityScale
	self.spring_arm_3d.spring_length = clamp(
		self.MinArmDistance + distance_step * velocity_scale, 
		self.MinArmDistance, self.MaxArmDistance)


func tilt_model(up_vector):
	var b_rotation := Quaternion(self.model.transform.basis.y, up_vector)
	self.model.transform.basis = Basis(b_rotation * self.model.basis.get_rotation_quaternion())

func rot_y_model(delta, angle_accel):
	### Rotate y so model looks into walk direction:
	if not self.current_dir == Vector3.ZERO:
		var angle = Vector2(self.current_dir.x, self.current_dir.z).angle()#Vector2(self.velocity.x, self.velocity.z).angle()
		self.model.rotation.y = lerp_angle(self.model.rotation.y, 
												PI/2.0 - angle,
												angle_accel/10.0 * delta)

func _physics_process(delta):
	match self.current_state:
		self.States.GROUNDED:
			self.ground_move(delta)
		self.States.JUMPING:
			self.jump_move(delta)
		self.States.FALLING:
			self.fall_move(delta)

	# set current wall angle to enable drive on walls
	var velocity_scale = (self.velocity.length() - self.UnderVelocityAngle) / self.VelocityScale
	var new_angle = clamp(
		self.WallAngleMin + velocity_scale * WallAngleStep, 
		self.WallAngleMin, self.WallAngleMax)
	if self.is_on_floor(): new_angle = max(new_angle, self.get_floor_angle())
	self.set_deferred("floor_max_angle", new_angle)
	

func get_player_input(max_velo, accel, delta):
	self.current_dir.x = -Input.get_action_strength("Left") + Input.get_action_strength("Right")
	self.current_dir.z = -Input.get_action_strength("Forward") + Input.get_action_strength("Backward")
	var dir_len = self.current_dir.length()
	self.current_dir = self.current_dir.rotated(Vector3.UP, self.spring_arm_3d.rotation.y)
	if dir_len > 1:
		self.current_dir / dir_len
	if dir_len > 0.1:
		self.velocity = self.velocity.move_toward(max_velo * self.current_dir, 
													accel * delta)

	self.check_dash(delta)


func check_dash(delta):
	if Input.is_action_pressed("Dash") and PlayerStats.soap_amount > 0:
		PlayerStats.soap_amount -= PlayerStats.DashCost
		var y_velo = self.velocity.y
		self.velocity = self.velocity.move_toward( 
			self.DashVelocity*self.current_dir, 
			self.DashAcceleration*delta)
		self.velocity.y = y_velo

func ground_move(delta):
	self.get_player_input(self.MaxVelocity, self.Acceleration, delta)

	self.velocity.y = self.Gravity * delta
	
	if self.get_floor_angle() >= self.WallAngleSlide:
		var slide_accel = 5.0*Vector3(0 ,self.Gravity, 0.0).slide(self.get_floor_normal())
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
		self.current_state = self.States.JUMPING
		if self.get_floor_angle() <= PI/8.0:
			self.velocity += 2.0*self.JumpStrength * self.current_floor_normal
		else:
			self.velocity = basis_rot * self.velocity
			self.velocity += self.JumpStrength * self.current_floor_normal
		self.global_position += 0.1 * self.current_floor_normal
	elif not self.is_on_floor():
		self.coyote_timer.start(self.CoyoteTime)
		self.current_state = self.States.FALLING


func jump_move(delta):
	self.get_player_input(self.MaxVelocity, self.AirAcceleration, delta)
	
	self.velocity.y += self.AirGravity * delta
	self.move_and_slide()
	self.rot_y_model(delta, self.Acceleration)
	
	self.velocity = self.velocity.move_toward(Vector3.ZERO, self.AirFriction * delta)
	
	self.control_cam(delta)
	self.current_floor_normal = self.current_floor_normal.move_toward(
		Vector3.UP, delta * self.AirAcceleration / 5.0
	)
	self.tilt_model(self.current_floor_normal)
	
	if self.is_on_floor():
		self.current_state = self.States.GROUNDED


func fall_move(delta):
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
		self.current_state = self.States.JUMPING
		self.velocity -= self.JumpStrength * Vector3.UP
		self.global_position += 0.1 * self.current_floor_normal
	if self.is_on_floor():
		self.current_state = self.States.GROUNDED
