class_name PlayerFollowingLogic
extends Object

const WALK_TOWARD_DIRECTION_SPEED = 40
const DISTANCE_IN_BETWEEN = 25
const MINIMUM_DISTANCE_IN_BETWEEN = 5
const IDLE_ANIMATION_KEY = "Idle"
const WALK_ANIMATION_KEY = "Walk"
const WALK_SLOWLY_ANIMATION_KEY = "WalkSlowly"
const SLOW_SPEED_THRESHOLD = 80

var body: NPC
var body_speed: int
var player: Player
var animation_tree: AnimationTree
var animation_tree_parameters: Array
var animation_state

func _init(npc: NPC, speed: int, body_animation_tree: AnimationTree, body_animation_tree_parameters: Array, player_to_follow: Player):
	assert(npc, "No body selected")
	assert(speed, "No speed selected")
	assert(body_animation_tree, "No body animation tree selected")
	assert(body_animation_tree_parameters, "No body animation tree parameters specified")
	body = npc
	body_speed = speed
	animation_tree = body_animation_tree
	animation_state = body_animation_tree.get("parameters/playback")
	animation_tree_parameters = body_animation_tree_parameters
	player = player_to_follow

func follow_player() -> void:
	assert(player, "There is no player to follow")
	
	var target_position = (player.position - body.position).normalized()
	var distance = body.position.distance_to(player.position)
	var new_body_direction = player.get_player_follow_direction()
	
	if new_body_direction != Vector2.ZERO:
		if distance < MINIMUM_DISTANCE_IN_BETWEEN or distance > DISTANCE_IN_BETWEEN:
			body.face_direction(new_body_direction)
		
		if body_speed > SLOW_SPEED_THRESHOLD: # walking normally
			reduce_distance(distance, target_position, WALK_ANIMATION_KEY)
		else: # walking slowly
			reduce_distance(distance, target_position, WALK_SLOWLY_ANIMATION_KEY)
	else:
		animation_state.travel(IDLE_ANIMATION_KEY)
		body.velocity = Vector2.ZERO
	
	# prevents some sprite_2D bugs and also that npc continues to walk when player is in cutscene or going from one room to another
	if player.velocity == Vector2.ZERO:
		animation_state.travel(IDLE_ANIMATION_KEY)
		body.velocity = Vector2.ZERO

func reduce_distance(distance: float, target_position: Vector2, walk_animation_key: String):
	if distance > DISTANCE_IN_BETWEEN:
		animation_state.travel(walk_animation_key)
		body.velocity = body.velocity.move_toward(target_position * body_speed, body_speed)
		body.move_and_slide()

func match_player_speed():
	body_speed = player.SPEED
