class_name MustacheGuy # definiamo lo script come una classe globalmente accessibile con il nome 'LingeringRemnant'
extends Mob # estendiamo la classe Mob (e quindi ne ereditiamo metodi e proprietà)

@onready var projectile_timer: Timer = $ProjectileTimer
@export var FIRE_DELAY = 0.15

@onready var bullet_point: Marker2D = $BulletPoint

const FIRE_SFX = preload("res://sounds/sfx/fire.mp3")
@export var num_sfx_players: int = 20
var sfx_players: Array[AudioStreamPlayer]

var Bullet = preload("res://projectiles/bullet.tscn")
var player_position: Vector2 = Vector2.ZERO

# definiamo un tipo enumerativo per gli stati del nostro nuovo tipo di mob
# prima di aggiungere nuovi stati, gli stati della classe base 'Mob' (IDLE e WANDER) devono essere nello stesso ordine
enum MustacheGuyStates {
	IDLE, # stesso stato della classe 'Mob'
	WANDER, # stesso stato della classe 'Mob'
	RUN_AWAY # nuovo stato
}

func _ready():
	call_on_ready()
	
	sfx_players.resize(num_sfx_players)
	for i in num_sfx_players:
		var gun_audio_stream_player = AudioStreamPlayer.new()
		gun_audio_stream_player.bus = "SFX" # Consider using an "SFX" audio bus
		add_child(gun_audio_stream_player)
		sfx_players[i] = gun_audio_stream_player

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
		
		MustacheGuyStates.RUN_AWAY: # il mob ha 'visto' il player e sta scappando da esso
			run_away_state(delta) # richiamiamo la funzione chase_state()
		
	move_and_slide()

# eseguiamo l'override della funzione seek_player()
func seek_player():
	if player_detection_zone.can_see_player() and player_stats.health > 0: # ci accertiamo che il mob possa 'vedere' il player
		state = MustacheGuyStates.RUN_AWAY # facciamo transire il mob allo stato di RUN_AWAY in modo che possa scappare dal player

# funzione che gestisce le operazioni dello stato RUN_AWAY del nostro mob
func run_away_state(delta: float) -> void:
	var player = player_detection_zone.player # prendiamo la reference al player dalla PlayerDetectionZone
	if player != null and player_stats.health > 0: # ci assicuriamo che vi sia effettivamente un player all'interno della PlayerDetectionZone
		player_position = player.global_position # prendiamo la posizione del player sullo schermo
		var distance_from_player = self.global_position.distance_to(player_position) # calcoliamo la distanza che c'è tra il mob e il player
		if distance_from_player < MIN_DISTANCE_FROM_PLAYER: # controlliamo che la distanza tra il mob e il player sia minore della distanza minima
			var vector_from_player_to_mob = self.global_position - player_position # calcoliamo la direzione in cui scappare dal player
			var normalized_vector = vector_from_player_to_mob / distance_from_player # normalizziamo il vettore direzione
			var distance_vector = normalized_vector * MIN_DISTANCE_FROM_PLAYER # calcoliamo la distanza che il mob deve percorrere per scappare dal player e raggiungere quindi la distanza minima che deve esserci tra lui e il player
			var run_away_to_point = distance_vector + player_position # calcoliamo il punto finale dove sarà il mob dopo essere scappato dal player, ripristinando così la distanza minima tra lui e il player
			accelerate_towards_point(run_away_to_point, delta) # muoviamo il mob verso il punto finale
		else:
			animation_state.travel(IDLE_ANIMATION_KEY) # riproduciamo l'animazione di Idle del mob
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			face_direction(self.global_position.direction_to(player.global_position)) # giriamo il mob in direzione del player
	else:
		state = States.IDLE # torniamo allo stato di IDLE perché il mob non vede più il player
	
	if projectile_timer.time_left == 0:
		projectile_timer.wait_time = FIRE_DELAY
		projectile_timer.start()
		fire()

func fire():
	if Bullet:
		play_fire_sfx()
		
		var bullet = Bullet.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.damage = 0.5
		bullet.global_position = bullet_point.global_position
		bullet.set_collision_layer_value(4, true)
		var direction_to_player = bullet_point.global_position.direction_to(player_position)
		bullet.rotation = direction_to_player.angle()
		match utils.get_cardinal_direction(direction_to_player):
			Vector2.UP:
				bullet.global_position -= Vector2(0,30) + Vector2(randf_range(-5, 5), 0)
			Vector2.DOWN:
				bullet.global_position += Vector2(0,20) + Vector2(randf_range(-5, 5), 0)
			Vector2.LEFT:
				bullet.global_position -= Vector2(30,0) + Vector2(0, randf_range(-5, 5))
			Vector2.RIGHT:
				bullet.global_position += Vector2(30,0) + Vector2(0, randf_range(-5, 5))

func play_fire_sfx():
	for gun_audio_stream_player in sfx_players:
		if not gun_audio_stream_player.playing:
			gun_audio_stream_player.stream = FIRE_SFX
			gun_audio_stream_player.play()
			return # Play on the first available player
	# Optional: If all players are busy, you could stop the oldest one and play
	if sfx_players.size() > 0:
		sfx_players[0].stop()
		sfx_players[0].stream = FIRE_SFX
		sfx_players[0].play()
