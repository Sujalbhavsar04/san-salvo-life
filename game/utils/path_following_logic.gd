class_name PathFollowingLogic
extends Object

signal on_path_following_started
signal on_path_following_ended

const DEFAULT_SPEED = 40
const IDLE_ANIMATION_KEY = "Idle"
const WALK_ANIMATION_KEY = "Walk"

const Utils = preload("res://utils/utils.gd")

var current_point_to_walk_toward_index: int = 0

var body: CharacterBody2D
var path: Array = []
var animation_tree: AnimationTree
var animation_tree_parameters: Array
var animation_state

var current_speed: int

var utils: Utils

func _init(character_body_2D: CharacterBody2D, body_animation_tree: AnimationTree, body_animation_tree_parameters: Array):
	assert(character_body_2D, "No body selected")
	assert(body_animation_tree, "No body animation tree selected")
	assert(body_animation_tree_parameters, "No body animation tree parameters specified")
	body = character_body_2D
	animation_tree = body_animation_tree
	animation_state = body_animation_tree.get("parameters/playback")
	animation_tree_parameters = body_animation_tree_parameters
	
	reset_speed()
	
	utils = Utils.new()

func add_point_to_path(destination_point: Vector2, direction_to_face: Vector2 = Vector2.ZERO) -> void:
	
	if direction_to_face == Vector2.ZERO:
		direction_to_face = body.global_position.direction_to(destination_point)
	
	if path.size() == 0:
		emit_signal("on_path_following_started")
	path.append([destination_point, direction_to_face])

func walk_path(delta, idle_animation_key = IDLE_ANIMATION_KEY, walk_animation_key = WALK_ANIMATION_KEY) -> void:
	assert(path.size() != 0, "There are no destination points")
	
	if current_point_to_walk_toward_index < path.size():
		assert(path[current_point_to_walk_toward_index][0], "No point in path")
		assert(path[current_point_to_walk_toward_index][1], "Point has no direction")
		
		var point_to_walk_toward = path[current_point_to_walk_toward_index][0]
		var direction_to_face_while_walking_toward_point = path[current_point_to_walk_toward_index][1]
		
		if body.global_position != point_to_walk_toward:
			var direction = body.global_position.move_toward(point_to_walk_toward, current_speed * delta)
			face_direction(direction_to_face_while_walking_toward_point)
			animation_state.travel(walk_animation_key)
			body.global_position = direction
		else:
			face_direction(direction_to_face_while_walking_toward_point)
			current_point_to_walk_toward_index += 1
	else:
		emit_signal("on_path_following_ended")
		reset_speed()
		path = []
		current_point_to_walk_toward_index = 0
		animation_state.travel(idle_animation_key)

func face_direction(direction: Vector2) -> void:
	utils.face_direction(animation_tree, animation_tree_parameters, direction)

func get_facing_direction() -> Vector2:
	if animation_tree_parameters.size() == 0:
		return Vector2.ZERO
	return animation_tree.get(animation_tree_parameters[0])

func change_speed(new_speed: int) -> void:
	current_speed = new_speed

func reset_speed() -> void:
	current_speed = DEFAULT_SPEED
