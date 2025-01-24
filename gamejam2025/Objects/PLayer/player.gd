extends CharacterBody3D

enum States {JUMPING, FALLING, GROUNDED, FAST, DEAD}

const Acceleration = 15.0
const AirAcceleration = 5.0

const Friction = 5.0
const AirFriction = 1.0

const MaxVelocity = 75.0
const JumpStrength = 25.0

const Gravity = -80.0
const AirGravity = -40.0

const CamSpeedRot = 5.0
const MinCamAngle = 0.5 # min angle for camera up
const MaxCamAngle = -1.0 # max angle for camera down

const MinArmDistance = 8.0
const MaxArmDistance = 16.0
const VelocityScale = 10.0
### Controll sutff
var current_dir := Vector3.ZERO
var current_floor_normal := Vector3.UP
var current_state := States.GROUNDED

@onready var velocity_dir_marker = $Model/VelocityDirMarker

### Camera
@onready var spring_arm_3d : SpringArm3D = $SpringArm3D
@onready var camera_3d : Camera3D = $SpringArm3D/Node3D/Camera3D

### Model:
@onready var model = $Model
@onready var model_rot_y = $Model/ModelRotY


func _ready():
	pass


func control_cam(delta):
	var cam_rot_y = Input.get_action_strength("CamLeft") - Input.get_action_strength("CamRight")

	self.spring_arm_3d.rotation.y = lerp_angle(self.spring_arm_3d.rotation.y, 
						self.spring_arm_3d.rotation.y + cam_rot_y * self.CamSpeedRot, 
						delta)

	var cam_rot_x = Input.get_action_strength("CamUp") - Input.get_action_strength("CamDown")
	cam_rot_x = clamp(self.spring_arm_3d.rotation.x + cam_rot_x, self.MaxCamAngle, self.MinCamAngle)
	self.spring_arm_3d.rotation.x = lerp_angle(
		self.spring_arm_3d.global_rotation.x, cam_rot_x, delta)

	self.camera_3d.look_at(self.global_position)
	
	var distance_step = (self.MaxArmDistance - self.MinArmDistance) / 3.0
	var velocity_scale = (self.velocity.length() - 30.0) / self.VelocityScale
	self.spring_arm_3d.spring_length = clamp(
		self.MinArmDistance + distance_step * velocity_scale, 
		self.MinArmDistance, self.MaxArmDistance)


func tilt_model(up_vector):
	var b_rotation := Quaternion(self.model.transform.basis.y, up_vector)
	self.model.transform.basis = Basis(b_rotation * self.model.basis.get_rotation_quaternion())

func rot_y_model(delta, angle_accel):
	### Rotate y so model looks into walk direction:
	var angle = Vector2(self.velocity.x, self.velocity.z).angle()
	self.model.rotation.y = lerp_angle(self.model.rotation.y, 
											PI/2.0 - angle,
											angle_accel * delta)

func _physics_process(delta):
	match self.current_state:
		self.States.GROUNDED:
			self.ground_move(delta)
		self.States.JUMPING:
			self.jump_move(delta)


func get_player_input(max_velo, accel, delta):
	self.current_dir.x = -Input.get_action_strength("Left") + Input.get_action_strength("Right")
	self.current_dir.z = -Input.get_action_strength("Forward") + Input.get_action_strength("Backward")
	var dir_len = self.current_dir.length()
	self.current_dir = self.current_dir.rotated(Vector3.UP, self.spring_arm_3d.rotation.y)
	if dir_len > 1:
		self.current_dir / dir_len
	if dir_len > 0.05:
		self.velocity = self.velocity.move_toward(max_velo * self.current_dir, 
													accel * delta)

func ground_move(delta):
	self.get_player_input(self.MaxVelocity, self.Acceleration, delta)
	self.velocity.y = self.Gravity * delta
	
	var none_rotated_velo = self.velocity
	self.velocity_dir_marker.position = self.velocity
	self.velocity = (self.velocity_dir_marker.global_position - self.global_position)
	self.move_and_slide()
	self.velocity = none_rotated_velo
	
	self.rot_y_model(delta, self.Acceleration)
	self.velocity = self.velocity.move_toward(Vector3.ZERO, self.Friction * delta)
	
	self.control_cam(delta)
	self.current_floor_normal = self.get_floor_normal()
	self.tilt_model(self.get_floor_normal())
	
	if Input.is_action_just_pressed("Jump"):
		self.current_state = self.States.JUMPING
		self.velocity = self.JumpStrength * self.current_floor_normal
		self.global_position += 0.1 * self.current_floor_normal


func jump_move(delta):
	self.get_player_input(self.MaxVelocity, self.AirAcceleration, delta)
	
	self.velocity.y += self.AirGravity * delta
	self.move_and_slide()
	self.rot_y_model(delta, self.Acceleration)
	
	self.velocity = self.velocity.move_toward(Vector3.ZERO, self.AirFriction * delta)
	
	self.control_cam(delta)
	self.current_floor_normal = self.current_floor_normal.move_toward(
		Vector3.UP, delta * self.AirAcceleration
	)
	self.tilt_model(self.current_floor_normal)
	
	if self.is_on_floor():
		self.current_state = self.States.GROUNDED
