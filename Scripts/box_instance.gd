# box_instance.gd
extends CharacterBody3D

var player: Node3D = null
var speed: float = 4.0
var circle_direction: int = 1
var decision_time: float = 1.0
var decision_timer: float = 0.0
var current_velocity: Vector3
var kite_distance: float = 10.0
var min_shooting_range: float = 6.0
var max_shooting_range: float = 12.0
var mat_dict := Global.make_material_with_random_color()
var mat: Material = mat_dict["material"]
var enemy_color_code: int = mat_dict["color_id"]

@export var shoot_interval: float = 2.0
@export var cannonball_scene: PackedScene
var shoot_timer: float = 0.0

func _ready():
	var players = get_tree().get_nodes_in_group("player")	
	if players.size() > 0:
		player = players[0]
	$Box.material = mat
		

func _physics_process(_delta):
	# Shooting logic
	shoot_timer -= _delta
	if shoot_timer <= 0.0 and is_in_shooting_range():
		shoot_cannonball()
		shoot_timer = shoot_interval
		
	# Face the player
	var direction = (player.global_transform.origin - global_transform.origin)
	direction.y = 0
	if direction.length() > 0:
		look_at(global_transform.origin + direction, Vector3.UP)

	# Countdown and decide movement
	decision_timer -= _delta
	if decision_timer <= 0.0:
		current_velocity = calculate_movement_decision()
		decision_timer = decision_time + randf_range(-0.2, 0.2)

	# Move using the decided velocity
	velocity = current_velocity
	move_and_slide()

func calculate_movement_decision() -> Vector3:
	var to_player = player.global_transform.origin - global_transform.origin
	to_player.y = 0
	var dist = to_player.length()
	
	# Optional: Change circling direction per decision
	circle_direction = 1 if randf() < 0.5 else -1
	
	if dist < kite_distance:
		return -to_player.normalized() * speed
	# No need for this
	# elif dist >= kite_distance:
		# return to_player.normalized() * speed
	else:
		var tangent = Vector3(-to_player.z, 0, to_player.x).normalized() * circle_direction
		return tangent * speed
		
func is_in_shooting_range() -> bool:
	var dist = global_transform.origin.distance_to(player.global_transform.origin)
	return dist >= min_shooting_range and dist <= max_shooting_range  # Mid-range

func shoot_cannonball():
	var cannonball = cannonball_scene.instantiate()
	get_tree().current_scene.add_child(cannonball)

	# Spawn point
	var spawn_pos = global_transform.origin + Vector3.UP * 1.5
	cannonball.global_transform.origin = spawn_pos

	# Calculate launch direction with arc
	var to_player = player.global_transform.origin - spawn_pos
	to_player.y += 3.0  # Aim slightly higher for arc
	var impulse = to_player.normalized() * 15.0
	cannonball.apply_impulse(impulse)
