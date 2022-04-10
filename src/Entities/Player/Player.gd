extends KinematicBody2D

onready var _sprite = $Sprite
onready var _animation_tree = $AnimationTree
onready var _animation_state = _animation_tree.get("parameters/playback")
onready var _sword_hitbox = $SwordHitbox
onready var _hurtbox = $Hurtbox
onready var _blink_animation_player = $BlinkAnimationPlayer
onready var _camera = get_parent().get_node("Camera2D")
onready var _camera_offset_default = _camera.offset
var stats = PlayerStats

export(float) var ACCELERATION : float = 500.0
export(float) var MAX_SPEED : float = 150.0
export(float) var FRICTION : float = 0.25
export(float) var GRAVITY : float = 400.0
export(float) var JUMP_FORCE : float = 225.0
export(float) var ROLL_SPEED : float = 100.0
export(float) var CAMERA_SHAKE : float = 1.0

# States
enum States {
	MOVE,
	ATTACK1,
	ATTACK2,
	ROLL,
	HIT,
	DEATH
}

export var state = States.MOVE

var velocity : Vector2 = Vector2.ZERO
var roll_vector : Vector2 = Vector2.RIGHT

func _ready():
	stats.connect("no_health", self, "_on_Stats_no_health")
	stats.connect("health_decreased", self, "_on_Stats_health_decrease")
	_animation_tree.active = true
	_sword_hitbox.knockback_vector = roll_vector
	stats._ready()

func _physics_process(delta):
	match state:
		States.ATTACK2:
			_animation_state.travel("attack2")
			
			_camera.set_offset(_camera_offset_default)
			if _sword_hitbox.get_overlapping_areas():
				_camera.set_offset(_camera.offset + Vector2( \
					rand_range(-1.0, 1.0) * CAMERA_SHAKE, \
					rand_range(-1.0, 1.0) * CAMERA_SHAKE \
				))
			
		States.ATTACK1:
			_animation_state.travel("attack1")
				
			_camera.set_offset(_camera_offset_default)
			if _sword_hitbox.get_overlapping_areas():
				_camera.set_offset(_camera.offset + Vector2( \
					rand_range(-1.0, 1.0) * CAMERA_SHAKE/2, \
					rand_range(-1.0, 1.0) * CAMERA_SHAKE/2 \
				))
			
			if Input.is_action_just_pressed("player_attack"):
				_animation_state.travel("attack2")
				state = States.ATTACK2
			
		States.MOVE:
			move_state(delta)
			
		States.ROLL:
			velocity = roll_vector * ROLL_SPEED
			_animation_state.travel("roll")
			velocity = move_and_slide(velocity)
			
		States.HIT:
			_animation_state.travel("hit")
			
			_camera.set_offset(_camera_offset_default)
			_camera.set_offset(_camera.offset + Vector2( \
				rand_range(-1.0, 1.0) * CAMERA_SHAKE, \
				rand_range(-1.0, 1.0) * CAMERA_SHAKE \
			))
			
		States.DEATH:
			_animation_state.travel("death")

	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func move_state(delta):	
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	# Horizontal movement
	if x_input != 0:
		roll_vector = Vector2(x_input, 0)
		_sword_hitbox.knockback_vector = Vector2(x_input, 0)
		
		velocity.x += x_input * ACCELERATION * delta
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
		# Flip sprite and hitbox position
		
		if x_input < 0:
			_sprite.flip_h = true
			_sword_hitbox.position.x = -abs(_sword_hitbox.position.x) # Always be negative
		else:
			_sprite.flip_h = false
			_sword_hitbox.position.x = abs(_sword_hitbox.position.x) # Always be positive
		
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
			state = States.ROLL
		
		# ATTACK1
		if Input.is_action_just_pressed("player_attack"):
			velocity = Vector2.ZERO
			state = States.ATTACK1
	else:
		# ATTACK1
		if Input.is_action_just_pressed("player_attack"):
			velocity = Vector2.DOWN * JUMP_FORCE * 2
			state = States.ATTACK1
		else: 
			_animation_state.travel("fall")

func _on_Hurtbox_area_entered(area):
	_sword_hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)
	velocity = Vector2.ZERO
	_hurtbox.start_invincibility(0.6)
	stats.health -= area.damage
	
func _on_Stats_health_decrease(_value):
	state = States.HIT

func _on_Stats_no_health(_value):
	_hurtbox.get_node("CollisionShape2D").set_deferred("disabled", true)
	_sword_hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)
	velocity = Vector2.ZERO
	state = States.DEATH

func _on_Hurtbox_invincibility_started():
	_blink_animation_player.play("Start")

func _on_Hurtbox_invincibility_ended():
	_blink_animation_player.play("Stop")
