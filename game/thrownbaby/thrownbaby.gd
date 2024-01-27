extends Sprite2D

var velocity: Vector2 
var gravity: float = 1400.0
var t: float

func _process(delta):
	velocity.y += gravity*delta
	global_position += velocity*delta
	rotation += delta
	t+=delta
	if t > 6.0: queue_free()
