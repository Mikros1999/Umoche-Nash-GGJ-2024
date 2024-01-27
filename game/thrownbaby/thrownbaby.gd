extends RigidBody2D

var velocity: Vector2 
var gravity: float = 1400.0
var t: float

func _ready():
	apply_central_impulse(velocity)
	apply_torque_impulse(randf()*10000.0)
	if Beat.silly_mode: silly_mode_ready()

func silly_mode_ready():
	if randi()%5 == 1:
		var tween = create_tween()
		tween.tween_property($Baby,"scale",Vector2.ONE,10.0)
		modulate = Color(0.3,0.3,0.3)

func _process(delta):
	t+=delta
	if t > 6.0: queue_free()
