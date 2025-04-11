extends CanvasLayer

@onready var dialogue_controller: DialogueController = $DialogueController

func _ready():
	dialogue_controller.dialogues_path = {
		"cutscene_1": [
			"res://dialogues/levels/chinese_shop/chinese_shop_cutscene_1_dialogue_1.json",
			"res://dialogues/levels/chinese_shop/chinese_shop_cutscene_1_dialogue_2.json"
		]
	}

func play_cutscene_1_dialogue():
	dialogue_controller.play_dialogue("cutscene_1")
