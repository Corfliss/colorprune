extends Node

var bgm_player: AudioStreamPlayer
var layer_player: AudioStreamPlayer

var bgm_track: AudioStreamWAV = preload("res://Assets/BGMMainMenuCut.wav")
var extra_track: AudioStreamWAV = preload("res://Assets/PluckyNote.wav")
var score: float = 0.0

func _ready() -> void:
# Create both players
	bgm_player = AudioStreamPlayer.new()
	layer_player = AudioStreamPlayer.new()

	bgm_player.stream = bgm_track
	layer_player.stream = extra_track

	add_child(bgm_player)
	add_child(layer_player)

	bgm_player.bus = "Music"
	layer_player.bus = "Music"  # Or use another bus if mixing separately

	bgm_player.play()
	bgm_player.finished.connect(func():
		bgm_player.play()  # Manually restart
	)

func play_layer():
	layer_player.play()
	layer_player.connect("finished", Callable(self, "_on_layer_finished"))

func _on_layer_finished():
	layer_player.play()

# Returns a tuple of (color_id, Color)
func get_random_color() -> Array:
	var colors = {
		0: Color("EE4444"), # Red
		1: Color("44EE44"), # Green
		2: Color("4444EE")  # Blue
	}
	var keys = colors.keys()
	var random_id = keys[randi() % keys.size()]
	return [random_id, colors[random_id]]
	
func make_material_with_random_color() -> Dictionary:
	var result = get_random_color()
	var color_id = result[0]
	var color = result[1]

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color

	return {
		"material": material,
		"color_id": color_id
	}
