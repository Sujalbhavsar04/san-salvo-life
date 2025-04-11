class_name Projectile
extends Hitbox

@export var animated_sprite_2D: AnimatedSprite2D
@export var visible_on_screen_notitifier_2D: VisibleOnScreenNotifier2D

@export var SPEED: int = 200
const START_ANIMATION_KEY = "start"
const END_ANIMATION_KEY = "end"

var is_has_projectile_hit: bool = false

func _ready():
	animated_sprite_2D.play(START_ANIMATION_KEY)
	
	animated_sprite_2D.animation_finished.connect(queue_free)
	visible_on_screen_notitifier_2D.screen_exited.connect(queue_free)

func _physics_process(delta):
	if !is_has_projectile_hit:
		var direction = Vector2.RIGHT.rotated(rotation)
		knockback_vector = direction
		global_position += SPEED * direction * delta

func destroy():
	is_has_projectile_hit = true
	animated_sprite_2D.play(END_ANIMATION_KEY)
