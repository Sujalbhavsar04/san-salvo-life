extends Node

@onready var player: Player = $"../Player"
@onready var john_the_chinese: JohnTheChinese = $"../JohnTheChinese"

func go_near_john():
	if player.global_position != Vector2(309, 379): # this check avoids bugs due to missing direction
		player.set_walk_toward_state(Vector2(309, 379))
	player.set_walk_toward_state(Vector2(309, 379), Vector2.LEFT)

func john_the_chinese_goes_near_register():
	if john_the_chinese.global_position != Vector2(260, 379): # this check avoids bugs due to missing direction
		john_the_chinese.set_walk_toward_state(Vector2(260, 379))
	john_the_chinese.set_walk_toward_state(Vector2(260, 379), Vector2.UP)

func john_the_chinese_goes_near_register_again():
	john_the_chinese.set_walk_toward_state(Vector2(260, 365), Vector2.UP)

func john_the_chinese_moves_away_from_the_register():
	john_the_chinese.set_walk_toward_state(Vector2(190, 377))
	john_the_chinese.set_walk_toward_state(Vector2(190, 377), Vector2.RIGHT)

func player_moves_near_register():
	player.set_walk_toward_state(Vector2(261, 375))
	player.set_walk_toward_state(Vector2(261, 375), Vector2.UP)

func player_escapes():
	player.set_walk_toward_state(Vector2(417, 380))
