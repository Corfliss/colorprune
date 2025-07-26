extends Control

func _ready():
	%BackButton.pressed.connect(_on_back_pressed)
	%ScoreLabel.text = str(Global.score).pad_decimals(2)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")  # Your main game scene
