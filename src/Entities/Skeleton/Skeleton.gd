extends KinematicBody2D

onready var _stats = $Stats
onready var _sprite = $Sprite
onready var _animation_player = $AnimationPlayer
onready var _player_detection_zone = $PlayerDetectionZone
onready var _hurtbox = $Hurtbox
onready var _hitbox = $Hitbox
onready var _hitbox_range = $HitboxRange
onready var _soft_collision = $SoftCollision
onready var _wander_controller = $WanderController

export var ACCELERATION = 200
export var MAX_SPEED = 200
export var FRICTION = 200
export var GRAVITY = 500

enum States {
	IDLE,
	WANDER,
	CHASE,
	TAKEHIT,
	DEATH,
	ATTACK,
	SHIELD
}
onready var state = pick_rand_state([States.IDLE, States.WANDER])

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

	match state:
		States.IDLE:
			if _animation_player.current_animation != "idle":
				_animation_player.play("idle")
			seek_player()
			
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			
			if _wander_controller.get_time_left() == 0:
				update_wander()
				
		States.WANDER:
			if _animation_player.current_animation != "run":
				_animation_player.play("run")
			seek_player()
			
			if _wander_controller.get_time_left() == 0:
				update_wander()
				
			accelerate_towards_point(delta, _wander_controller.target_position)
			
			if global_position.distance_to(_wander_controller.target_position) <= MAX_SPEED * delta:
				update_wander()
				
		States.CHASE:
			if _animation_player.current_animation != "run":
				_animation_player.play("run")
			
			var player = _player_detection_zone.player
			if player:
				accelerate_towards_point(delta, player.global_position)
			else:
				state = States.IDLE
				
		States.ATTACK:
			if _animation_player.current_animation != "attack":
				_animation_player.play("attack")
				
		States.SHIELD:
			if _animation_player.current_animation != "shield":
				_animation_player.play("shield")
				
		States.TAKEHIT:
			if _animation_player.current_animation != "takehit":
				_animation_player.play("takehit")
		States.DEATH:
			if _animation_player.current_animation != "death":
				_animation_player.play("death")

	if _soft_collision.is_colliding():
		velocity += _soft_collision.get_push_vector() * delta * 400
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity)

func accelerate_towards_point(delta, point):
	var direction = position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	if velocity.x < 0:
		_sprite.flip_h = true
		_hitbox.rotation_degrees = 180
		_hitbox_range.rotation_degrees = 180
	else:
		_sprite.flip_h = false
		_hitbox.rotation_degrees = 0
		_hitbox_range.rotation_degrees = 0

func update_wander():
	state = pick_rand_state([States.IDLE, States.WANDER])
	_wander_controller.start_wander_timer(rand_range(1,3))

func seek_player():
	if _player_detection_zone.player:
		state = States.CHASE

func pick_rand_state(state_list: Array):
	return state_list[randi() % state_list.size()]

func _on_Hurtbox_area_entered(area):
	
	# Only hurt skeleton while it is in attack state/animation
	if state == States.ATTACK:
		state = States.TAKEHIT
		_stats.health -= area.damage
		knockback = area.knockback_vector * 100
		
	# Skeleton special move: SHIELD to any attack besides being in attack state
	else:
		state = States.SHIELD
		velocity = Vector2.ZERO
		knockback = area.knockback_vector * 50
		
	_hurtbox.start_invincibility(0.4)

func _on_HitboxRange_area_entered(_area):
	velocity = Vector2.ZERO
	state = States.ATTACK

func _on_Stats_no_health(_value):
	velocity = Vector2.ZERO
	state = States.DEATH

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"attack":
			state = States.IDLE
		"takehit":
			state = States.IDLE
		"shield":
			state = States.IDLE
		"death":
			queue_free()
