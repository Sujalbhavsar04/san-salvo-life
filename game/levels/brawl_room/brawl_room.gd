extends Node2D # estendiamo dalla classe Node2D

@onready var game_camera = $GameCamera # salviamo il riferimento al nodo GameCamera della scena
@onready var player = $Player # salviamo il riferimento al nodo player della scena
@onready var scene_transition = $Transitions/SceneTransition # salviamo il riferimento del nodo SceneTransition

var gui = Gui
var music_player = MusicPlayer

var scene_changer_controller = SceneChangerController # otteniamo il riferimento allo script autoload SceneChangerController

func _ready():
	gui.show_health_ui()
	player.equip_weapon(player.Weapons.MAC_10)
	scene_changer_controller.set_up_room(game_camera, player, scene_transition)
	
	if not music_player.last_played_bgm_key == music_player.BGM_KEYS.BATTLE:
		music_player.stop_background_music()
		await get_tree().create_timer(1).timeout
		music_player.play_background_music(music_player.BGM_KEYS.BATTLE)
