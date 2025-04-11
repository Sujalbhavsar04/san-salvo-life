class_name DialogueController
extends Control

signal dialogue_started
signal dialogue_completed

@export var player: Player
@export var cutscene_animation_player: AnimationPlayer
@export var dialogues_path: Dictionary

@onready var dialogue_box: DialogueBox = $DialogueBox

var current_dialogue_key = ''
var is_dialogue_playing = false
var dialogue_array_index: int = 0
var is_was_animation_player_stopped: bool = false

func _ready():
	assert(player, "No player selected")
	assert(cutscene_animation_player, "No cutscene animation player selected")
	self.visible = false
	dialogue_box.visible = false

func play_dialogue(dialogue_key: String) -> void:
	assert(is_can_dialogue_be_played(dialogues_path[dialogue_key]), "Dialogue cannot be player")
	set_up_dialogue_state(dialogue_key)
	
	emit_signal("dialogue_started")
	
	dialogue_box.visible = true
	is_dialogue_playing = true
	
	start_dialogue()

func is_dialogue_controller_playing_dialogue() -> bool:
	return is_dialogue_playing

func is_can_dialogue_be_played(cutscene_dialogues_array: Array) -> bool:
	return dialogue_array_index < len(cutscene_dialogues_array)

func set_up_dialogue_state(dialogue_key):
	player.set_player_as_in_cutscene()
	
	if is_instance_valid(cutscene_animation_player) and cutscene_animation_player.is_playing():
		is_was_animation_player_stopped = true
		cutscene_animation_player.pause()
	
	self.visible = true
	if dialogue_key != current_dialogue_key:
		current_dialogue_key = dialogue_key
		dialogue_array_index = 0

func start_dialogue():
	dialogue_box.initialize_dialogue(dialogues_path[current_dialogue_key][dialogue_array_index])
	dialogue_array_index += 1

func reset_dialogue_controller() -> void:
	player.set_player_as_not_in_cutscene()
	
	if is_was_animation_player_stopped:
		is_was_animation_player_stopped = false
		cutscene_animation_player.play()
	
	self.visible = false

func _on_dialogue_box_dialogue_finished():
	emit_signal("dialogue_completed")
	is_dialogue_playing = false
	dialogue_box.visible = false
	reset_dialogue_controller()
