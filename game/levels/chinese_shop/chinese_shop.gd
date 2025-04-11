extends Node2D # estendiamo dalla classe Node2D

@onready var game_camera = $GameCamera # salviamo il riferimento al nodo GameCamera della scena
@onready var player = $Player # salviamo il riferimento al nodo player della scena
@onready var animation_player = $Cutscenes/CutsceneController/Cutscenes
@onready var scene_transition = $Transitions/SceneTransition # salviamo il riferimento del nodo SceneTransition
@onready var register: Sprite2D = $Objects/Register

var music_player = MusicPlayer

var mobile_service = MobileService
var gui = Gui
var scene_changer_controller = SceneChangerController # otteniamo il riferimento allo script autoload SceneChangerController

func _ready():
	music_player.stop_background_music()
	register.frame = 0
	player.visible = false
	player.equip_weapon(player.Weapons.KNIFE)
	player.IS_PLAYER_MASKED = true
	scene_changer_controller.set_up_room(game_camera, player, scene_transition, Callable(self, "start_room")) # prepariamo la stanza

func start_room():
	if mobile_service.is_mobile_export:
		gui.hide_all_mobile_controls()
		gui.show_mobile_controls()
		gui.show_exit_button()
	animation_player.play("cutscene_1")
