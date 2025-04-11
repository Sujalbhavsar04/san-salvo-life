class_name Player # Definisce lo script come una classe globalmente accessibile con il nome 'Player'
extends CharacterBody2D

signal on_path_following_started
signal on_path_following_ended

signal on_speed_changed(speed: int, is_do_match_player_following_bodies_speed_with_player_speed: bool)

@onready var projectile_timer: Timer = $ProjectileTimer

const FIRE_SFX = preload("res://sounds/sfx/fire.mp3")
@export var FIRE_DELAY = 0.15
@onready var bullet_point: Marker2D = $BulletPoint

@onready var blink_animation_player = $BlinkAnimationPlayer

@onready var audio_stream_player = $AudioStreamPlayer

var gui = Gui
var mobile_service = MobileService
var player_stats = PlayerStats

var is_player_dead = false
var low_life_sound_played = false

var is_gun_equipped = false
var Bullet = preload("res://projectiles/bullet.tscn")

const MAX_DEFAULT_SPEED = 150 # definiamo una costante che rappresenta la nostra velocità massima

@export var SPEED = MAX_DEFAULT_SPEED # definiamo una variabile per impostare la velocità del personaggio
@export var IS_PLAYER_MASKED: bool = false

@onready var color_rect = $CanvasLayer/ColorRect
@onready var animation_player = $AnimationPlayer # reference al nodo AnimationPlayer
@onready var animation_tree = $AnimationTree # reference al nodo AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback") # reference allo stato corrente dell'AnimationTree
@onready var gun: Sprite2D = $Gun
@onready var weapon_sprite_2d: Sprite2D = $Weapon/Sprite2D
@onready var hurtbox = $Hurtbox
@export var num_sfx_players: int = 20
var sfx_players: Array[AudioStreamPlayer]

var music_player = MusicPlayer

const IDLE_ANIMATION_KEY = "Idle" # chiave con cui abbiamo chiamato lo stato di idle nell'AnimationTree
const WALK_ANIMATION_KEY = "Walk" # chiave con cui abbiamo chiamato lo stato di walk nell'AnimationTree
const IDLE_MASKED_ANIMATION_KEY = "IdleMasked"
const WALK_MASKED_ANIMATION_KEY = "WalkMasked"

var player_direction: Vector2 = Vector2.DOWN # definiamo una variabile che tiene in memoria la direzione guardata dal player in ogni istante

# vettore che contiene tutte le blend position, ovvero i crosshair degli stati dell'AnimationTree
# ricordiamo che la sprite cambia a seconda della posizione del crosshair nello spazio
const ANIMATION_TREE_PARAMETERS = [
	"parameters/Idle/blend_position",
	"parameters/Walk/blend_position",
	"parameters/IdleMasked/blend_position",
	"parameters/WalkMasked/blend_position"
]

# definiamo un tipo enumerativo per gli stati del nostro player
enum States {
	WALK,
	WALK_TOWARD
}

enum Weapons {
	KNIFE,
	MAC_10
}

var direction_used_in_player_follow: Vector2 = Vector2.DOWN

# definiamo una variabile che tiene traccia dello stato corrente in cui si trova il nostro player
var state: States = States.WALK
# used for path following logic in order to switch back to previous state on path following end
var state_before_walk_toward_stake: States = States.WALK
var is_player_in_cutscene: bool = false
var cutscene_queue: int = 0

const Utils = preload("res://utils/utils.gd")
var utils: Utils

var path_following_logic: PathFollowingLogic

func _ready():
	color_rect.visible = false
	animation_tree.active = true # abilitiamo il nodo AnimationTree
	path_following_logic = PathFollowingLogic.new(self, animation_tree, ANIMATION_TREE_PARAMETERS)
	path_following_logic.on_path_following_started.connect(player_path_following_started)
	path_following_logic.on_path_following_ended.connect(player_path_following_ended)
	utils = Utils.new()
	
	player_stats.no_health.connect(death)
	
	sfx_players.resize(num_sfx_players)
	for i in num_sfx_players:
		var gun_audio_stream_player = AudioStreamPlayer.new()
		gun_audio_stream_player.bus = "SFX" # Consider using an "SFX" audio bus
		add_child(gun_audio_stream_player)
		sfx_players[i] = gun_audio_stream_player

