extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D

const SPEED = 220.0
const JUMP_VELOCITY = -240.0
const DASH_SPEED = 440.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 1.0
const ATTACK_COOLDOWN = 0.5

#Dash
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var is_dashing = false

#Attack
var attack_cooldown_timer = 0.0
var is_attacking = false
var attack_direction = 1  # Store direction during attack


func _physics_process(delta: float) -> void:
	# Update timers
	if dash_timer > 0:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle dash
	if Input.is_action_just_pressed("Dash") and dash_cooldown_timer <= 0:  # Shift key
		start_dash()

	# Handle attack (only on floor)
	if Input.is_action_just_pressed("Attack") and attack_cooldown_timer <= 0 and is_on_floor():
		start_attack()

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation_player.play("Jump")

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("Left", "Right")
	
	# Handle movement (skip if dashing or attacking)
	if not is_dashing and not is_attacking:
		if direction:
			velocity.x = direction * SPEED
			# Flip sprite based on direction
			if direction < 0:  # Moving left
				sprite.flip_h = true
			else:  # Moving right
				sprite.flip_h = false
			# Play run animation when moving horizontally and on floor
			if is_on_floor() and animation_player.current_animation != "Run" and animation_player.current_animation != "Jump":
				animation_player.play("Run")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	elif is_attacking:
		# During attack, maintain the direction and stop movement
		velocity.x = 0
		# Keep sprite facing the same direction as when attack started
		sprite.flip_h = (attack_direction < 0)

	# Handle animations based on player state
	update_animation()

	move_and_slide()

func start_dash():
	var direction := Input.get_axis("Left", "Right")
	if direction == 0:
		# If no direction input, dash in the direction the sprite is facing
		direction = -1 if sprite.flip_h else 1
	
	is_dashing = true
	dash_timer = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN
	velocity.x = direction * DASH_SPEED
	
	# Flip sprite based on dash direction
	if direction < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	# Play dash animation
	animation_player.play("Dash")

func start_attack():
	is_attacking = true
	attack_cooldown_timer = ATTACK_COOLDOWN
	
	# Store current sprite direction for attack
	attack_direction = -1 if sprite.flip_h else 1
	
	# Stop horizontal movement during attack
	velocity.x = 0
	
	# Play attack animation
	animation_player.play("Attack")
	
	# Set is_attacking to false when attack animation finishes
	await animation_player.animation_finished
	is_attacking = false

func update_animation():
	# Don't change animation if dashing or attacking
	if is_dashing or is_attacking:
		return
	
	# Don't change animation if jump animation is playing
	if animation_player.current_animation == "Jump" and animation_player.is_playing():
		return
	
	# Handle falling animation
	if not is_on_floor() and velocity.y > 0:
		if animation_player.current_animation != "Fall":
			animation_player.play("Fall")
		return
	
	# Handle idle animation when not moving and on floor
	if is_on_floor() and abs(velocity.x) < 1.0:
		if animation_player.current_animation != "Idle":
			animation_player.play("Idle")
