extends KinematicBody2D

onready var _animated_sprite = $AnimatedSprite

export var acceleration : float = 512.0
export var max_speed : float = 64.0
export var friction : float = 0.25
export var gravity : float = 200.0
export var jump_force : float = 128.0

var motion : Vector2 = Vector2.ZERO

func _physics_process(delta):
	# Get input of left and right
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if Input.is_action_just_pressed("player_attack"):
		set_anim("attack")
	
	# Horizontal movement
	if x_input != 0:
		motion.x += x_input * acceleration * delta
		motion.x = clamp(motion.x, -max_speed, max_speed)
		_animated_sprite.flip_h = x_input < 0
	
	# Gravity
	motion.y += gravity * delta
	
	if is_on_floor():
		# Slide friction
		if x_input == 0:	
			motion.x = lerp(motion.x, 0, friction)
		
		# Jump
		if Input.is_action_just_pressed("ui_up"):
			motion.y = -jump_force
	
	motion = move_and_slide(motion, Vector2.UP)
	
	# Main animation
	if is_on_floor():
		if x_input == 0:
			set_anim("idle")
		else:
			set_anim("run")
	else:
		if motion.y < 0:
			set_anim("jump")
		else:
			set_anim("fall")

func set_anim(anim):
	if _animated_sprite.animation != anim:
		_animated_sprite.play(anim)
	else:
		return
