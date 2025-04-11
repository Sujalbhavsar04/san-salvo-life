extends AudioStreamPlayer

const BGM_FOLDER_PATH = "res://sounds/bgm/"

const BGM_KEYS = {
	BATTLE = "battle.mp3",
	CITY = "city.mp3",
	MAIN_MENU = "main_menu.mp3"
}

var last_played_bgm = null
var last_played_bgm_key = null

func play_background_music(bgm_key: String):
	stop_background_music()
	var bgm_file_path = BGM_FOLDER_PATH + bgm_key
	var bgm = load(bgm_file_path)
	last_played_bgm = bgm
	last_played_bgm_key = bgm_key
	self.stream = bgm
	self.play()

func stop_background_music():
	self.stop()

func change_background_music(bgm_key: String):
	stop_background_music()
	play_background_music(bgm_key)

func _on_finished():
	self.stream = last_played_bgm
	self.play()

func is_background_music_playing() -> bool:
	return self.playing
