extends KinematicBody2D

onready var _sprite = $AnimatedSprite
onready var stats = $Stats
onready var _player_detection_zone = $PlayerDetectionZone

export var ACCELERATION : float = 500.0
export var MAX_SPEED : float = 150.0
export var FRICTION : float = 100.0
export var GRAVITY : float = 500.0

enum {
	IDLE,
	WANDER,
	CHASE
}
var velocity : Vector2 = Vector2.ZERO
var knockback : Vector2 = Vector2.ZERO

var state = IDLE

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			_sprite.play("idle")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER:
			pass
			
		CHASE:
			_sprite.play("run")
			if _player_detection_zone.player:
				var direction = (_player_detection_zone.player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
			
			_sprite.flip_h = velocity.x < 0
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity)

func seek_player():
	if _player_detection_zone.player:
		state = CHASE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	if stats.health <= 0:
		_sprite.play("death")
	else:
		_sprite.play("hurt")
	knockback.x = area.knockback_vector * 100


func _on_AnimatedSprite_animation_finished():
	match _sprite.animation:
		"death":
			queue_free()
