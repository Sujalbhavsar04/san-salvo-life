extends Control

var player_stats = PlayerStats

@onready var empty_hearts = $EmptyHearts
@onready var full_hearts = $FullHearts

var hearts = 10:
	get:
		return hearts
	set(value):
		hearts = clamp(value, 0, max_hearts)
		if full_hearts != null:
			full_hearts.set_size(Vector2(hearts * 32, 32))

var max_hearts = 10:
	get:
		return max_hearts
	set(value):
		max_hearts = max(value, 1)
		self.hearts = min(hearts, max_hearts)
		if empty_hearts != null:
			empty_hearts.set_size(Vector2(max_hearts * 32, 32))

func set_hearts(value):
	self.hearts = value

func set_max_hearts(value):
	self.max_hearts = value

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.health_changed.connect(set_hearts)
	PlayerStats.max_health_changed.connect(set_max_hearts)
