# I love the mechanics, and I hate to make it one by one
# So, that's even it out
extends Node3D

const SHOTGUN_PELLET_COUNT := 8
const SHOTGUN_SPREAD_ANGLE := 10 # degrees
const RIFLE_SPREAD_ANGLE := 5 # degrees

#region Node
@export_group("Nodes")
@export var aim_raycast : RayCast3D
#endregion

@onready var weapon_blue = $WeaponPistol/WeaponBlue
@onready var weapon_blue_mesh: Mesh = weapon_blue.mesh
@onready var weapon_blue_mat: Material = weapon_blue_mesh.surface_get_material(0)
@onready var weapon_blue_color: Color = weapon_blue_mat.albedo_color

@onready var weapon_red = $WeaponShotgun/WeaponRed
@onready var weapon_red_mesh: Mesh = weapon_red.mesh
@onready var weapon_red_mat: Material = weapon_red_mesh.surface_get_material(0)
@onready var weapon_red_color: Color = weapon_red_mat.albedo_color

@onready var weapon_green = $WeaponRifle/WeaponGreen
@onready var weapon_green_mesh: Mesh = weapon_green.mesh
@onready var weapon_green_mat: Material = weapon_green_mesh.surface_get_material(0)
@onready var weapon_green_color: Color = weapon_green_mat.albedo_color

#region Helper Function
func get_spread_direction(forward: Vector3, spread: int) -> Vector3:
	var random_rot = Basis()
	random_rot = random_rot.rotated(Vector3.UP, deg_to_rad(randf_range(-spread, spread)))
	random_rot = random_rot.rotated(Vector3.RIGHT, deg_to_rad(randf_range(-spread, spread)))
	return (random_rot * forward).normalized()
#endregion

#region Shooting Style
func shoot_blue_sysone_nohold_lmb():
	if !aim_raycast:
		print("Raycast node is missing.")
		return

	var origin = aim_raycast.global_transform.origin
	var target = origin - aim_raycast.global_transform.basis.z * 100.0

	print("Ray from:", origin, " to:", target)

	var ray_params = PhysicsRayQueryParameters3D.create(origin, target)
	ray_params.collision_mask = 0xFFFFFFFF  # Ray checks all layers
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(ray_params)

	if result and result.has("collider") and result.collider is Node:
		var hit = result.collider
		print("Hit object:", hit.name)
		if hit.is_in_group("enemy"):
			if hit.enemy_color_code == 2:
				hit.queue_free()
				%EnemyHit.play()
			else:
				print("Color mismatch: hit color =", hit.enemy_color_code, " weapon color =", weapon_blue_color)
		else:
			print("Hit object is not a valid enemy or missing color.")
	else:
		print("Raycast hit nothing or unrecognized object: ", result)
	$WeaponPistol/BluePistolShoot.play()

func shoot_blue_sysone_nohold_rmb():
	# TODO: implement logic for shoot_blue_sysone_nohold_rmb
	pass

func shoot_blue_sysone_nohold_bmb():
	# TODO: implement logic for shoot_blue_sysone_nohold_bmb
	pass

func shoot_blue_sysone_hold_lmb():
	# TODO: implement logic for shoot_blue_sysone_hold_lmb
	pass

func shoot_blue_sysone_hold_rmb():
	# TODO: implement logic for shoot_blue_sysone_hold_rmb
	pass

func shoot_blue_sysone_hold_bmb():
	# TODO: implement logic for shoot_blue_sysone_hold_bmb
	pass

func shoot_blue_systwo_nohold_lmb():
	# TODO: implement logic for shoot_blue_systwo_nohold_lmb
	pass

func shoot_blue_systwo_nohold_rmb():
	# TODO: implement logic for shoot_blue_systwo_nohold_rmb
	pass

func shoot_blue_systwo_nohold_bmb():
	# TODO: implement logic for shoot_blue_systwo_nohold_bmb
	pass

func shoot_blue_systwo_hold_lmb():
	# TODO: implement logic for shoot_blue_systwo_hold_lmb
	pass

func shoot_blue_systwo_hold_rmb():
	# TODO: implement logic for shoot_blue_systwo_hold_rmb
	pass

func shoot_blue_systwo_hold_bmb():
	# TODO: implement logic for shoot_blue_systwo_hold_bmb
	pass

#func shoot_red_sysone_nohold_lmb():
	#for i in SHOTGUN_PELLET_COUNT:
		#var spread_dir = get_spread_direction(aim_raycast.global_transform.basis.z.normalized())
		#var ray_origin = aim_raycast.global_transform.origin
		#var ray_target = ray_origin + spread_dir * 100.0 # 100 units ahead
