extends Control

var music_player = MusicPlayer
var pause_menu = PauseMenu

func _ready():
	TranslationServer.set_locale("it")
	pause_menu.disable_pause_menu()
	music_player.play_background_music(music_player.BGM_KEYS.MAIN_MENU)

func _on_video_stream_player_finished():
	get_tree().change_scene_to_file("res://menu/main_menu.tscn")
