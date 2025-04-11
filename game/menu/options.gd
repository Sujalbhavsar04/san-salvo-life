extends Control

# Usa @onready per prendere i riferimenti!
@onready var master_slider: HSlider = $MasterSlider
@onready var music_slider: HSlider = $MusicSlider
@onready var sfx_slider: HSlider = $SFXSlider
@onready var brightness_slider: HSlider = $BrightnessSlider
@onready var screen_options: OptionButton = $ScreenOptions
@onready var check_box: CheckBox = $CheckBox

# Define the enum for screen modes
enum ScreenMode {
	WINDOWED,
	FULLSCREEN,
	BORDERLESS
}

const SETTINGS_FILE_PATH = "user://settings.cfg"

# Function called when the instance is added to the scene
func _ready():
	add_dropdown_items()
	load_settings()
	master_slider.grab_focus.call_deferred()

func add_dropdown_items():
	for mode in ScreenMode:
		screen_options.add_item(mode)

# Function to save settings
func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_slider.value)
	config.set_value("audio", "music_volume", music_slider.value)
	config.set_value("audio", "sfx_volume", sfx_slider.value)
	config.set_value("display", "brightness", brightness_slider.value)
	config.set_value("display", "screen_mode", screen_options.selected)
	config.set_value("keyboard", "invert_x_y_axis", check_box.button_pressed)
	
	# Salva il file se non esiste già, altrimenti sovrascrivilo
	config.save(SETTINGS_FILE_PATH)

# Function to load settings
func load_settings():
	var config = ConfigFile.new()

	# Carica i dati dal file
	var err = config.load(SETTINGS_FILE_PATH)

	# Se il file non viene caricato correttamente ignoralo
	if err != OK:
		return

	master_slider.value = config.get_value("audio", "master_volume")
	music_slider.value = config.get_value("audio", "music_volume")
	sfx_slider.value = config.get_value("audio", "sfx_volume")
	brightness_slider.value = config.get_value("display", "brightness")
	screen_options.selected = config.get_value("display", "screen_mode")
	check_box.button_pressed = config.get_value("keyboard", "invert_x_y_axis")

# Function called when the Back button is pressed
func _on_back_button_pressed():
	save_settings()
	get_tree().change_scene_to_file("res://menu/main_menu.tscn")
