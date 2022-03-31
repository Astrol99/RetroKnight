extends KinematicBody2D

onready var _stats = $Stats
onready var _animated_sprite = $AnimatedSprite
onready var _player_detection_zone = $PlayerDetectionZone
onready var _hurtbox = $Hurtbox
onready var _soft_collision = $SoftCollision
onready var _wander_controller = $WanderController
onready var _blink_animation_player = $BlinkAnimationPlayer

export var ACCELERATION = 50
export var MAX_SPEED = 500
export var FRICTION = 200

enum {
	IDLE,
	WANDER,
	CHASE
}
var state = CHASE

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

func _ready():
	state = pick_rand_state([IDLE, WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if _wander_controller.get_time_left() == 0:
				update_wander()
		WANDER:
			seek_player()
			if _wander_controller.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(delta, _wander_controller.target_position)
			if global_position.distance_to(_wander_controller.target_position) <= MAX_SPEED * delta:
				update_wander()
		CHASE:
			var player = _player_detection_zone.player
			if player:
				accelerate_towards_point(delta, player.global_position)
			else:
				state = IDLE

	if _soft_collision.is_colliding():
		velocity += _soft_collision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func accelerate_towards_point(delta, point):
	var direction = position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	_animated_sprite.flip_h = velocity.x < 0

func update_wander():
	state = pick_rand_state([IDLE, WANDER])
	_wander_controller.start_wander_timer(rand_range(1,3))

func seek_player():
	if _player_detection_zone.player:
		state = CHASE

func pick_rand_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 100
	
	_animated_sprite.play("takehit")
	yield(_animated_sprite, "animation_finished")
	_animated_sprite.play("flight")
	
	_stats.health -= area.damage
	_hurtbox.start_invincibility(0.4)

func _on_Stats_no_health():
	_animated_sprite.play("death")
	yield(_animated_sprite, "animation_finished")
	
	queue_free()


func _on_Hitbox_body_entered(_body):
	_animated_sprite.play("attack")
	yield(_animated_sprite, "animation_finished")
	_animated_sprite.play("flight")


func _on_Hurtbox_invincibility_started():
	_blink_animation_player.play("Start")


func _on_Hurtbox_invincibility_ended():
	_blink_animation_player.play("Stop")
