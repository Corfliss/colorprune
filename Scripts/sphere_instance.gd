extends CharacterBody3D

@export var damage: int = 20
@export var charge_time: float = 2.5  # Increased from 1.5 to 2.5 for longer lock-in delay
@export var cooldown: float = 3.0
@export var attack_range: float = 50.0
@export var target_lock_time: float = 1.0  # Added dedicated lock-in time before firing

var player: Node3D
var shoot_timer: float = 0.0
var charging: bool = false
var locking: bool = false  # Track if we're in the locking phase
var mat_dict := Global.make_material_with_random_color()
var mat: Material = mat_dict["material"]
var enemy_color_code: int = mat_dict["color_id"]
var enemy_color: Color = mat.albedo_color
var speed: float = 2.0
var fire_next_frame = false
var lock_timer: float = 0.0
var locked_hit_position: Vector3 = Vector3.ZERO
var locked_hit_valid: bool = false

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	$Body.material = mat
	$Muzzle/SniperRay.enabled = false
	clear_laser()

func _physics_process(_delta):
	if not player:
		return

	var to_player = player.global_transform.origin - global_transform.origin
	to_player.y = 0
	var distance = to_player.length()

	look_at(player.global_transform.origin, Vector3.UP)

	shoot_timer -= _delta

	if shoot_timer <= 0.0 and not charging and not locking:
		start_locking()

	if locking:
		lock_timer -= _delta

		# Only update beam if still locking
		if lock_timer > 0.0:
			var current_origin = $Muzzle.global_transform.origin
			var current_direction = (player.global_transform.origin + Vector3.UP * 1 - current_origin).normalized()
			var max_point = current_origin + current_direction * attack_range

			$Muzzle/SniperRay.look_at($Muzzle/SniperRay.global_transform.origin + current_direction, Vector3.UP)
			$Muzzle/SniperRay.force_raycast_update()

			var target_point = max_point
			if $Muzzle/SniperRay.is_colliding():
				target_point = $Muzzle/SniperRay.get_collision_point()

			create_laser(current_origin, target_point, 0.01)  # <-- Only updated during locking

	#if locking:
		#lock_timer -= _delta
#
		#var current_origin = $Muzzle.global_transform.origin
		#var current_direction = (player.global_transform.origin + Vector3.UP * 0.5 - current_origin).normalized()
		#var max_point = current_origin + current_direction * attack_range
#
		#$Muzzle/SniperRay.look_at($Muzzle/SniperRay.global_transform.origin + current_direction, Vector3.UP)
		#$Muzzle/SniperRay.force_raycast_update()
#
		#var target_point = max_point
		#if $Muzzle/SniperRay.is_colliding():
			#target_point = $Muzzle/SniperRay.get_collision_point()
#
		#create_laser(current_origin, target_point, 0.01)
#
		#if lock_timer <= 0.0:
			#locking = false
			#start_charging()
#
	#if fire_next_frame:
		#fire_hitscan()
		#fire_next_frame = false

func create_laser(from_global: Vector3, to_global: Vector3, thickness: float = 0.01):
	var direction = to_global - from_global
	var length = direction.length()
	if length == 0:
		return

	var dir = direction.normalized()
	var forward = dir.cross(Vector3.FORWARD).normalized()

	var offset = forward * (thickness / 2.0)

	var a = from_global - offset
	var b = from_global + offset
	var c = to_global + offset
	var d = to_global - offset

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	st.set_material(mat)

	st.add_vertex($LaserMesh.to_local(a))
	st.add_vertex($LaserMesh.to_local(b))
	st.add_vertex($LaserMesh.to_local(d))
	st.add_vertex($LaserMesh.to_local(c))

	var mesh = st.commit()
	$LaserMesh.mesh = mesh

