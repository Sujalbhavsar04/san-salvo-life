extends CanvasLayer

var is_enabled = false

@onready var music_player = MusicPlayer
@onready var color_rect = $ColorRect

func _ready():
	disable_pause_menu()
	reset()

func _input(event):
	if not is_enabled:
		return
	
	if event.is_action_pressed("ui_cancel"):
		music_player.stop_background_music()
		start_fade_out()

func start_fade_out(duration: float = 1.0):
	self.visible = true
	color_rect.visible = true
	var tween = create_tween()
	tween.tween_property(color_rect, "color", Color(color_rect.color.r, color_rect.color.g, color_rect.color.b, 1.0), duration)
	tween.finished.connect(change_to_main_scene)
	tween.play()

func change_to_main_scene():
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://menu/main_menu.tscn")
	reset()

func reset():
	self.visible = false
	color_rect.visible = false
	color_rect.color = Color(Color.BLACK.r, Color.BLACK.g, Color.BLACK.b, 0.0)

func enable_pause_menu():
	is_enabled = true

func disable_pause_menu():
	is_enabled = false
