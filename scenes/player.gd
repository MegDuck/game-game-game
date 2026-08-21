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
var lookSensitivity : float = 20
# vectors
var mouseDelta : Vector2 = Vector2()
# player components
@onready var camera = get_node("Camera")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input (event):
	# did the mouse move?
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

# called every frame
func _process(delta):
	# Convert mouse input (pixels) * sensitivity into degrees, then into radians for Godot 4
	camera.rotation.x -= deg_to_rad(mouseDelta.y * lookSensitivity * delta)
	
	# Clamp the camera's pitch. 
	# Assuming minLookAngle and maxLookAngle are in degrees (e.g., -85 and 85),
	# we convert them to radians so they clamp the radian property correctly.
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(minLookAngle), deg_to_rad(maxLookAngle))
	
	# Rotate the parent node (usually the player body) along the Y axis (Yaw)
	rotation.y -= deg_to_rad(mouseDelta.x * lookSensitivity * delta)
	
	mouseDelta = Vector2()

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
