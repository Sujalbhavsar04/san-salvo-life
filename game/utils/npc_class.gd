class_name NPC
extends CharacterBody2D

signal on_path_following_started
signal on_path_following_ended

enum Directions {
	NONE,
	UP,
	DOWN,
	RIGHT,
	LEFT
}

const DIRECTIONS_ARRAY = [Vector2.ZERO, Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]
@export var faced_direction: Directions = Directions.NONE
@export var SPEED = 150
@export var player: Player

enum States {
	IDLE,
	FOLLOW_PLAYER,
	WALK_TOWARD
}

var state: States = States.IDLE

@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var collision_shape_2D: CollisionShape2D = $CollisionShape2D
@onready var sprite_2D: Sprite2D = $Sprite2D

const PlayerFollowingLogic = preload("res://utils/player_following_logic.gd")
const PathFollowingLogic = preload("res://utils/path_following_logic.gd")
const ANIMATION_TREE_PARAMETERS = [
	"parameters/Idle/blend_position",
	"parameters/Walk/blend_position"
]

var player_following_logic: PlayerFollowingLogic
var path_following_logic: PathFollowingLogic

func _ready():
	assert(player, "No player selected")
	assert(faced_direction != Directions.NONE, "No direction selected")
	animation_tree.active = true
	
	player_following_logic = PlayerFollowingLogic.new(self, SPEED, animation_tree, ANIMATION_TREE_PARAMETERS, player)
	
	path_following_logic = PathFollowingLogic.new(self, animation_tree, ANIMATION_TREE_PARAMETERS)
	path_following_logic.on_path_following_started.connect(path_following_started)
	path_following_logic.on_path_following_ended.connect(path_following_ended)
	
	face_direction(DIRECTIONS_ARRAY[faced_direction])
	
	player.on_speed_changed.connect(set_NPC_player_follow_speed_same_as_player)

func _physics_process(delta):
	match state:
		States.IDLE:
			idle_state()
		States.FOLLOW_PLAYER:
			follow_player_state()
		States.WALK_TOWARD:
			walk_toward_state(delta)

func idle_state():
	animation_state.travel("Idle")

func start_player_follow():
	assert(player, "No player to follow selected")
	collision_shape_2D.disabled = true
	state = States.FOLLOW_PLAYER

func stop_player_follow():
	collision_shape_2D.disabled = false
	state = States.IDLE

func follow_player_state():
	player_following_logic.follow_player()

func set_walk_toward_state(destination_point: Vector2, direction_to_face: Vector2 = Vector2.ZERO) -> void:
	assert(path_following_logic, "No Path Following logic")
	
	if direction_to_face == Vector2.ZERO:
		path_following_logic.add_point_to_path(destination_point)
	else:
		path_following_logic.add_point_to_path(destination_point,direction_to_face)

func walk_toward_state(delta):
	path_following_logic.walk_path(delta)

func face_direction(direction: Vector2) -> void:
	assert(path_following_logic, "No Path Following logic")
	path_following_logic.face_direction(direction)

func get_facing_direction() -> Vector2:
	assert(path_following_logic, "No Path Following logic")
	return path_following_logic.get_facing_direction()

func path_following_started():
	state = States.WALK_TOWARD
	emit_signal("on_path_following_started")

func path_following_ended():
	state = States.IDLE
	emit_signal("on_path_following_ended")

func set_NPC_player_follow_speed_same_as_player(new_speed, is_do_match_player_following_bodies_speed_with_player_speed):
	if is_do_match_player_following_bodies_speed_with_player_speed:
		SPEED = new_speed
		player_following_logic.match_player_speed()