func _physics_process(delta):
	if is_player_dead:
		return
	
	if not is_player_in_cutscene:
		# eseguiamo un'azione specifica in base allo stato in cui si trova il nostro player
		match state:
			States.WALK: # il player sta camminando o è fermo
				walk_state()
	else:
		match state:
			States.WALK_TOWARD:
				walk_toward_state(delta)

# funzione che gestisce le operazioni dello stato WALK del nostro player
func walk_state():
	var input_vector = Vector2.ZERO # impostiamo a ZERO il valore iniziale del nostro vettore di movimento
	
	var current_player_direction: Vector2 = Vector2.ZERO # impostiamo a ZERO il valore iniziale del nostro vettore che indica la direzione "guardata" dal player
	
	# game is being played on mobile
	if mobile_service.is_mobile_export:
		input_vector = gui.get_joystick_position_vector()
		# normalize
		if input_vector != Vector2.ZERO:
			var left_distance = input_vector.distance_to(Vector2.LEFT)
			var right_distance = input_vector.distance_to(Vector2.RIGHT)
			var up_distance = input_vector.distance_to(Vector2.UP)
			var down_distance = input_vector.distance_to(Vector2.DOWN)
			var min_distance = min(left_distance, right_distance, up_distance, down_distance)
			match min_distance:
				left_distance:
					current_player_direction = Vector2.LEFT
				right_distance:
					current_player_direction = Vector2.RIGHT
				up_distance:
					current_player_direction = Vector2.UP
				down_distance:
					current_player_direction = Vector2.DOWN
	else: # game is being played on pc
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		input_vector = input_vector.normalized()
		current_player_direction = input_vector
	
	if input_vector != Vector2.ZERO: # controlliamo che il giocatore sta effettivamente muovendo il personaggio
		player_direction = current_player_direction
		face_direction(current_player_direction) # facciamo guardare al player la direzione che deve guardare mentre si sta muovendo
		travel_to_walk_animation() # passiamo dallo stato "Idle" allo stato "Walk"
		
		velocity = velocity.move_toward(input_vector * SPEED, SPEED) # se il giocatore sta effettivamente muovendo il personaggio, assegniamo una velocità a quest'ultimo
	else:
		travel_to_idle_animation() # passiamo dallo stato "Walk" allo stato "Idle"
		
		velocity = Vector2.ZERO # se il giocatore NON sta effettivamente muovendo il personaggio, assegniamo una velocità NULLA a quest'ultimo

	move_and_slide() # muoviamo il personaggio sullo schermo
	
	if is_gun_equipped:
		if Input.is_action_just_pressed("attack"):
			projectile_timer.wait_time = FIRE_DELAY
			projectile_timer.start()
		
		if Input.is_action_just_released("attack"):
			projectile_timer.stop()

func face_direction(direction: Vector2) -> void:
	assert(path_following_logic, "No Path Following logic")
	player_direction = direction
	path_following_logic.face_direction(direction)

func travel_to_idle_animation():
	var animation_key = IDLE_ANIMATION_KEY
	if IS_PLAYER_MASKED:
		animation_key = IDLE_MASKED_ANIMATION_KEY
	animation_state.travel(animation_key)

func travel_to_walk_animation():
	var animation_key = WALK_ANIMATION_KEY
	if IS_PLAYER_MASKED:
		animation_key = WALK_MASKED_ANIMATION_KEY
	animation_state.travel(animation_key)

func equip_weapon(weapon: Weapons):
	match weapon:
		Weapons.KNIFE:
			weapon_sprite_2d.texture = load("res://sprites/weapons/knife.png")
		Weapons.MAC_10:
			is_gun_equipped = true
			gun.texture = load("res://sprites/weapons/mac_10.png")

func change_walk_toward_state_speed(new_speed: int) -> void:
	assert(path_following_logic, "No Path Following logic")
	path_following_logic.change_speed(new_speed)

