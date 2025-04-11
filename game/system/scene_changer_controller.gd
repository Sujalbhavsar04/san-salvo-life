extends Node

signal room_set_up_completed

@onready var pause_menu = PauseMenu
@onready var mobile_service = MobileService
@onready var gui = Gui

var player_state: Player.States = Player.States.WALK # Stato del giocatore (WALK, IDLE, etc.). Inizializzato a WALK di default.
var player_start_position: Vector2 = Vector2.ZERO # Posizione di partenza del giocatore nella stanza. Inizializzata a (0, 0) di default.
var player_direction_to_face: Vector2 # Direzione in cui il giocatore deve essere rivolto all'inizio della stanza.

# Funzione per impostare la stanza.
func set_up_room(game_camera: GameCamera, player: Player, scene_transition: SceneTransition, start_room_function: Callable = Callable()) -> void:
	
	scene_transition.fade_in() # avviamo l'animazione di fade-in
	
	if start_room_function.is_valid():
		self.room_set_up_completed.connect(start_room_function)
	
	# Connette il segnale 'room_changed' di scene_transition alla funzione 'room_set_up_finished'.
	# Questo significa che quando scene_transition emetterà 'room_changed', verrà chiamata 'room_set_up_finished'.
	scene_transition.room_changed.connect(room_set_up_finished)

	# Controllo per la modalità debug. Se player_start_position è (0, 0), la funzione termina.
	# Questo permette di usare la posizione di partenza definita nella scena del giocatore.
	if player_start_position == Vector2.ZERO:
		return

	player.state = player_state # Imposta lo stato del player.
	player.global_position = player_start_position # Imposta la posizione globale del player.
	player.face_direction(player_direction_to_face) # Fa rivolgere il player nella direzione specificata.

	# Disabilita la transizione fluida della telecamera.
	# Questo fa si che la telecamera assumi immediatamente la posizione del player ed evita che si muovi ancora dopo il termine dell'animazione di fade-in
	game_camera.position_smoothing_enabled = false
	# Imposta la posizione della telecamera in base alla posizione di partenza del giocatore.
	game_camera.global_position = player_start_position

# Funzione chiamata quando il segnale 'room_changed' viene emesso.
func room_set_up_finished(game_camera: GameCamera):
	if mobile_service.is_mobile_export:
		gui.show_all_mobile_controls()
	pause_menu.enable_pause_menu()
	# Abilita la transizione fluida della telecamera.
	game_camera.position_smoothing_enabled = true
	emit_signal("room_set_up_completed")
