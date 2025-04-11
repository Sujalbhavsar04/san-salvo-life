extends Control

var music_player = MusicPlayer

@onready var v_box_container = $VBoxContainer
@onready var rich_text_label = $VBoxContainer/RichTextLabel
@export var SCROLL_SPEED = 60  # Scrolling speed

func _ready():
	set_process(false)
	v_box_container.global_position.y = get_viewport().size.y # Start the entire VBoxContainer off-screen
	music_player.stop_background_music()
	await get_tree().create_timer(1).timeout
	
	if not music_player.last_played_bgm_key == music_player.BGM_KEYS.CITY:
		music_player.play_background_music(music_player.BGM_KEYS.CITY)
	
	await get_tree().create_timer(3).timeout
	set_process(true)

func _process(delta):
	# Move the entire VBoxContainer up
	v_box_container.global_position.y -= SCROLL_SPEED * delta
	
	# Check if the entire container is off-screen
	if v_box_container.global_position.y + rich_text_label.size.y < 0:
		change_to_main_menu()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		change_to_main_menu()
		
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			change_to_main_menu()
	
	if event is InputEventScreenTouch:
		if event.pressed:
			change_to_main_menu()

func change_to_main_menu():
	get_tree().change_scene_to_file("res://menu/main_menu.tscn")  # Return to menu
