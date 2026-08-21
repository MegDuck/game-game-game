extends CharacterBody3D

# stats
var curHp : int = 10
var maxHp : int = 10
var ammo : int = 15
var score : int = 0
# physics
var moveSpeed : float = 5.0
var jumpForce : float = 5.0
var gravity : float = 12.0
# cam look
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 0.5
# vectors
var mouseDelta : Vector2 = Vector2()
# player components
@onready var camera = get_node("Camera")

#Headbobbing Controls
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

#FOV Controls
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

@export var bob_frequency := 2.0  # How fast the bobbing is
@export var bob_amplitude := 0.08 # How high/low the camera bobs
@export var sway_amplitude := 0.05 # How much the camera sways left/right

# We need to store the camera's default position so we can return to it
var base_camera_pos : Vector3
var bob_time := 0.0


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	camera.position = Vector3.ZERO 
	base_camera_pos = camera.position

func _input (event):
	# did the mouse move?
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

func _process(delta):
	# --- YOUR EXISTING MOUSE LOOK CODE ---
	camera.rotation.x -= deg_to_rad(mouseDelta.y * lookSensitivity)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(minLookAngle), deg_to_rad(maxLookAngle))
	rotation.y -= deg_to_rad(mouseDelta.x * lookSensitivity)
	mouseDelta = Vector2()
	
	# --- CAMERA BOBBING LOGIC ---
	# 1. Check if the player is moving on the ground
	# (Assuming 'velocity' is your CharacterBody3D's velocity)
	var is_moving = velocity.length() > 1.0 and is_on_floor()
	
	if is_moving:
		# Increase the bob timer
		bob_time += delta * bob_frequency
		
		# Calculate vertical (Up/Down) and horizontal (Left/Right) offsets
		var bob_offset_y = sin(bob_time * TAU) * bob_amplitude
		var bob_offset_x = cos(bob_time * TAU * 0.5) * sway_amplitude
		
		# Apply the offsets to the camera's local position
		camera.position = Vector3(
			base_camera_pos.x + bob_offset_x,
			base_camera_pos.y + bob_offset_y,
			base_camera_pos.z
		)
	else:
		# If not moving, smoothly reset camera back to center
		bob_time = 0.0
		camera.position = camera.position.lerp(base_camera_pos, delta * 10.0)

# called every physics step
func _physics_process (delta):
	# reset the x and z velocity
	velocity.x = 0
	velocity.z = 0
	var input = Vector2()
	# movement inputs
	if Input.is_action_pressed("move_forward"):
		input.y -= 1
	if Input.is_action_pressed("move_backward"):
		input.y += 1
	if Input.is_action_pressed("move_left"):
		input.x -= 1
	if Input.is_action_pressed("move_right"):
		input.x += 1
	# normalize the input so we can't move faster diagonally
	input = input.normalized()

	# get our forward and right directions
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	
	# set the velocity
	velocity.z = (forward * input.y + right * input.x).z * moveSpeed
	velocity.x = (forward * input.y + right * input.x).x * moveSpeed
	# apply gravity
	velocity.y -= gravity * delta
	# move the player
	move_and_slide()
	
	# jump if we press the jump button and are standing on the floor
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jumpForce
