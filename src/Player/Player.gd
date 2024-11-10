extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005

# Get the gravity from the project settings to be synced with RigidBody nodes.
const gravity:float = 9.8
@onready var _head = $Head 
@onready var _head_camera = $Head/Camera3D

const TILT_FREQ: float = 2.0
const TILT_AMPL: float = 0.08
var tilt_factor: float = 0.0

func _ready() -> void: 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event:InputEvent):
	if event is InputEventMouseMotion:
		self._head.rotate_y(-event.relative.x * SENSITIVITY)
		self._head_camera.rotate_x(-event.relative.y * SENSITIVITY)
		self._head_camera.rotation.x = clamp(
			self._head_camera.rotation.x, 
			deg_to_rad(-50), 
			deg_to_rad(90),
		)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (
		self._head.transform.basis * Vector3(
			input_dir.x, 
			0, input_dir.y
		)
	).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	self._head_camera.transform.origin = self._head_tilt(delta)
	move_and_slide()

func _head_tilt(delta) -> Vector3:
	self.tilt_factor += delta * self.velocity.length() * float(self.is_on_floor())
	var pos = Vector3.ZERO
	pos.y = sin(self.tilt_factor * TILT_FREQ) * TILT_AMPL
	pos.x = cos(self.tilt_factor * TILT_FREQ / 2) * TILT_AMPL
	return pos
