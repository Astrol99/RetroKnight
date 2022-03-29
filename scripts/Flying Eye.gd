extends KinematicBody2D

onready var _stats = $Stats
onready var _animated_sprite = $AnimatedSprite
onready var _player_detection_zone = $PlayerDetectionZone
onready var _hurtbox = $Hurtbox
onready var _soft_collision = $SoftCollision

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

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER:
			pass
			
		CHASE:
			var player = _player_detection_zone.player
			if player:
				var direction = position.direction_to(player.global_position)
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
	
			_animated_sprite.flip_h = velocity.x < 0

	if _soft_collision.is_colliding():
		velocity += _soft_collision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func seek_player():
	if _player_detection_zone.player:
		state = CHASE

func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 100
	
	_animated_sprite.play("takehit")
	yield(_animated_sprite, "animation_finished")
	_animated_sprite.play("flight")
	
	_stats.health -= area.damage

func _on_Stats_no_health():
	_animated_sprite.play("death")
	yield(_animated_sprite, "animation_finished")
	
	queue_free()


func _on_Hitbox_body_entered(body):
	_animated_sprite.play("attack")
	yield(_animated_sprite, "animation_finished")
	_animated_sprite.play("flight")
