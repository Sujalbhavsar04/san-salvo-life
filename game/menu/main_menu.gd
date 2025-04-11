extends CanvasLayer

var pause_menu = PauseMenu
var gui = Gui
var mobile_service = MobileService
var music_player = MusicPlayer
var scene_changer_controller = SceneChangerController

@onready var play_button: Button = $Panel/MarginContainer/Panel/VBoxContainer/PlayButton
@onready var credits_button: Button = $Panel/MarginContainer/Panel/VBoxContainer/CreditsButton
@onready var option_button: Button = $Panel/MarginContainer/Panel/VBoxContainer/OptionButton
@onready var exit_button: Button = $Panel/MarginContainer/Panel/VBoxContainer/ExitButton
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var color_rect = $ColorRect

const PLAY_BUTTON_SFX = preload("res://sounds/sfx/start_game.wav")
var scene_to_change_into = null

func _ready():
	pause_menu.disable_pause_menu()
	gui.hide_health_ui()
	if mobile_service.is_mobile_export:
		gui.hide_all_mobile_controls()
	color_rect.visible = true
	color_rect.color = Color(Color.BLACK.r, Color.BLACK.g, Color.BLACK.b, 1.0)
	await get_tree().create_timer(1).timeout
	start_fade_in()
	play_button.grab_focus.call_deferred()

func button_pressed(button: Button):
	var hover_theme: StyleBoxTexture = button.get_theme_stylebox("hover")
	if button.is_hovered():
		hover_theme.set_texture_margin_all(10)
		hover_theme.set_expand_margin_all(0)
	button.release_focus()
	
	await get_tree().create_timer(0.1).timeout
	
	if button.is_hovered():
		hover_theme.set_texture_margin_all(0)
		hover_theme.set_expand_margin_all(10)
	button.grab_focus()

func start_fade_out(duration: float = 1.0):
	color_rect.visible = true
	var tween = create_tween()
	tween.tween_property(color_rect, "color", Color(color_rect.color.r, color_rect.color.g, color_rect.color.b, 1.0), duration)
	tween.finished.connect(change_to_scene_after_fade)
	tween.play()

func start_fade_in(duration: float = 1.0):
	var tween = create_tween()
	tween.tween_property(color_rect, "color", Color(color_rect.color.r, color_rect.color.g, color_rect.color.b, 0.0), duration)
	tween.finished.connect(show_main_menu)
	tween.play()

func show_main_menu():
	color_rect.visible = false
	if not music_player.last_played_bgm_key == music_player.BGM_KEYS.MAIN_MENU:
		music_player.stop_background_music()
		await get_tree().create_timer(1).timeout
		music_player.play_background_music(music_player.BGM_KEYS.MAIN_MENU)

func change_to_scene_after_fade():
	var time = 0.1
	if scene_to_change_into == "res://levels/chinese_shop/chinese_shop.tscn":
		time = 3
	await get_tree().create_timer(time).timeout
	get_tree().change_scene_to_file(scene_to_change_into)

func change_to_scene(scene_path: String):
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(scene_path)

func _on_play_button_pressed():
	music_player.stop_background_music()
	if not audio_stream_player.playing:
		audio_stream_player.stream = PLAY_BUTTON_SFX
		audio_stream_player.play()
	button_pressed(play_button)
	
	scene_changer_controller.player_state = Player.States.WALK
	scene_changer_controller.player_start_position = Vector2(417, 380)
	scene_changer_controller.player_direction_to_face = Vector2.LEFT
	
	await get_tree().create_timer(0.5).timeout
	scene_to_change_into = "res://levels/chinese_shop/chinese_shop.tscn"
	start_fade_out()

func _on_credits_button_pressed():
	button_pressed(credits_button)
	await get_tree().create_timer(0.5).timeout
	scene_to_change_into = "res://menu/credits.tscn"
	start_fade_out()

func _on_option_button_pressed():
	button_pressed(option_button)
	await get_tree().create_timer(0.5).timeout
	scene_to_change_into = "res://menu/options.tscn"
	start_fade_out()

func _on_exit_button_pressed():
	button_pressed(exit_button)
	get_tree().quit()

func _on_play_button_mouse_entered():
	play_button.grab_focus()

func _on_credits_button_mouse_entered():
	credits_button.grab_focus()

func _on_option_button_mouse_entered():
	option_button.grab_focus()

func _on_exit_button_mouse_entered():
	exit_button.grab_focus()
