extends RigidBody3D

@export var damage: int = 10
@export var lifetime: float = 3.0
var fall_limit_y: int = -50

func _ready():
	print("Projectile spawned")
	$Area3D.body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(_delta):
	if global_transform.origin.y < fall_limit_y:
		print("Projectile fell out")
		queue_free()

func _on_body_entered(body: Node3D):
	print("Projectile hit:", body.name)
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
