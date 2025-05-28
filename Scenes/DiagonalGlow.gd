extends ColorRect

@onready var mat := material as ShaderMaterial
var time_passed := 0.0

func _process(delta):
	time_passed += delta
	mat.set_shader_parameter("time", time_passed)