#
		#var ray_params = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
		#var result = get_world_3d().direct_space_state.intersect_ray(ray_params)
#
		#if result:
			#var hit = result.collider
			#if hit.is_in_group("enemy"):
				#hit.queue_free() # or hit.take_damage(amount)

func shoot_red_sysone_nohold_lmb():
	if !aim_raycast:
		print("Raycast node is missing.")
		return

	for i in SHOTGUN_PELLET_COUNT:
		var spread_dir = get_spread_direction(-aim_raycast.global_transform.basis.z.normalized(), SHOTGUN_SPREAD_ANGLE) # ← direction fix
		var ray_origin = aim_raycast.global_transform.origin
		var ray_target = ray_origin + spread_dir * 100.0

		print("Pellet", i, ": Ray from:", ray_origin, " to:", ray_target)

		var ray_params = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
		ray_params.collision_mask = 0xFFFFFFFF  # Hit everything
		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(ray_params)

		if result and result.has("collider") and result.collider is Node:
			var hit = result.collider
			print("Hit object (Pellet %d): %s" % [i, hit.name])

			if hit.is_in_group("enemy"):
				if hit.enemy_color_code == 0:
					hit.queue_free()
					%EnemyHit.play()
		else:
			print("Pellet %d hit nothing or non-Node: %s" % [i, str(result)])
		#if result and result.has("collider") and result.collider is Node:
			#var hit = result.collider
			#if hit.is_in_group("enemy"):
				#hit.queue_free()
			#else:
				#print("Raycast hit nothing or unrecognized object: ", result)
	$WeaponShotgun/RedShotgunShoot.play()

func shoot_red_sysone_nohold_rmb():
	# TODO: implement logic for shoot_red_sysone_nohold_rmb
	pass

func shoot_red_sysone_nohold_bmb():
	# TODO: implement logic for shoot_red_sysone_nohold_bmb
	pass

func shoot_red_sysone_hold_lmb():
	# TODO: implement logic for shoot_red_sysone_hold_lmb
	pass

func shoot_red_sysone_hold_rmb():
	# TODO: implement logic for shoot_red_sysone_hold_rmb
	pass

func shoot_red_sysone_hold_bmb():
	# TODO: implement logic for shoot_red_sysone_hold_bmb
	pass

func shoot_red_systwo_nohold_lmb():
	# TODO: implement logic for shoot_red_systwo_nohold_lmb
	pass

func shoot_red_systwo_nohold_rmb():
	# TODO: implement logic for shoot_red_systwo_nohold_rmb
	pass

func shoot_red_systwo_nohold_bmb():
	# TODO: implement logic for shoot_red_systwo_nohold_bmb
	pass

func shoot_red_systwo_hold_lmb():
	# TODO: implement logic for shoot_red_systwo_hold_lmb
	pass

func shoot_red_systwo_hold_rmb():
	# TODO: implement logic for shoot_red_systwo_hold_rmb
	pass

func shoot_red_systwo_hold_bmb():
	# TODO: implement logic for shoot_red_systwo_hold_bmb
	pass

func shoot_green_sysone_nohold_lmb():
	if !aim_raycast:
		print("Raycast node is missing.")
		return
	var forward_dir = -aim_raycast.global_transform.basis.z.normalized()

	# Slight random spray
	var spread_dir = get_spread_direction(forward_dir, RIFLE_SPREAD_ANGLE)

	var ray_origin = aim_raycast.global_transform.origin
	var ray_target = ray_origin + spread_dir * 100.0

	print("Spray shot from:", ray_origin, " to:", ray_target)

	var ray_params = PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
	ray_params.collision_mask = 0xFFFFFFFF
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(ray_params)

	if result and result.has("collider") and result.collider is Node:
		var hit = result.collider
		print("Spray hit object:", hit.name)

		if hit.is_in_group("enemy"):
			if hit.enemy_color_code == 1:
				hit.queue_free()
				%EnemyHit.play()
	else:
		print("Spray hit nothing or non-Node:", result)
	$WeaponRifle/GreenRifleShoot.play()

func shoot_green_sysone_nohold_rmb():
	# TODO: implement logic for shoot_green_sysone_nohold_rmb
	pass

func shoot_green_sysone_nohold_bmb():
	# TODO: implement logic for shoot_green_sysone_nohold_bmb
	pass

