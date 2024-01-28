class_name ThrownBaby
extends RigidBody2D

var velocity: Vector2 
var gravity: float = 1400.0
var t: float

func _ready():
	Beat.on_song_start.connect(queue_free)
	Beat.on_beat.connect(on_beat)
	apply_central_impulse(velocity)
	apply_torque_impulse(randf()*10000.0)
	if Beat.silly_mode: silly_mode_ready()

var n = 0
var exploding = randi()%7 == 0

func on_beat():
	n += 1
	if exploding and n == 5:
		explode()
		print("exploded")

func explode():
	var explosion = preload("res://game/explosion/explosion.tscn").instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	queue_free()

func silly_mode_ready():
	if randi()%5 == 1:
		var tween = create_tween()
		tween.tween_property($Baby,"scale",Vector2.ONE,10.0)
		modulate = Color(0.3,0.3,0.3)

func _process(delta):
	t+=delta
	if t > 3000.0: queue_free()
