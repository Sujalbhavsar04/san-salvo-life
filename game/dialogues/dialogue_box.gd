class_name DialogueBox
extends MarginContainer

signal dialogue_started
signal dialogue_finished

@export var CHARACTER_DISPLAY_SPEED = 0.05
@export var enabled = false

@onready var portrait = $MarginContainer/Portrait
@onready var dialogue_text = $MarginContainer/HBoxContainer/DialogueText
@onready var end = $MarginContainer/HBoxContainer/End
@onready var timer = $Timer

var mobile_service = MobileService

enum States {
	READY,
	READING,
	FINISHED
}

const PORTRAITS_PATH = "res://sprites/portraits/"

var name_key = "name"
var text_key = "text"

var dialog
var phrase_num = 0
var current_text = ''
var char_index = 0
var text_queue = []
var current_state = States.READY

func _ready():
	reset()

func _process(_delta):
	match current_state:
		States.READY:
			ready_state()
		States.READING:
			reading_state()
		States.FINISHED:
			finished_state()

func ready_state():
	if not text_queue.is_empty():
		timer.set_wait_time(CHARACTER_DISPLAY_SPEED)
		timer.start()
		current_state = States.READING

func reading_state():
	if Input.is_action_just_pressed("ui_accept") or mobile_service.is_touch_screen_just_pressed():
		timer.stop()
		dialogue_text.text = text_queue[0]
		move_to_finished_state()

func finished_state():
	if Input.is_action_just_pressed("ui_accept") or mobile_service.is_touch_screen_just_pressed():
		text_queue.pop_front()
		reset()
		current_state = States.READY
		next_phrase()

func move_to_finished_state():
	end.visible = true
	current_state = States.FINISHED

func queue_text(next_text: String):
	text_queue.push_back(next_text)

func initialize_dialogue(dialog_path):
	emit_signal("dialogue_started")
	dialog = get_dialog(dialog_path)
	next_phrase()

func get_dialog(dialog_path) -> Array:
	assert(FileAccess.file_exists(dialog_path), "File path does not exist")
	
	var dialogueFile = FileAccess.open(dialog_path, FileAccess.READ)
	
	# Retrieve data
	var json = JSON.new()
	var dialogueFileAsString = dialogueFile.get_as_text()
	var error = json.parse(dialogueFileAsString)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			return data_received
		else:
			return []
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", dialogueFileAsString, " at line ", json.get_error_line())
		return []

func next_phrase() -> void:
	if phrase_num >= len(dialog):
		# ORDER MATTERS: FIRST WE RESET AND THEN WE EMIT THE SIGNAL OTHERWISE BUG LIKE DIALOGUE SKIPPING WILL OCCUR
		phrase_num = 0
		emit_signal("dialogue_finished")
		return
	
	var portrait_image_path = PORTRAITS_PATH + dialog[phrase_num][name_key] + ".png"
	portrait.texture = load(portrait_image_path)
	
	queue_text(tr(dialog[phrase_num][text_key]))
	
	phrase_num += 1

func reset():
	current_text = ''
	dialogue_text.text = ''
	char_index = 0
	end.visible = false

func _on_timer_timeout():
	var text = text_queue[0]
	if char_index < text.length():
		current_text += text[char_index]
		dialogue_text.text = current_text
		char_index += 1
	else:
		timer.stop()
		move_to_finished_state()
