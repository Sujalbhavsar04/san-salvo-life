class_name Utils
extends Object

func face_direction(animation_tree: AnimationTree, animation_tree_parameters: Array, direction: Vector2) -> void:
	for parameter in animation_tree_parameters:
		animation_tree.set(parameter, direction)

func get_cardinal_direction(direction: Vector2) -> Vector2:
	if abs(direction.x) - abs(direction.y) == 0:
		if direction.x > 0 and direction.y > 0:
			return Vector2.RIGHT
		
		if direction.x > 0 and direction.y < 0:
			return Vector2.RIGHT
		
		if direction.x < 0 and direction.y > 0:
			return Vector2.LEFT
		
		if direction.x < 0 and direction.y < 0:
			return Vector2.LEFT
	
	if direction == Vector2.ZERO:
		return Vector2.ZERO  # No movement

	# Determine the dominant axis
	if abs(direction.x) > abs(direction.y):
		return Vector2.RIGHT if direction.x > 0 else Vector2.LEFT
	
	return Vector2.DOWN if direction.y > 0 else Vector2.UP

