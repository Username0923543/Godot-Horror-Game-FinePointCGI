extends CharacterBody3D


const SPEED = 5.0
const CROUCHSPEED = 3.0
const JUMP_VELOCITY = 4
@export var sensitivity = 4
var crouched : bool
var flashlighton : bool
var mouseclamp = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	
	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed = SPEED
	
	if Input.is_action_pressed("Escape"):
		if mouseclamp:
			mouseclamp = false
		else:
			mouseclamp = true
	
	if Input.is_action_pressed("Crouch"):
		speed = CROUCHSPEED
		if crouched:
			var space_state = get_world_3d().direct_space_state
			var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(position, position + Vector3(0,2,0), 1, [self]))
			if result.size() == 0:
				$AnimationPlayer.play_backwards("Crouch")
				crouched = false
		else:
			$AnimationPlayer.play("Crouch")
			crouched = true
	
	
	if Input.is_action_just_pressed("Flashlight"):
		if flashlighton:
			$AnimationPlayer.play("HideFlashlight")
			flashlighton = false
		else:
			$AnimationPlayer.play("ShowFlashlight")
			flashlighton = true
		
		
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _input(event):
	if mouseclamp :
		if(event is InputEventMouseMotion):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			rotation.y -= event.relative.x / 1000 * sensitivity
			$Camera3D.rotation.x -= event.relative.y / 1000 * sensitivity
			rotation.x = clamp(rotation.x,PI/-2,PI/2)
	if !mouseclamp:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		pass

