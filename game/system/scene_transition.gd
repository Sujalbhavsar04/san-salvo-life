class_name SceneTransition # Definiamo il nome della classe
extends Node # Estendiamo dalla classe Node

signal room_changed(game_camera: GameCamera) # Definiamo un segnale personalizzato 'room_changed' che viene emesso quando la stanza cambia, passando la GameCamera come argomento

var mobile_service = MobileService
var gui = Gui
var pause_menu = PauseMenu

@export var player: Player
@export var game_camera: GameCamera # Esportiamo una variabile per assegnare la GameCamera dall'editor

# Otteniamo i riferimenti a ColorRect e AnimationPlayer presenti nella scena
@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Definiamo delle costanti per i nomi delle animazioni
const FADE_OUT_KEY = "fade_out"
const FADE_IN_KEY = "fade_in"

# Definiamo i colori per le animazioni di fade out e fade in
var color_on_fade_out: Color = Color(0,0,0,0) # Trasparente
var color_on_fade_in: Color # Nero (inizializzato in camera_set_up)

# Variabile per memorizzare il percorso della scena da caricare
var scene_to_change_into_path: String = "" 

func _ready():
	assert(player, "No player selected")
	assert(game_camera, "No game camera selected") # Verifichiamo che sia stata assegnata una GameCamera
	color_rect.visible = false # Nascondiamo inizialmente il ColorRect
	# Impostiamo il colore iniziale del ColorRect per evitare flickering
	camera_set_up() 
	color_set_up()
	
	# Connettiamo il segnale "animation_finished" alla funzione animation_finished
	animation_player.animation_finished.connect(animation_finished) 

# Inizializza il colore per il fade in
func camera_set_up():
	color_on_fade_in = Color(0,0,0,1) # Nero opaco

# Imposta il colore iniziale del ColorRect
func color_set_up():
	color_rect.color = Color(Color.BLACK) 

# Avvia l'animazione di fade out e memorizza il percorso della scena da caricare
func fade_out(scene_path: String) -> void:
	assert(scene_path, "No scene selected") # Verifichiamo che sia stato specificato un percorso valido
	if mobile_service.is_mobile_export:
		gui.hide_all_mobile_controls()
	scene_to_change_into_path = scene_path # Memorizziamo il percorso della scena nella variabile di classe
	color_rect.color = color_on_fade_out # Impostiamo il colore iniziale per il fade out
	play_animation(FADE_OUT_KEY) # Avviamo l'animazione di fade out

# Avvia l'animazione di fade in
func fade_in():
	color_rect.color = color_on_fade_in # Impostiamo il colore iniziale per il fade in
	play_animation(FADE_IN_KEY) # Avviamo l'animazione di fade out

# Funzione generica per avviare un'animazione
func play_animation(animation_key: String):
	# Posizioniamo e dimensioniamo il ColorRect in base alla GameCamera
	color_rect.global_position = game_camera.top_left.global_position
	var new_size = Vector2(game_camera.bottom_right.global_position.x + abs(game_camera.top_left.global_position.x), game_camera.bottom_right.global_position.y + abs(game_camera.top_left.global_position.y))
	color_rect.size = new_size
	color_rect.visible = true # Rendiamo visibile il ColorRect
	player.set_player_as_in_cutscene()
	animation_player.play(animation_key) # Avviamo l'animazione

# Gestisce la fine di un'animazione
func animation_finished(anim_name):
	if anim_name == FADE_OUT_KEY:
		fade_out_animation_finished()
	else:
		fade_in_animation_finished()

# Cambia la scena al termine dell'animazione di fade out
func fade_out_animation_finished():
	# Verifichiamo che sia stato specificato un percorso valido
	assert(scene_to_change_into_path != '', "No scene selected")
	pause_menu.disable_pause_menu()
	get_tree().change_scene_to_file(scene_to_change_into_path) # Cambiamo la scena

# Questa funzione viene chiamata al termine dell'animazione di fade in.
func fade_in_animation_finished():
	player.set_player_as_not_in_cutscene() # il giocatore entra nella stanza.
	emit_signal("room_changed", game_camera) # Emette il segnale 'room_changed', passando la GameCamera come argomento

# Questa funzione viene chiamata quando la porta ha finito di aprirsi.
func on_door_has_opened():
	play_animation(FADE_OUT_KEY) # Avvia l'animazione di fade out.
