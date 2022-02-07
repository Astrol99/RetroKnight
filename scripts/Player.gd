extends KinematicBody2D

onready var _sprite = $Sprite
onready var _animation_tree = $AnimationTree
onready var _animation_state = _animation_tree.get("parameters/playback")

export var ACCELERATION : float = 500.0
export var MAX_SPEED : float = 150.0
export var FRICTION : float = 0.25
export var GRAVITY : float = 400.0
export var JUMP_FORCE : float = 200.0

enum {
	MOVE,
	ATTACK
}

var state = MOVE
var velocity : Vector2 = Vector2.ZERO

func _ready():
	_animation_tree.active = true

func _process(delta):
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)

func move_state(delta):	
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	# Horizontal movement
	if x_input != 0:
		velocity.x += x_input * ACCELERATION * delta
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
		_sprite.flip_h = x_input < 0
		
		if is_on_floor():
			_animation_state.travel("run")
			
	elif x_input == 0 and is_on_floor():
		velocity.x = lerp(velocity.x, 0, FRICTION)
		_animation_state.travel("idle")

	if is_on_floor():
		# Jump
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = -JUMP_FORCE
			_animation_state.travel("jump")

	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if Input.is_action_just_pressed("player_attack"):
		state = ATTACK

func attack_state(delta):
	velocity = Vector2.ZERO
	_animation_state.travel("attack")

func attack_animation_finished():
	state = MOVE
	
