extends CanvasLayer

@onready var mobile_service = MobileService

@onready var health_ui = $HealthUI
@onready var mobile_controls = $MobileControls
@onready var joystick = $MobileControls/Joystick
@onready var fire_gun = $MobileControls/FireGun
@onready var exit = $MobileControls/Exit

func _ready():
	hide_health_ui()
	hide_all_mobile_controls()

func hide_health_ui():
	health_ui.visible = false

func show_health_ui():
	health_ui.visible = true

func hide_mobile_controls():
	mobile_controls.visible = false

func show_mobile_controls():
	mobile_controls.visible = true

func hide_all_mobile_controls():
	hide_mobile_controls()
	hide_joystick()
	hide_fire_gun_button()
	hide_exit_button()

func show_all_mobile_controls():
	show_mobile_controls()
	show_joystick()
	show_fire_gun_button()
	show_exit_button()

func hide_exit_button():
	exit.visible = false

func show_exit_button():
	exit.visible = true

func hide_fire_gun_button():
	fire_gun.visible = false

func show_fire_gun_button():
	fire_gun.visible = true

func hide_joystick():
	joystick.visible = false

func show_joystick():
	joystick.visible = true

func get_joystick_position_vector() -> Vector2:
	if mobile_service.is_mobile_export:
		return joystick.position_vector
	return Vector2.ZERO
