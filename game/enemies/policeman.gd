class_name Policeman
extends Mob

# definiamo un tipo enumerativo per gli stati del nostro nuovo tipo di mob
# prima di aggiungere nuovi stati, gli stati della classe base 'Mob' (IDLE e WANDER) devono essere nello stesso ordine
enum PolicemanStates {
	IDLE, # stesso stato della classe 'Mob'
	WANDER, # stesso stato della classe 'Mob'
	CHASE # nuovo stato
}

# questa funzione ha la stessa struttura di quella nella classe 'Mob'
# l'unica differenza è l'aggiunta della gestione del nuovo stato
func _physics_process(delta):
	if is_mob_dead:
		return
	
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	match state:
		States.IDLE:
			idle_state(delta)
		
		States.WANDER:
			wander_state(delta)
		
		PolicemanStates.CHASE: # il mob ha 'visto' il player e lo sta rincorrendo
			chase_state(delta) # richiamiamo la funzione chase_state()
		
	move_and_slide()

# eseguiamo l'override della funzione seek_player()
func seek_player():
	if player_detection_zone.can_see_player() and player_stats.health > 0: # ci accertiamo che il mob possa 'vedere' il player
		state = PolicemanStates.CHASE # facciamo transire il mob allo stato di CHASE in modo che possa seguire il player

# funzione che gestisce le operazioni dello stato CHASE del nostro mob
func chase_state(delta: float) -> void:
	var player = player_detection_zone.player # prendiamo la reference al player dalla PlayerDetectionZone
	if player != null and player_stats.health > 0: # ci assicuriamo che vi sia effettivamente un player all'interno della PlayerDetectionZone
		var player_position = player.global_position # prendiamo la posizione del player sullo schermo
		if self.global_position.distance_to(player_position) > MIN_DISTANCE_FROM_PLAYER: # controlliamo che la distanza tra il mob e il player sia maggiore di quella minima
			accelerate_towards_point(player_position, delta) # muoviamo il mob verso il player. Così facendo il mob sembrerà stia rincorrendo il player
	else:
		state = States.IDLE # torniamo allo stato di IDLE perché il mob non vede più il player
