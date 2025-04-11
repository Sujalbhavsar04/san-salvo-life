extends Node2D

var scene_changer_controller = SceneChangerController

@onready var player = $"../Player"
@onready var scene_transition = $"../Transitions/SceneTransition"

func cutscene_1_finished_playing():
	scene_changer_controller.player_state = player.state # Aggiorna lo stato del giocatore nel controller
	scene_changer_controller.player_start_position = Vector2(303, 257)
	scene_changer_controller.player_direction_to_face = Vector2.DOWN

	scene_transition.fade_out("res://levels/brawl_room/brawl_room.tscn") # Avvia la transizione di scen
