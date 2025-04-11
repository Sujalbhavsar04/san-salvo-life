class_name Joystick
extends Node2D

# vector produced by JoystickKnob
var position_vector: Vector2 = Vector2.ZERO

@onready var joystick_knob = $JoystickKnob

@onready var mobile_service = MobileService

func change_joystick_visibility(is_show_joystick: bool) -> void:
	if is_show_joystick:
		show_joystick()
	else:
		hide_joystick()

func show_joystick():
	visible = true

func hide_joystick():
	visible = false
	if position_vector != Vector2.ZERO:
		joystick_knob.reset()
		mobile_service.reset_touch_screen_detection()