#func create_laser(from_global: Vector3, to_global: Vector3, thickness: float = 0.2):
	#var direction = to_global - from_global
	#var length = direction.length()
	#if length == 0:
		#return
	#
	## Create a new QuadMesh and assign dimensions
	#var mesh = QuadMesh.new()
	#mesh.size = Vector2(length, thickness)
	#
	## Assign mesh and material
	#$LaserMesh.mesh = mesh
	#$LaserMesh.material_override = mat
	#
	## Calculate basis to orient the laser towards the target
	#var forward = direction.normalized()
	#var up = Vector3.UP
#
	#if abs(forward.dot(up)) > 0.95:
		#up = Vector3.FORWARD  # Avoid gimbal lock when aiming mostly up
#
	#var basis = Basis().looking_at(forward, up)
	## Rotate so the quad lies in the correct plane (facing forward)
	##basis = basis.rotated(Vector3.RIGHT, deg_to_rad(-90))
#
	## Build the final transform (position and rotation)
	#var laser_transform = Transform3D()
	#laser_transform.basis = basis
	#laser_transform.origin = from_global + forward * (length / 2.0)  # Offset so it starts at the muzzle
	#
	## Apply the transform to the laser mesh node
	#$LaserMesh.global_transform = laser_transform
	
	
	#var immediate := ImmediateMesh.new()
	#immediate.surface_begin(Mesh.PRIMITIVE_LINES)
#
	## Convert global positions to LaserMesh local space (assuming LaserMesh is a direct child of root or common parent)
	#var local_from = $LaserMesh.to_local(from_global)
	#var local_to = $LaserMesh.to_local(to_global)
#
	## Simple single line (thin)
	#immediate.surface_add_vertex(local_from)
	#immediate.surface_add_vertex(local_to)
	#immediate.surface_end()
#
	#$LaserMesh.mesh = immediate
	#$LaserMesh.material_override = mat

func clear_laser():
	$LaserMesh.mesh = null

# New function for the lock-on phase
func start_locking():
	locking = true
	lock_timer = target_lock_time
	$Muzzle/SniperRay.enabled = true

func start_charging():
	charging = true
	var origin = $Muzzle.global_transform.origin
	var direction = (player.global_transform.origin - origin).normalized()
	var max_point = origin + direction * attack_range
	
	# Setup RayCast3D
	var ray = $Muzzle/SniperRay
	ray.enabled = false  # reset to avoid race condition
	ray.transform.origin = Vector3.ZERO
	ray.target_position = Vector3(0, 0, attack_range)
	# Align the Muzzle itself to face the player direction
	# (if Muzzle doesn't rotate, we rotate the Ray itself)
	ray.look_at(ray.global_transform.origin + direction, Vector3.UP)
	ray.enabled = true
	ray.force_raycast_update()
	
	# Store the locked position for future hitscan
	locked_hit_position = max_point
	locked_hit_valid = true
	if ray.is_colliding():
		locked_hit_position = ray.get_collision_point()
	
	# Create thicker laser during charge phase
	create_laser(origin, locked_hit_position, 1.5)
	
	await get_tree().create_timer(charge_time).timeout
	fire_next_frame = true

func fire_hitscan():
	if not locked_hit_valid:
		clear_laser()
		$Muzzle/SniperRay.enabled = false
		charging = false
		shoot_timer = cooldown
		return
		
	var origin = $Muzzle.global_transform.origin
	var to_locked = locked_hit_position
	var space_state = get_world_3d().direct_space_state
	
	# Cast ray again from origin to locked_hit_position
	var query = PhysicsRayQueryParameters3D.new()
	query.from = origin
	query.to = locked_hit_position
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit = result.collider
		var real_target = hit
		while real_target and not real_target.has_method("take_damage"):
			real_target = real_target.get_parent()
		if real_target and real_target.is_in_group("player"):
			real_target.take_damage(damage)
	
	clear_laser()
	$Muzzle/SniperRay.enabled = false
	charging = false
	shoot_timer = cooldown
