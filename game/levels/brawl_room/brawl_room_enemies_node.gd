extends Node2D

func _ready():
	for mob in self.get_children():
		mob.mob_died.connect(revive_mob)

func revive_mob(mob: Mob):
	await get_tree().create_timer(60 * 5).timeout
	mob.revive()