func shoot_green_sysone_hold_lmb():
	# TODO: implement logic for shoot_green_sysone_hold_lmb
	pass

func shoot_green_sysone_hold_rmb():
	# TODO: implement logic for shoot_green_sysone_hold_rmb
	pass

func shoot_green_sysone_hold_bmb():
	# TODO: implement logic for shoot_green_sysone_hold_bmb
	pass

func shoot_green_systwo_nohold_lmb():
	# TODO: implement logic for shoot_green_systwo_nohold_lmb
	pass

func shoot_green_systwo_nohold_rmb():
	# TODO: implement logic for shoot_green_systwo_nohold_rmb
	pass

func shoot_green_systwo_nohold_bmb():
	# TODO: implement logic for shoot_green_systwo_nohold_bmb
	pass

func shoot_green_systwo_hold_lmb():
	# TODO: implement logic for shoot_green_systwo_hold_lmb
	pass

func shoot_green_systwo_hold_rmb():
	# TODO: implement logic for shoot_green_systwo_hold_rmb
	pass

func shoot_green_systwo_hold_bmb():
	# TODO: implement logic for shoot_green_systwo_hold_bmb
	pass
#endregion

func function_shoot_name_parser(input_fire: Dictionary) -> String:
	var shoot_function_name: String = "shoot"
	
	var weapon_case: int = input_fire["weapon_state"]
	match weapon_case:
		0: shoot_function_name += "_blue"
		1: shoot_function_name += "_red"
		2: shoot_function_name += "_green"
	
	if not input_fire["weapon_toggle_button"]:
		shoot_function_name += "_sysone"
	else:
		shoot_function_name += "_systwo"

	if not input_fire["weapon_hold_button"]:
		shoot_function_name += "_nohold"
	else:
		shoot_function_name += "_hold"
	
	var shoot_case: int = 0
	# For green weapon (weapon_state == 2), detect hold input, otherwise tap input
	if weapon_case == 2:
		# Use hold inputs for green weapon
		if input_fire.has("shoot_hold") and input_fire["shoot_hold"]:
			shoot_case += 1
		if input_fire.has("shoot_alt_hold") and input_fire["shoot_alt_hold"]:
			shoot_case += 2
	else:
		# Use tap inputs for blue and red weapons
		if input_fire.has("shoot") and input_fire["shoot"]:
			shoot_case += 1
		if input_fire.has("shoot_alt") and input_fire["shoot_alt"]:
			shoot_case += 2
	
	match shoot_case:
		1: shoot_function_name += "_lmb" # left mouse button
		2: shoot_function_name += "_rmb" # right mouse button
		3: shoot_function_name += "_bmb" # both mouse buttons
	
	return shoot_function_name

func shoot(input_fire: Dictionary):
	if input_fire.size() != 7:
		push_error("Invalid input dictionary: missing keys")
		return
	var shoot_function_name = function_shoot_name_parser(input_fire)
	print("Calling shoot function:", shoot_function_name)

	if has_method(shoot_function_name):
		call(shoot_function_name)

	else:
		push_error("No such shoot function: " + shoot_function_name)

#func function_shoot_name_parser(input_fire: Dictionary):
	#var shoot_function_name: String = "shoot"
	#
	#var weapon_case: int = input_fire["weapon_state"]
	#match weapon_case:
		## Seriously, don't do this as hard code, use global enum that hasn't been settled yet
		#0: shoot_function_name += "_blue"
		#1: shoot_function_name += "_red"
		#2: shoot_function_name += "_green"
	#
	## Seriously, I need ternary operation
	#if not input_fire["weapon_toggle_button"]:
		#shoot_function_name += "_sysone"
	#else:
		#shoot_function_name += "_systwo"
#
	#if not input_fire["weapon_hold_button"]:
		#shoot_function_name += "_nohold"
	#else:
		#shoot_function_name += "_hold"
	#
	#var shoot_case: int = 0
	#if input_fire["shoot"]:
		#shoot_case += 1
	#if input_fire["shoot_alt"]:
		#shoot_case += 2
	#match shoot_case:
		#1: shoot_function_name += "_lmb" # left mouse button
		#2: shoot_function_name += "_rmb" # right mouse button
		#3: shoot_function_name += "_bmb" # both mouse buttons
	#
	#return shoot_function_name
	#
#func shoot(input_fire: Dictionary):
	#if input_fire.size() != 5:
		#push_error("Invalid input")
	#var shoot_function_name = function_shoot_name_parser(input_fire)
	#print(shoot_function_name)
	#call(shoot_function_name)
