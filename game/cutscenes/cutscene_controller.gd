class_name CutsceneController
extends Node

@export var player: Player

@onready var animation_player: AnimationPlayer = $Cutscenes

var current_animation_name: String = ''

signal animation_started(animation_name: String)
signal animation_finished(animation_name: String)

func _ready():
	assert(player, "No player selected")

func _on_cutscenes_animation_started(anim_name):
	# checks if animation player was not paused and then resumed
	if current_animation_name != anim_name:
		current_animation_name = anim_name
		emit_signal("animation_started", anim_name)
		player.set_player_as_in_cutscene()
		
func _on_cutscenes_animation_finished(anim_name):
	# checks if animation player was not paused and then resumed
	if current_animation_name == anim_name:
		current_animation_name = ''
		emit_signal("animation_finished", anim_name)
		player.set_player_as_not_in_cutscene()
