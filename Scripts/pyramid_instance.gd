extends CharacterBody3D


@export var speed : float = 6.0

var player : Node3D = null
var mat_dict := Global.make_material_with_random_color()
var mat: Material = mat_dict["material"]
var enemy_color_code: int = mat_dict["color_id"]

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)
	$CSGCylinder3D/Area3D.body_entered.connect(_on_body_entered_2)

	create_pyramid_mesh()
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0] 

func create_pyramid_mesh():
	var pyramid = ArrayMesh.new()
	var arrays = []

	# Properly use PackedVector3Array
	var verts := PackedVector3Array([
		Vector3(0, 2, 0),       # Top moved up
		Vector3(-1, 0, -1),     # Base at y = 0
		Vector3(1, 0, -1),
		Vector3(1, 0, 1),
		Vector3(-1, 0, 1),
	])

	# Also needs to be PackedInt32Array
	var indices := PackedInt32Array([
		0, 1, 2, # Side 1
		0, 2, 3, # Side 2
		0, 3, 4, # Side 3
		0, 4, 1, # Side 4
		1, 2, 3, # Base triangle 1
		1, 3, 4  # Base triangle 2
	])

	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_INDEX] = indices

	pyramid.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	var mesh_instance = MeshInstance3D.new()
	
	mesh_instance.mesh = pyramid
	mesh_instance.material_override = mat
	add_child(mesh_instance)

func _physics_process(_delta):
	var direction = (player.global_transform.origin - global_transform.origin)
	direction.y = 0  # stay on the ground
	look_at(global_transform.origin + direction, Vector3.UP)
	velocity = direction.normalized() * speed
	move_and_slide()

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Character touched the pyramid!")
		body.take_damage(10)  # If your character has a take_damage function

func _on_body_entered_2(body):
	if body.is_in_group("player"):
		print("Character touched the pyramid!")
		body.take_damage(10)  # If your character has a take_damage function
