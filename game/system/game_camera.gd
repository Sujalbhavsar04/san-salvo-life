class_name GameCamera
extends Camera2D

@onready var top_left = $Limits/TopLeft
@onready var bottom_right = $Limits/BottomRight

@onready var timer: Timer = $Timer

var is_shaking: bool = false
var shake_amount: float = 0
var shake_fade_amount: float = 0
var default_offset: Vector2 = offset
var pox_x: int
var pos_y: int

var is_stopping: bool = false

func _ready():
	set_process(true)
	randomize()
	
	limit_top = top_left.position.y
	limit_left = top_left.position.x
	limit_bottom = bottom_right.position.y
	limit_right = bottom_right.position.x

func _process(_delta):
	if is_stopping:
		if shake_amount == 0:
			set_process(false)
			is_shaking = false
			Tween.interpolate_value(self, "offset", 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		else:
			shake_amount = max(0, shake_amount - shake_fade_amount)
	offset = Vector2(randf_range(-1,1) * shake_amount, randf_range(-1,1)*shake_amount)

func shake(time: float, amount: float):
	timer.wait_time = time
	timer.start()
	start_shake(amount)

func start_shake(amount: float):
	is_shaking = true
	shake_amount = amount
	shake_fade_amount = amount / 100
	is_stopping = false
	set_process(true)

func stop_shake():
	is_stopping = true

func _on_timer_timeout():
	stop_shake()
