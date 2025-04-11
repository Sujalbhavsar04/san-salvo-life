class_name WandererController # definiamo lo script come una classe globalmente accessibile con il nome 'WandererController'
extends Node2D # estendiamo la classe Node2D (e quindi ne ereditiamo metodi e proprietà)

@export var wander_range = 32 # definiamo una variabile per impostare il raggio entro il quale ci si può muovere

@onready var start_position = global_position # salviamo la posizione iniziale in una variabile
@onready var target_position = global_position # salviamo all'interno di una variabile la posizione iniziale come posizione target

@onready var timer = $Timer # reference al nodo Timer

func _ready():
	update_target_position() # richiamiamo la funzione che si occupa di calcolare il punto in cui muovere il corpo

# funzione che calcola il punto in cui muovere il corpo
func update_target_position():
	var target_vector = Vector2(randf_range(-wander_range, wander_range), randf_range(-wander_range, wander_range)) # calcoliamo la direzione del vettore in cui muovere il corpo all'interno dell'area di raggio definito dalla variabile wander_range con centro in start_position
	target_position = start_position + target_vector # calcoliamo la posizione in cui muovere il corpo

# funzione che ritorna il tempo rimanente prima del prossimo WANDER
func get_time_left():
	return timer.time_left # ritorniamo il tempo rimanente prima del prossimo WANDER

# funzione che fa partire il countdown che conta il tempo rimanente prima del prossimo WANDER
func start_wander_timer(duration):
	timer.start(duration) # facciamo partire il timer

# funzione che viene chiamata quando Timer spara il signal timeout (ovvero quando il countdown per il prossimo WANDER raggiunge lo zero)
func _on_timer_timeout():
	update_target_position() # richiamiamo la funzione che si occupa di calcolare il punto in cui muovere il corpo
