extends KinematicBody2D

export var acceleration : float = 512.0
export var max_speed : float = 64.0
export var friction : float = 0.25
export var air_resistance : float = 0.02
export var gravity : float = 200.0
export var jump_force : float = 128.0

var motion : Vector2 = Vector2.ZERO

#onready const sprite = $Sprite

func _physics_process(delta):
	# Horizontal movement
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if x_input != 0:
		motion.x += x_input * acceleration * delta
		motion.x = clamp(motion.x, -max_speed, max_speed)
		#sprite.flip_h = x_input < 0
	
	# Gravity
	motion.y += gravity * delta
	
	# Jump
	if is_on_floor():
		if x_input == 0:
			motion.x = lerp(motion.x, 0, friction)
		
		if Input.is_action_just_pressed("ui_up"):
			motion.y = -jump_force
	else:
		if Input.is_action_just_pressed("ui_up") and motion.y < -jump_force/2:
			motion.y = -jump_force/2
		
		if x_input == 0:
			motion.x = lerp(motion.x, 0, air_resistance)
	
	motion = move_and_slide(motion, Vector2.UP)
