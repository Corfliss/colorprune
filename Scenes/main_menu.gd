extends Control

func _ready():
	%StartButton.pressed.connect(_on_start_pressed)
	%InfoButton.pressed.connect(_on_info_pressed)
	%QuitButton.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/Sandbox.tscn")  # Your main game scene

func _on_info_pressed():
	%InfoPanel.visible = !%InfoPanel.visible

func _on_quit_pressed():
	get_tree().quit()
