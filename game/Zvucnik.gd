extends Sprite2D

func _ready():
	Beat.hit_success.connect(on_success)

func on_success():
	var old_scale = scale
	scale *= 1.1
	$GornjiKrug.scale = Vector2.ONE*1.16
	$DonjiKrug.scale = Vector2.ONE*1.16
	var tween = create_tween().set_parallel(true)
	tween.tween_property($GornjiKrug,"scale",Vector2.ONE,0.1)
	tween.tween_property($DonjiKrug,"scale",Vector2.ONE,0.1)
	tween.tween_property(self,"scale",old_scale,0.1)
	for body in $Impulse.get_overlapping_bodies():
		body.apply_central_impulse(Vector2(-sign(scale.x)*300.0,-100))