func set_walk_toward_state(destination_point: Vector2, direction_to_face: Vector2 = Vector2.ZERO) -> void:
	assert(path_following_logic, "No Path Following logic")
	
	if direction_to_face == Vector2.ZERO:
		path_following_logic.add_point_to_path(destination_point)
	else:
		path_following_logic.add_point_to_path(destination_point,direction_to_face)

func walk_toward_state(delta):
	if IS_PLAYER_MASKED:
		path_following_logic.walk_path(delta, IDLE_MASKED_ANIMATION_KEY, WALK_MASKED_ANIMATION_KEY)
	else:
		path_following_logic.walk_path(delta)

func player_path_following_started():
	state_before_walk_toward_stake = state
	state = States.WALK_TOWARD
	emit_signal("on_path_following_started")

func player_path_following_ended():
	state = state_before_walk_toward_stake
	emit_signal("on_path_following_ended")

func set_player_as_in_cutscene():
	cutscene_queue += 1
	if not is_player_in_cutscene:
		velocity = Vector2.ZERO
		travel_to_idle_animation()
		is_player_in_cutscene = true

func set_player_as_not_in_cutscene():
	cutscene_queue = max(0, cutscene_queue - 1)
	if cutscene_queue == 0:
		is_player_in_cutscene = false
		state = States.WALK

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

func attack():
	if Bullet:
		play_fire_sfx()
		
		var bullet = Bullet.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = bullet_point.global_position
		bullet.set_collision_layer_value(5, true)
		var bullet_rotation = deg_to_rad(0)
		match utils.get_cardinal_direction(player_direction):
			Vector2.UP:
				bullet.global_position -= Vector2(0,30) + Vector2(randf_range(-5, 5), 0)
				bullet_rotation = deg_to_rad(270)
			Vector2.DOWN:
				bullet.global_position -= Vector2(0,-10) + Vector2(randf_range(-5, 5), 0)
				bullet_rotation = deg_to_rad(90)
			Vector2.LEFT:
				bullet.global_position -= Vector2(30,0) + Vector2(0, randf_range(-5, 5))
				bullet_rotation = deg_to_rad(180)
			Vector2.RIGHT:
				bullet.global_position += Vector2(30,0) + Vector2(0, randf_range(-5, 5))
				bullet_rotation = deg_to_rad(360)
		bullet.rotation = bullet_rotation


func _on_projectile_timer_timeout():
	attack()

func death():
	state = States.WALK
	travel_to_idle_animation()
	music_player.stop_background_music()
	is_player_dead = true
	projectile_timer.stop()
	if audio_stream_player.playing:
		audio_stream_player.stop()
	audio_stream_player.stream = load("res://sounds/sfx/game_over.mp3")
	audio_stream_player.play()
	
	var tween = create_tween()
	tween.tween_property(self, "rotation", deg_to_rad(-90), 0.05)
	tween.play()
	
	await get_tree().create_timer(3).timeout
	start_fade_out()

func start_fade_out(duration: float = 1.0):
	color_rect.visible = true
	var tween = create_tween()
	tween.tween_property(color_rect, "color", Color(color_rect.color.r, color_rect.color.g, color_rect.color.b, 1.0), duration)
	tween.finished.connect(change_to_main_scene)
	tween.play()

func change_to_main_scene():
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://menu/main_menu.tscn")

func revive_player():
	low_life_sound_played = false
	is_player_dead = false
	player_stats.health = player_stats.max_health

func _on_hurtbox_area_entered(area):
	if not hurtbox.invincible and not is_player_dead:
		player_stats.health -= area.damage
		
		if not low_life_sound_played and  player_stats.health <= (10 * player_stats.max_health) / 100:
			low_life_sound_played = true
			if audio_stream_player.playing:
				audio_stream_player.stop()
			audio_stream_player.stream = load("res://sounds/sfx/low_life.mp3")
			audio_stream_player.play()
		
		velocity = area.knockback_vector * 150
		hurtbox.start_invincibility(0.4)

func _on_hurtbox_invicibility_started():
	blink_animation_player.play("start")

func _on_hurtbox_invincibility_ended():
	blink_animation_player.play("stop")
