class_name Mob # definiamo lo script come una classe globalmente accessibile con il nome 'Mob'
extends CharacterBody2D # estendiamo la classe CharacterBody2D (e quindi ne ereditiamo metodi e proprietà)

signal mob_died(mob: Mob)

@export var ACCELERATION = 300 # definiamo una variabile che rappresenta l'accelerazione che ha il nostro mob quando ha iniziato a muoversi
@export var MAX_SPEED = 50 # definiamo una variabile che rappresenta la velocità massima a cui potrà muoversi il mob
@export var FRICTION = 200 # definiamo una variabile che rappresenta la decelerazione che ha il mob quando si sta sta fermando (questo evita che il mob si fermi bruscamente dopo che ha smesso di muoversi)
@export var WANDER_TARGET_RANGE = 4 # definiamo una variabile che rappresenta il raggio massimo che può avere la zona in cui il mob si muove quando è nello stato "wander"

@export var MIN_DISTANCE_FROM_PLAYER = 10 # definiamo una variabile che rappresenta la distanza minima che deve avere il mob rispetto al player quando questo entra nella PlayerDetectionZone

var player_stats = PlayerStats

const Utils = preload("res://utils/utils.gd")
var utils: Utils

# definiamo un tipo enumerativo per gli stati del nostro mob
enum States {
	IDLE,
	WANDER
}

const IDLE_ANIMATION_KEY = "Idle" # chiave con cui abbiamo chiamato lo stato di IDLE nell'AnimationTree
const WALK_ANIMATION_KEY = "Walk" # chiave con cui abbiamo chiamato lo stato di WALK nell'AnimationTree

# vettore che contiene tutte le blend position, ovvero i crosshair degli stati dell'AnimationTree
# ricordiamo che la sprite cambia a seconda della posizione del crosshair nello spazio
const ANIMATION_TREE_PARAMETERS = [
	"parameters/Idle/blend_position",
	"parameters/Walk/blend_position"
]

@export var animation_tree: AnimationTree # reference al nodo AnimationTree
@export var player_detection_zone: PlayerDetectionZone # reference al nodo PlayerDetectionZone
@export var wanderer_controller: WandererController # reference al nodo WandererController
@export var stats: Stats
@export var hurtbox: Hurtbox
@export var blink_animation_player: AnimationPlayer

var is_mob_dead = false

var animation_state = null # definiamo una variabile che conterrà lo stato corrente dell'AnimationTree

var state = States.WANDER # definiamo una variabile che tiene traccia dello stato corrente in cui si trova il nostro mob

func _ready():
	# chiamiamo una funzione che viene chiamata quando viene chiamata la funzione _ready()
	# facciamo uso di una funzione in modo da poter fare override della funzione _ready() nelle
	# sottoclassi di Mob
	call_on_ready()

# funzione che viene chiamata quando viene chiamata la funzione _ready()
func call_on_ready():
	assert(animation_tree, "No animation tree selected") # controlliamo che vi sia una reference al nodo AnimationTree
	assert(player_detection_zone, "No player detection zone selected") # controlliamo che vi sia una reference al nodo PlayerDetectionZone
	assert(wanderer_controller, "No wander controller selected") # controlliamo che vi sia una reference al nodo WanderController
	assert(stats, "No stats selected")
	assert(hurtbox, "No hurtbox selected")
	assert(blink_animation_player, "No blink animation player selected")
	
	animation_tree.active = true # abilitiamo il nodo AnimationTree
	animation_state = animation_tree.get("parameters/playback") # ottieniamo la reference allo stato corrente dell'AnimationTree
	
	stats.no_health.connect(death)
	
	hurtbox.area_entered.connect(hurtbox_area_entered)
	hurtbox.invicibility_started.connect(start_blink_player)
	hurtbox.invincibility_ended.connect(end_blink_player)
	
	utils = Utils.new()
	
	randomize() # randomizziamo il seed del random number generator
	state = pick_random_state([States.IDLE, States.WANDER]) # scegliamo casualmente uno stato iniziale del Mob tra IDLE e WANDER
	
