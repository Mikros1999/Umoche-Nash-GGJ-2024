extends Area2D


func _ready():
	$Explosion.animation_finished.connect(queue_free)
	$Explosion.play("default")
	await get_tree().create_timer(0.1).timeout
	for body in get_overlapping_bodies():
		if body is ThrownBaby:
			body.apply_central_impulse(global_position.direction_to(body.global_position)*1500.0)
