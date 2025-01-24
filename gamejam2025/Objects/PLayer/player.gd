extends CharacterBody3D

enum States {JUMPING, FALLING, GROUNDED, FAST, DEAD}

const Acceleration = 10.0
const Friction = 5.0
const MaxVelocity = 50.0
const JumpStrength = 50.0

const Gravity = -80.0

const CamSpeedRot = 5.0

### Controll sutff
var current_dir := Vector3.ZERO
var current_state := States.GROUNDED

### Camera
@onready var spring_arm_3d : SpringArm3D = $SpringArm3D
@onready var camera_3d : Camera3D = $SpringArm3D/Node3D/Camera3D

### Model:
@onready var model = $Model
@onready var model_rot_y = $Model/ModelRotY


func _ready():
	pass


func control_cam(delta):
	var x_dir = Input.get_action_strength("CamLeft") - Input.get_action_strength("CamRight")
	self.spring_arm_3d.rotation.y = lerp_angle(self.spring_arm_3d.rotation.y, 
						self.spring_arm_3d.rotation.y + x_dir * self.CamSpeedRot, 
						delta)
	self.camera_3d.look_at(self.global_position)

func tilt_model(up_vector):
	pass

func _physics_process(delta):
	match self.current_state:
		self.States.GROUNDED:
			self.ground_move(delta)


func ground_move(delta):
	self.current_dir.x = -Input.get_action_strength("Left") + Input.get_action_strength("Right")
	self.current_dir.z = -Input.get_action_strength("Forward") + Input.get_action_strength("Backward")
	var dir_len = self.current_dir.length()
	self.current_dir = self.current_dir.rotated(Vector3.UP, self.spring_arm_3d.rotation.y)
	if dir_len > 1:
		self.current_dir / dir_len
	if dir_len > 0.05:
		self.velocity = self.velocity.move_toward(self.MaxVelocity * self.current_dir, 
													self.Acceleration * delta)
	
	self.velocity.y += self.Gravity * delta
	self.move_and_slide()
	
	### Rotate y so model looks into walk direction:
	var angle = Vector2(self.velocity.x, self.velocity.z).angle()
	self.model_rot_y.rotation.y = angle
	
	self.velocity = self.velocity.move_toward(Vector3.ZERO, self.Friction * delta)
	
	self.control_cam(delta)
