class_name JoystickKnob
extends Sprite2D

@onready var joystick: Joystick = $".."

# maximum length we want to drag our joystick out to
# it is equals to the radius of the JoystickRing in pixels
# it needs to be a float value for scaling purposes
@export var max_length: float = 32
@export var dead_zone: int = 5

var pressing: bool = false

func _ready():
	# scale max_length accordingly when scaling joystick
	max_length *= joystick.scale.x

func _process(delta):
	if pressing:
		var global_mouse_position: Vector2 = get_global_mouse_position()
		if global_mouse_position.distance_to(joystick.global_position) <= max_length:
			global_position = global_mouse_position
		else:
			# keep dragging the knob when mouse is outside the JoystickRing
			var angle = joystick.global_position.angle_to_point(global_mouse_position)
			global_position.x = joystick.global_position.x + cos(angle) * max_length
			global_position.y = joystick.global_position.y + sin(angle) * max_length
		calculate_vector()
	else:
		# reset knob position when players lets it go
		global_position = lerp(global_position, joystick.global_position, delta*50)
		# reset vectore
		joystick.position_vector = Vector2.ZERO

# function used to send data to the player
func calculate_vector():
	var x_difference = global_position.x - joystick.global_position.x
	if abs(x_difference) >= dead_zone:
		# we divide by max_length in order to have a 0 to 1 value
		joystick.position_vector.x = x_difference / max_length
		joystick.position_vector.y = (global_position.y - joystick.global_position.y) / max_length

func _on_button_button_down():
	pressing = true

func _on_button_button_up():
	pressing = false

func reset():
	_on_button_button_up()