func _physics_process(delta):
	if is_mob_dead:
		return
	
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta) # se il mob non è fermo allora lo fermiamo lentamente con una decelerazione
	
	# eseguiamo un'azione specifica in base allo stato in cui si trova il nostro mob
	match state:
		States.IDLE: # il mob è fermo in IDLE
			idle_state(delta) # richiamiamo la funzione idle_state()
		
		States.WANDER: # il mob sta vagando a zonzo nella mappa
			wander_state(delta) # richiamiamo la funzione wander_state()
		
	move_and_slide() # muoviamo il mob sullo schermo

# funzione che gestisce le operazioni dello stato IDLE del nostro mob
func idle_state(delta: float) -> void:
	animation_state.travel(IDLE_ANIMATION_KEY) # riproduciamo l'animazione di Idle del mob
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta) # se il mob non è fermo allora lo fermiamo lentamente con una decelerazione
	seek_player() # richiamiamo la funzione seek_player() che cerca il player all'interno della PlayerDetectionZone
	if wanderer_controller.get_time_left() == 0: # controlliamo se è scaduto l'intervallo di pausa che c'è tra un movimento di WANDER e l'altro
		update_wander() # invochiamo la funzione che sceglie se rimanere in IDLE o andare in WANDER

# funzione che gestisce le operazioni dello stato WANDER del nostro mob
func wander_state(delta: float) -> void:
	seek_player() # richiamiamo la funzione seek_player() che cerca il player all'interno della PlayerDetectionZone
	if wanderer_controller.get_time_left() == 0: # controlliamo se è scaduto l'intervallo di pausa che c'è tra un movimento di WANDER e l'altro
		update_wander() # invochiamo la funzione che sceglie se rimanere in IDLE o andare in WANDER
	accelerate_towards_point(wanderer_controller.target_position, delta) # muoviamo il mob verso una direzione all'interno del raggio del WandererController
	if self.global_position.distance_to(wanderer_controller.target_position) <= WANDER_TARGET_RANGE: # controlliamo che il mob non sia andato oltre il raggio del WandererController
		update_wander() # invochiamo la funzione che sceglie se rimanere in IDLE o andare in WANDER

# funzione che sceglie uno stato casuale da una lista di stati passati in input
func pick_random_state(stateList):
	stateList.shuffle() # mischiamo gli elementi della lista in modo che abbiano un ordine casuale
	return stateList.pop_front() # ritorniamo il primo elemento della lista, che sarà dunque lo stato casuale scelto

# funzione che sceglie se rimanere in IDLE o andare in WANDER
func update_wander():
	state = pick_random_state([States.IDLE, States.WANDER]) # scegliamo uno stato casuale tra IDLE e WANDER
	wanderer_controller.start_wander_timer(randf_range(1, 3)) # scegliamo un intervello casuale prima della prossima azione dello stato WANDER (e quindi di potenzialmente muovere nuovamente il mob)

# funzione che muove un mob verso un punto
func accelerate_towards_point(point, delta):
	var mob_direction = self.global_position.direction_to(point) # calcoliamo la direzione che deve guardare il mob mentre si muove verso il suo punto destinazione
	face_direction(mob_direction) # invochiamo la funzione che imposta tutte le blend position degli stati dell'AnimationTree verso la direzione in cui si deve muovere il mob
	animation_state.travel(WALK_ANIMATION_KEY) # riproduciamo l'animazione di Walk del mob
	velocity= velocity.move_toward(mob_direction * MAX_SPEED, ACCELERATION * delta) # muoviamo il mob con una certa velocità verso la direzione del punto destinazione

# funzione che imposta tutte le blend position degli stati dell'AnimationTree verso la direzione in cui si deve muovere il mob
func face_direction(direction: Vector2) -> void:
	utils.face_direction(animation_tree, ANIMATION_TREE_PARAMETERS, direction)

func hurtbox_area_entered(area):
	if not hurtbox.invincible and not is_mob_dead:
		stats.health -= area.damage
		velocity = area.knockback_vector * 150
		hurtbox.start_invincibility(0.4)

# funzione che controlla se il player è all'interno dell PlayerDetectionZone
func seek_player():
	pass # questa funzione deve essere sovrascritta dalle sottoclassi di Mob nel caso il mob specifico faccia qualcosa quando il player viene "visto" dal mob stesso

func start_blink_player():
	blink_animation_player.play("start")

func end_blink_player():
	blink_animation_player.play("stop")

func death():
	emit_signal("mob_died", self)
	self.visible = false
	is_mob_dead = true

func revive():
	stats.health = stats.max_health
	self.visible = true
	is_mob_dead = false
