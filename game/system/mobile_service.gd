extends Node

const is_mobile_export: bool = true

var touch_screen_state: TouchScreenStates = TouchScreenStates.IDLE

enum TouchScreenStates {
	IDLE,
	JUST_PRESSED,
	PRESSED,
	JUST_RELEASED
}

func _process(_delta):
	if touch_screen_state == TouchScreenStates.JUST_PRESSED:
		# wait 1 frame before swapping
		get_tree().process_frame.connect(swap_to_pressed)
	
	if touch_screen_state == TouchScreenStates.JUST_RELEASED:
		# wait 1 frame before swapping
		get_tree().process_frame.connect(swap_to_idle)
	
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_screen_state = TouchScreenStates.JUST_PRESSED
		else:
			touch_screen_state = TouchScreenStates.JUST_RELEASED

func is_touch_screen_just_pressed() -> bool:
	return mobile_service_conditioned_return_value (touch_screen_state == TouchScreenStates.JUST_PRESSED) 

func is_touch_screen_pressed() -> bool:
	return mobile_service_conditioned_return_value (touch_screen_state == TouchScreenStates.PRESSED) 

func is_touch_screen_just_released() -> bool:
	return mobile_service_conditioned_return_value (touch_screen_state == TouchScreenStates.JUST_RELEASED) 

func mobile_service_conditioned_return_value(input_value: bool) -> bool:
	return is_mobile_export and input_value

func swap_to_pressed():
	get_tree().process_frame.disconnect(swap_to_pressed)
	touch_screen_state = TouchScreenStates.PRESSED

func swap_to_idle():
	get_tree().process_frame.disconnect(swap_to_idle)
	touch_screen_state = TouchScreenStates.IDLE

func reset_touch_screen_detection():
	touch_screen_state = TouchScreenStates.IDLE
