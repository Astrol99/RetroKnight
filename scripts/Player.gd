extends KinematicBody2D

onready var _sprite = $Sprite
onready var _animation_player = $AnimationPlayer
onready var _animation_state = $AnimationTree.get("parameters/playback")

export var ACCELERATION : float = 500.0
export var MAX_SPEED : float = 150.0
export var FRICTION : float = 0.25
export var GRAVITY : float = 400.0
export var JUMP_FORCE : float = 200.0

var velocity : Vector2 = Vector2.ZERO

func _physics_process(delta):		
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	# Horizontal movement
	if x_input != 0:
		velocity.x += x_input * ACCELERATION * delta
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
		_sprite.flip_h = x_input < 0
		
		if is_on_floor():
			_animation_state.travel("run")
	else:
		if is_on_floor():
			_animation_state.travel("idle")

	if is_on_floor():
		# Friction
		if x_input == 0:	
			velocity.x = lerp(velocity.x, 0, FRICTION)
		
		# Jump
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = -JUMP_FORCE
			_animation_state.travel("jump")

	velocity.y += GRAVITY * delta
	
	
	velocity = move_and_slide(velocity, Vector2.UP)
