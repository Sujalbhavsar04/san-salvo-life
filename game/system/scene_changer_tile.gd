class_name SceneChangerTile # Definiamo il nome della classe, rendendola accessibile globalmente
extends Node2D # Estendiamo dalla classe Node2D, la classe base per i nodi 2D

enum Directions { # Definiamo un'enumerazione per le direzioni
	NONE,
	UP,
	DOWN,
	RIGHT,
	LEFT
}

@export var scene_transition: SceneTransition # Esportiamo una variabile per assegnare il nodo SceneTransition dall'editor
@export var scene_to_change_into: String # Esportiamo una variabile per specificare il percorso della scena da caricare
@export var player_next_room_spawn_position: Vector2 # Esportiamo una variabile per specificare la posizione di spawn del giocatore nella prossima stanza
@export var direction: Directions = Directions.NONE # Esportiamo una variabile per specificare la direzione (usando l'enumerazione Directions)
@export var game_camera: GameCamera = null # esportiamo una variabile per assegnare la game camera.

var player: Player = null # Variabile per memorizzare il riferimento al nodo Player
var changing_room: bool = false # Variabile per indicare se la transizione di stanza è in corso

var scene_changer_controller = SceneChangerController # otteniamo il riferimento allo script autoload SceneChangerController

const directions_array = [
	Vector2.ZERO, 
	Vector2.UP, 
	Vector2.DOWN, 
	Vector2.RIGHT, 
	Vector2.LEFT, 
	Vector2.INF
] # Array di Vector2 corrispondenti alle direzioni

func _ready():
	assert(scene_transition, "No scene transition selected") # Verifica che il nodo SceneTransition sia stato assegnato
	assert(scene_to_change_into,"No scene selected") # Verifica che sia stato specificato il percorso della scena
	assert(player_next_room_spawn_position,"No player next room spawn position selected") # Verifica che sia stata specificata la posizione di spawn del giocatore
	assert(direction != Directions.NONE, "No direction selected") # Verifica che sia stata specificata una direzione

func _physics_process(_delta):
	if !changing_room and player != null: # Se la transizione non è in corso e il giocatore è presente
		scene_changer_controller.player_state = player.state # Aggiorna lo stato del giocatore nel controller
		scene_changer_controller.player_start_position = player_next_room_spawn_position # Aggiorna la posizione di spawn del giocatore nel controller
		scene_changer_controller.player_direction_to_face = directions_array[direction] # Aggiorna la direzione del giocatore nel controller

		scene_transition.fade_out(scene_to_change_into) # Avvia la transizione di scena
		changing_room = true # Imposta la variabile per indicare che la transizione è in corso

func _on_area_2d_body_entered(body):
	if body is Player: # Se il corpo che entra nell'area è il giocatore
		player = body # Memorizza il riferimento al giocatore
	else: # Altrimenti
		player = null # Resetta il riferimento al giocatore
