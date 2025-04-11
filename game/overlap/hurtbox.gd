class_name Hurtbox
extends Area2D

@onready var timer = $Timer
@onready var collision_shape_2d = $CollisionShape2D

signal invicibility_started
signal invincibility_ended

var invincible = false:
	get:
		return invincible
	set(value):
		invincible = value
		if invincible == true:
			emit_signal("invicibility_started")
		else:
			emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)
	collision_shape_2d.set_deferred("disabled", true)

func _on_timer_timeout():
	self.invincible = false
	collision_shape_2d.disabled = false
