class_name PathFollowController
extends Node

@export var cutscene_animation_player: AnimationPlayer
@export var path_follower_bodies: Array[CharacterBody2D]

var current_animation_name: String = ""

func _ready():
	assert(cutscene_animation_player, "Cutscene animation player is null")
	assert(path_follower_bodies, "No path follower bodies selected")
	cutscene_animation_player.animation_started.connect(on_animation_started)
	cutscene_animation_player.animation_finished.connect(on_animation_finished)
	for body in path_follower_bodies:
		body.on_path_following_started.connect(path_following_started)
		body.on_path_following_ended.connect(path_following_ended)

func on_animation_started(anim_name: String):
	current_animation_name = anim_name

func on_animation_finished(_anim_name: String):
	current_animation_name = ""

func path_following_started():
	cutscene_animation_player.pause()
	
func path_following_ended():
	cutscene_animation_player.play(current_animation_name)
