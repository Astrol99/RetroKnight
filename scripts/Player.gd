extends KinematicBody2D

onready var _sprite = $Sprite
onready var _animation_tree = $AnimationTree
onready var _animation_state = _animation_tree.get("parameters/playback")
onready var _hitbox = $Hitbox

const ACCELERATION : float = 500.0
const MAX_SPEED : float = 150.0
const FRICTION : float = 0.25
const GRAVITY : float = 400.0
const JUMP_FORCE : float = 200.0
const ROLL_SPEED : float = 100.0

# States
enum {
	MOVE,
	ATTACK,
	ROLL
}
var state = MOVE

var velocity : Vector2 = Vector2.ZERO
var roll_vector : Vector2 = Vector2.RIGHT

func _ready():
	_animation_tree.active = true

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)
		ROLL:
			roll_state(delta)
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func move_state(delta):	
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	# Horizontal movement
	if x_input != 0:
		roll_vector = Vector2(x_input, 0)
		velocity.x += x_input * ACCELERATION * delta
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
		# Flip sprite and hitbox position
		
		if x_input < 0:
			_sprite.flip_h = true
			_hitbox.position.x = -abs(_hitbox.position.x) # Always be negative
		else:
			_sprite.flip_h = false
			_hitbox.position.x = abs(_hitbox.position.x) # Always be positive
		
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
		# Roll
		if Input.is_action_just_pressed("roll"):
			state = ROLL
	else:
		_animation_state.travel("fall")
	
	# Attack
	if Input.is_action_just_pressed("player_attack"):
		state = ATTACK

func attack_state(delta):
	_animation_state.travel("attack")

func attack_animation_finished():
	state = MOVE

func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	_animation_state.travel("roll")
	
	velocity = move_and_slide(velocity)

func roll_animation_finished():
	state = MOVE
